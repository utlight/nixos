--- Browse, restore, rename, destroy, and delete stored DeepSeek Harness
--- sessions from Neovim.
---
--- agentic.nvim ships a restore picker (list + `session/load`) but no destroy,
--- delete, or rename: ACP has no such methods, so this module operates on the
--- stored session artifacts and the local session registry directly. It puts
--- every operation in one Telescope picker:
---
---   <CR>   restore (or focus) the selected session
---    r     rename the selected session
---    d     destroy the selection, or every marked row (Tab marks rows)
---    D     delete the selection, or every marked row
---    a     toggle current-workspace / all-workspaces scope
---
--- The picker opens in normal mode; press `i` to type in the prompt.
---
--- The picker defaults to sessions whose recorded cwd matches Neovim's cwd;
--- `a` shows sessions from every workspace.
---
--- Rename appends a `session/title` event with `source.kind = "user"` at the
--- next sequence number. That is the same event DSH's title service writes for
--- its own rename, so it pins the title against automatic regeneration without
--- rewriting or recompressing existing log bytes. Stored logs are append-only
--- zstd frames (or plain JSONL); the event is appended under the same `flock`
--- lease DSH writers use, so a live host can never race the write.
---
--- Destroy closes a session open in this Neovim, releases its write lease, and
--- removes its widget while keeping the stored artifact. Delete destroys any
--- session open here first, then removes the artifact and its stale
--- list-projection cache row. Sessions owned by another live DSH host (another
--- nvim, or the Web host) are refused.
---
--- A session open in this Neovim can be renamed by closing it, writing the
--- title, and restoring it, but only after explicit confirmation.

local M = {}

local uv = vim.uv or vim.loop
local LEVELS = vim.log.levels

local NEW_SESSION_ID = "dsh-new-session"
local MAX_TITLE_BYTES = 80

local TITLE_PREFIX = '{"type":"session/title"'
local TURN_PREFIX = '{"type":"turn/start"'
local USER_PREFIX = '{"type":"user/message"'

local APPEND_SCRIPT = [[
size=$(wc -c < "$1")
size=${size##* }
[ "$size" = "$2" ] || exit 3
cat >> "$1" || exit 4
sync "$1" || exit 5
]]

local function notify(message, level) vim.notify("dsh sessions: " .. message, level or LEVELS.INFO) end

local function dsh_home()
  local configured = vim.env.DSH_HOME
  if configured ~= nil and configured ~= "" then return configured end

  return vim.fs.joinpath(vim.env.HOME or "~", ".dsh")
end

local function sessions_root() return vim.fs.joinpath(dsh_home(), "sessions") end

local function projection_cache(id)
  return vim.fs.joinpath(dsh_home(), "storages", "session_projcache", "sessions", id .. ".json")
end

local function starts_with(value, prefix) return value:sub(1, #prefix) == prefix end

--- Version and physical encoding of one stored generation filename.
local function parse_artifact(name)
  local version = name:match("^session%.v(%d+)%.jsonl(%.zstd)$")
  if version ~= nil then return tonumber(version), "zstd" end

  version = name:match("^session%.v(%d+)%.jsonl$")
  if version ~= nil then return tonumber(version), "none" end

  return nil, nil
end

--- Current-generation artifacts for one session directory, zstd first.
--- @return table[] artifacts, number|nil version
local function session_artifacts(dir)
  local artifacts, max_version = {}, nil

  local ok, iterator = pcall(vim.fs.dir, dir)
  if not ok then return artifacts, max_version end

  for name, kind in iterator do
    if kind == "file" then
      local version, compression = parse_artifact(name)
      if version ~= nil then
        if max_version == nil or version > max_version then max_version = version end
        artifacts[#artifacts + 1] = {
          path = vim.fs.joinpath(dir, name),
          version = version,
          compression = compression,
        }
      end
    end
  end

  if max_version == nil then return artifacts, max_version end

  local current = {}
  for _, artifact in ipairs(artifacts) do
    if artifact.version == max_version then current[#current + 1] = artifact end
  end

  table.sort(current, function(left, right)
    if left.compression ~= right.compression then return left.compression == "zstd" end

    return left.path < right.path
  end)

  return current, max_version
end

--- Byte length of the UTF-8 code point starting at `byte`.
local function utf8_lead_size(byte)
  if byte >= 0xF0 then return 4 end
  if byte >= 0xE0 then return 3 end
  if byte >= 0xC0 then return 2 end

  return 1
end

--- Prefix that fits a byte budget without splitting a code point.
local function utf8_prefix_bytes(text, max_bytes)
  if #text <= max_bytes then return text, false end

  local index = 1
  while index <= #text do
    local size = utf8_lead_size(text:byte(index))
    if index + size - 1 > max_bytes then break end
    index = index + size
  end

  return text:sub(1, index - 1), true
end

local function utf8_length(text)
  local count, index = 0, 1
  while index <= #text do
    index = index + utf8_lead_size(text:byte(index))
    count = count + 1
  end

  return count
end

local function utf8_prefix_characters(text, max_characters)
  local index, count = 1, 0
  while index <= #text and count < max_characters do
    index = index + utf8_lead_size(text:byte(index))
    count = count + 1
  end

  return text:sub(1, index - 1)
end

--- Text of the first user message, so rows are identifiable without a title.
--- Must stay free of Vimscript calls: this runs inside a system callback.
local function prompt_text(event)
  local content = event.data and event.data.content
  if type(content) ~= "table" then return nil end

  local blocks = {}
  for _, block in ipairs(content) do
    if type(block) == "table" and block.type == "text" and type(block.text) == "string" then
      blocks[#blocks + 1] = block.text
    end
  end

  local text = table.concat(blocks, " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then return nil end

  if utf8_length(text) > 72 then text = utf8_prefix_characters(text, 70) .. "..." end

  return text
end

--- One streaming decompression pass over a log.
---
--- Returns the header, whether a turn ever started, the first eligible user
--- message, the last stored title, the last physical line, and whether the
--- reader finished cleanly. Listing tolerates a torn tail; rename refuses it.
--- @return table
local function inspect_log(log)
  local state = {
    ok = false,
    header = nil,
    has_turn = false,
    prompt = nil,
    title = nil,
    last_line = nil,
  }

  local pending = ""
  local function handle_line(line)
    if line == "" then return end

    state.last_line = line

    if state.header == nil then
      local decoded, header = pcall(vim.json.decode, line)
      if decoded and type(header) == "table" and header.type == "session" then
        state.header = header
        return
      end
    end

    if starts_with(line, TURN_PREFIX) then
      state.has_turn = true
    elseif state.prompt == nil and starts_with(line, USER_PREFIX) then
      local decoded, event = pcall(vim.json.decode, line)
      if decoded and type(event) == "table" and type(event.data) == "table" then
        local source = event.data.source
        if type(source) == "table" and source.kind == "user" then state.prompt = prompt_text(event) end
      end
    elseif starts_with(line, TITLE_PREFIX) then
      local decoded, event = pcall(vim.json.decode, line)
      if decoded and type(event) == "table" and type(event.data) == "table" then
        local title = event.data.title
        if type(title) == "string" and title ~= "" then state.title = title end
      end
    end
  end

  local command = log:match("%.zstd$") and { "zstd", "-q", "-dc", log } or { "cat", log }

  local spawned, result = pcall(function()
    return vim
      .system(command, {
        text = true,
        stdout = function(_, data)
          if data == nil then return end

          pending = pending .. data
          local lines = vim.split(pending, "\n", { plain = true })
          pending = table.remove(lines)
          for _, line in ipairs(lines) do
            handle_line(line)
          end
        end,
      })
      :wait()
  end)

  if not spawned or result == nil then return state end

  if result.code == 0 and pending ~= "" then handle_line(pending) end

  state.ok = result.code == 0

  return state
end

--- Next event seq for a log, or nil when the tail is not a valid event.
local function last_event_seq(snapshot)
  local line = snapshot.last_line
  if line == nil then return nil end

  local decoded, event = pcall(vim.json.decode, line)
  if not decoded or type(event) ~= "table" then return nil end

  -- A header-only artifact has no events yet; the next event is seq 0.
  if event.type == "session" then return -1 end
  if type(event.seq) ~= "number" or event.seq < 0 then return nil end

  return event.seq
end

--- Read the stored title from the list-projection cache, if one was generated.
local function cached_title(id)
  local ok, lines = pcall(vim.fn.readfile, projection_cache(id))
  if not ok or type(lines) ~= "table" or #lines == 0 then return nil end

  local decoded, record = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(record) ~= "table" or record.version ~= 7 then return nil end

  local saved = record.record
  if type(saved) ~= "table" or type(saved.rows) ~= "table" then return nil end

  local row = saved.rows.title
  if type(row) ~= "table" or row.ver ~= 1 then return nil end

  local title = row.val
  if type(title) == "string" and title ~= "" then return title end

  return nil
end

local function describe_age(seconds)
  if seconds < 60 then return "now" end

  local minutes = math.floor(seconds / 60)
  if minutes < 60 then return string.format("%dm ago", minutes) end

  local hours = math.floor(minutes / 60)
  if hours < 24 then return string.format("%dh ago", hours) end

  return string.format("%dd ago", math.floor(hours / 24))
end

--- `free` when nobody holds the write lease, `locked` when a host owns it.
local function lock_state(dir)
  local lock = vim.fs.joinpath(dir, "session.lock")
  if uv.fs_stat(lock) == nil then return "free" end

  local ok, result = pcall(function() return vim.system({ "flock", "-n", lock, "-c", "true" }):wait() end)

  if not ok or result == nil then return "unknown" end

  return result.code == 0 and "free" or "locked"
end

local function canonical_path(path)
  if path == nil or path == "" then return nil end

  local ok, real = pcall(uv.fs_realpath, path)
  return vim.fs.normalize(ok and real or path)
end

local function same_path(left, right) return left ~= nil and right ~= nil and left == right end

local function now_ms()
  if type(uv.gettimeofday) == "function" then
    local seconds, microseconds = uv.gettimeofday()
    return seconds * 1000 + math.floor(microseconds / 1000)
  end

  return os.time() * 1000
end

--- Truncate to a UTF-8 byte budget without splitting a code point.
local function truncate_utf8(text, max_bytes) return utf8_prefix_bytes(text, max_bytes) end

--- Match DSH's session-title normalization and 80-byte title budget.
local function normalize_title(text)
  if type(text) ~= "string" then return "", false end

  text = text:gsub("\27%][^\7\27]*[\7\27\\]?", "")
  text = text:gsub("\27%[[0-?]*[ -/]*[@-~]", "")
  text = text:gsub("\27[@-_]", "")
  text = text:gsub("%c", " ")
  text = text:gsub("%s+", " ")
  text = text:gsub("^%s+", ""):gsub("%s+$", "")

  return truncate_utf8(text, MAX_TITLE_BYTES)
end

local function compress_zstd(text)
  local ok, result = pcall(function() return vim.system({ "zstd", "-q", "-c" }, { stdin = text }):wait() end)
  if not ok or result == nil or result.code ~= 0 then return nil end
  if result.stdout == nil or result.stdout == "" then return nil end

  return result.stdout
end

--- Append one payload under the session write lease, refusing stale views.
local function append_locked(item, artifact, payload, expected_size)
  local lock = vim.fs.joinpath(item.dir, "session.lock")
  local ok, result = pcall(
    function()
      return vim
        .system(
          { "flock", "-n", lock, "sh", "-c", APPEND_SCRIPT, "sh", artifact.path, tostring(expected_size) },
          { stdin = payload }
        )
        :wait()
    end
  )

  if not ok or result == nil then return false, "could not run the append helper" end
  if result.code == 0 then return true, nil end
  if result.code == 1 then return false, "owned by a live DSH host" end
  if result.code == 3 then return false, "the session log changed while renaming; retry" end
  if result.code == 4 then return false, "could not append to " .. artifact.path end
  if result.code == 5 then return false, "could not flush " .. artifact.path end

  return false, "append helper failed with exit code " .. tostring(result.code)
end

--- Best-effort update of the derived title row so other DSH clients show it.
local function update_cached_title(item, title, seq)
  if item.created_at_ms == nil then return false, nil end

  local path = projection_cache(item.id)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= "table" or #lines == 0 then return false, nil end

  local decoded, record = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(record) ~= "table" or record.version ~= 7 then return false, nil end

  local saved = record.record
  if type(saved) ~= "table" or type(saved.identity) ~= "table" then return false, nil end
  if saved.identity.createdAt ~= item.created_at_ms or saved.identity.formatVersion ~= 4 then return false, nil end

  local row = type(saved.rows) == "table" and saved.rows.title or nil
  if type(row) ~= "table" or row.ver ~= 1 then return false, nil end

  row.val = title
  if type(row.seq) ~= "number" or row.seq < seq then row.seq = seq end

  local encoded = vim.json.encode(record)
  local temporary = string.format("%s.tmp.%s", path, tostring(uv.hrtime()))
  local written = vim.fn.writefile({ encoded }, temporary)
  if written ~= 0 then return false, "could not write the projection cache" end

  local renamed, err = uv.fs_rename(temporary, path)
  if not renamed then
    pcall(uv.fs_unlink, temporary)
    return false, "could not replace the projection cache: " .. tostring(err)
  end

  return true, nil
end

--- Every stored session, newest first.
--- @return table[]
function M.list()
  local items = {}
  local root = sessions_root()

  local ok, iterator = pcall(vim.fs.dir, root)
  if not ok then return items end

  local now = os.time()
  for cwd_dir, kind in iterator do
    if kind == "directory" then
      local cwd_path = vim.fs.joinpath(root, cwd_dir)
      local dir_ok, session_iterator = pcall(vim.fs.dir, cwd_path)
      if dir_ok then
        for id, session_kind in session_iterator do
          if session_kind == "directory" then
            local dir = vim.fs.joinpath(cwd_path, id)
            local artifacts = session_artifacts(dir)
            local primary = artifacts[1]
            if primary ~= nil then
              local snapshot = inspect_log(primary.path)
              local header = snapshot.header
              local stat = uv.fs_stat(dir)
              local used = snapshot.has_turn
              items[#items + 1] = {
                id = id,
                dir = dir,
                cwd = header and header.cwd or nil,
                created_at = math.floor((header and header.createdAt or 0) / 1000),
                created_at_ms = header and header.createdAt or nil,
                age = now - (stat ~= nil and stat.mtime.sec or 0),
                has_turn = used,
                lock = lock_state(dir),
                title = snapshot.title or cached_title(id),
                summary = used and snapshot.prompt or nil,
                version = primary.version,
              }
            end
          end
        end
      end
    end
  end

  table.sort(items, function(left, right) return (left.created_at or 0) > (right.created_at or 0) end)

  for _, item in ipairs(items) do
    item.age_label = describe_age(item.age)
    item.label = item.title or item.summary or "Untitled"
  end

  return items
end

--- Remove one stored session artifact plus its projection-cache row.
--- @param item table Entry from M.list()
--- @param opts table|nil `force` skips the live-writer guard
--- @return boolean removed
function M.remove(item, opts)
  opts = opts or {}

  if not opts.force and lock_state(item.dir) ~= "free" then
    notify(string.format("%s is still owned by a live DSH host", item.id), LEVELS.WARN)
    return false
  end

  if vim.fn.delete(item.dir, "rf") ~= 0 then
    notify("could not remove " .. item.dir, LEVELS.ERROR)
    return false
  end

  vim.fn.delete(projection_cache(item.id))

  return true
end

--- Sessions currently attached in this Neovim instance, by ACP session id.
local function live_session(id)
  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok or type(registry.sessions) ~= "table" then return nil end

  for _, session in pairs(registry.sessions) do
    if type(session) == "table" and session.session_id == id and not session._destroyed then return session end
  end

  return nil
end

local function current_session()
  local ok, registry = pcall(require, "agentic.session_registry")
  if not ok or type(registry.current) ~= "function" then return nil end

  local called, session = pcall(registry.current)

  return called and session or nil
end

--- Ask the DSH host to close a session so it flushes and releases its lease.
local function close_on_host(session, id)
  local agent = session ~= nil and session.agent or nil
  if type(agent) ~= "table" and type(agent) ~= "userdata" then return false end
  if type(agent._send_request) ~= "function" then return false end

  local acknowledged = false
  agent:_send_request("session/close", { sessionId = id }, function() acknowledged = true end)
  vim.wait(1500, function() return acknowledged end, 20)

  return acknowledged
end

--- Restore a stored session, or focus it when it is already open here.
--- @param id string ACP session id
function M.open(id)
  local live = live_session(id)
  if live ~= nil and live.session_key ~= nil then
    require("agentic.session_registry").show_session(live.session_key)
    return
  end

  require("agentic").restore_session_by_id(id)
end

--- Start a new session, keeping the current one in the background.
function M.new_session() require("agentic").new_session({ auto_add_to_context = false }) end

--- Close one session live in this Neovim and drop its widget, keeping its log.
local function destroy_live(item, live)
  if live.session_key == nil then return false, "session has no widget key" end

  if not close_on_host(live, item.id) then return false, "host did not confirm closing" end

  if not vim.wait(2000, function() return lock_state(item.dir) == "free" end, 25) then
    return false, "session is still locked by the host"
  end

  local ok, err = pcall(require("agentic").destroy_session, { session = live.session_key })
  if not ok then return false, "could not remove the session widget: " .. tostring(err) end

  return true, nil
end

--- Destroy live sessions in this Neovim, keeping their stored logs.
---
--- Supports multiple targets from marked rows; destruction is reversible, so it
--- asks for no confirmation. Sessions not open here are reported and left alone.
--- @param targets table[] Items from M.list()
--- @return number destroyed
function M.destroy(targets)
  if #targets == 0 then return 0 end

  local destroyed, cancelled, skipped = 0, 0, {}

  for _, item in ipairs(targets) do
    local live = live_session(item.id)
    if live == nil then
      if lock_state(item.dir) ~= "free" then
        skipped[#skipped + 1] = item.id:sub(1, 8) .. " (owned by another DSH host)"
      else
        skipped[#skipped + 1] = item.id:sub(1, 8) .. " (not open in this nvim)"
      end
    else
      local was_generating = live.is_generating == true
      local ok, err = destroy_live(item, live)
      if ok then
        destroyed = destroyed + 1
        if was_generating then cancelled = cancelled + 1 end
      else
        skipped[#skipped + 1] = item.id:sub(1, 8) .. " (" .. tostring(err) .. ")"
      end
    end
  end

  if destroyed == 0 then
    notify("nothing to destroy: " .. table.concat(skipped, ", "), LEVELS.WARN)
    return 0
  end

  local message = string.format("destroyed %d session(s)", destroyed)
  if cancelled > 0 then message = message .. string.format(", cancelled %d in-flight turn(s)", cancelled) end
  if #skipped > 0 then message = message .. "; kept " .. table.concat(skipped, ", ") end

  notify(message)

  return destroyed
end

--- Delete stored sessions; ones open in this Neovim are destroyed first.
--- Sessions owned by another live host are refused.
--- @param targets table[] Items from M.list()
function M.delete(targets)
  if #targets == 0 then return end

  local removable, skipped, live_count = {}, {}, 0

  for _, item in ipairs(targets) do
    local live = live_session(item.id)
    if live ~= nil then
      removable[#removable + 1] = { item = item, live = live }
      live_count = live_count + 1
    elseif lock_state(item.dir) ~= "free" then
      skipped[#skipped + 1] = item.id:sub(1, 8) .. " (owned by another DSH host)"
    else
      removable[#removable + 1] = { item = item }
    end
  end

  if #removable == 0 then
    notify("nothing to delete: " .. table.concat(skipped, ", "), LEVELS.WARN)
    return
  end

  local question = string.format("Delete %d session(s)?", #removable)
  if live_count > 0 then question = question .. string.format(" %d open here will be destroyed first.", live_count) end
  if #skipped > 0 then question = question .. string.format(" %d live session(s) elsewhere will be kept.", #skipped) end

  if vim.fn.confirm(question, "&Delete\n&Cancel", 2) ~= 1 then return end

  local removed = 0
  for _, entry in ipairs(removable) do
    local item, live = entry.item, entry.live
    if live ~= nil then
      local destroyed, destroy_error = destroy_live(item, live)
      if not destroyed then
        skipped[#skipped + 1] = item.id:sub(1, 8) .. " (" .. tostring(destroy_error) .. ")"
      elseif M.remove(item) then
        removed = removed + 1
      end
    elseif M.remove(item) then
      removed = removed + 1
    end
  end

  local message = string.format("deleted %d session(s)", removed)
  if #skipped > 0 then message = message .. "; kept " .. table.concat(skipped, ", ") end

  notify(message)
end

--- Rename one stored session by appending a user `session/title` event.
---
--- Refuses any session that a live host still owns; callers that legitimately
--- close a live session first (the picker's current-session flow) can call this
--- once `session/close` has released the lease.
--- @param item table Entry from M.list()
--- @param title string User-supplied title
--- @return boolean renamed
function M.rename(item, title)
  local normalized, truncated = normalize_title(title)
  if normalized == "" then
    notify("title must contain visible characters", LEVELS.WARN)
    return false
  end

  if live_session(item.id) ~= nil then
    notify("session is open in this Neovim; close it before renaming", LEVELS.WARN)
    return false
  end

  if lock_state(item.dir) ~= "free" then
    notify(string.format("%s is owned by a live DSH host", item.id:sub(1, 8)), LEVELS.WARN)
    return false
  end

  local artifacts, version = session_artifacts(item.dir)
  if #artifacts == 0 then
    notify("no stored log for " .. item.id:sub(1, 8), LEVELS.ERROR)
    return false
  end
  if version ~= 4 then
    notify(string.format("cannot rename a format v%s session; only v4 is supported", tostring(version)), LEVELS.WARN)
    return false
  end

  local plans = {}
  local event_time = now_ms()
  for _, artifact in ipairs(artifacts) do
    local stat = uv.fs_stat(artifact.path)
    if stat == nil then
      notify("could not stat " .. artifact.path, LEVELS.ERROR)
      return false
    end

    local snapshot = inspect_log(artifact.path)
    if not snapshot.ok then
      notify("session log is incomplete or corrupt; open it once in DSH to repair it", LEVELS.WARN)
      return false
    end
    if snapshot.header == nil then
      notify("could not read the session header", LEVELS.ERROR)
      return false
    end

    local seq = last_event_seq(snapshot)
    if seq == nil then
      notify("could not read the last session event", LEVELS.ERROR)
      return false
    end

    local next_seq = seq + 1
    local encoded_ok, encoded_data = pcall(vim.json.encode, {
      title = normalized,
      messageSeqs = {},
      source = { kind = "user" },
    })
    if not encoded_ok or type(encoded_data) ~= "string" then
      notify("could not encode the title event", LEVELS.ERROR)
      return false
    end

    -- Keep DSH's field order so the type marker stays at the start of the row.
    local line =
      string.format('{"type":"session/title","seq":%d,"time":%d,"data":%s}\n', next_seq, event_time, encoded_data)
    local payload = artifact.compression == "zstd" and compress_zstd(line) or line
    if payload == nil then
      notify("could not compress the title event", LEVELS.ERROR)
      return false
    end

    plans[#plans + 1] = { artifact = artifact, payload = payload, size = stat.size, seq = next_seq }
  end

  -- Append the primary artifact first: the picker reads its title from there.
  local primary = plans[1]
  local appended_primary, append_error = append_locked(item, primary.artifact, primary.payload, primary.size)
  if not appended_primary then
    notify("could not rename: " .. tostring(append_error), LEVELS.ERROR)
    return false
  end

  local appended = 1
  for index = 2, #plans do
    local plan = plans[index]
    local ok, message = append_locked(item, plan.artifact, plan.payload, plan.size)
    if ok then
      appended = appended + 1
    else
      notify("renamed the primary log but not " .. plan.artifact.path .. ": " .. tostring(message), LEVELS.WARN)
    end
  end

  -- The cache must never lead a divergent secondary log; only update it when
  -- every artifact received the same sequence number.
  if appended == #plans then
    local same_seq = true
    for index = 2, #plans do
      if plans[index].seq ~= primary.seq then
        same_seq = false
        break
      end
    end

    if same_seq then
      local cached, cache_error = update_cached_title(item, normalized, primary.seq)
      if not cached and cache_error ~= nil then notify(cache_error, LEVELS.WARN) end
    end
  end

  item.title = normalized
  item.label = normalized

  notify(string.format("renamed to %s%s", normalized, truncated and " (truncated to 80 bytes)" or ""))

  return true
end

local function display_width(text) return vim.fn.strdisplaywidth(text or "") end

local function pad_right(text, width) return text .. string.rep(" ", math.max(0, width - display_width(text))) end

local function pad_left(text, width) return string.rep(" ", math.max(0, width - display_width(text))) .. text end

--- Truncate to a display-cell budget without splitting a UTF-8 code point.
local function truncate_display(text, width)
  if display_width(text) <= width then return text end

  local characters = vim.fn.strchars(text)
  local fitting = 0
  while fitting < characters do
    local candidate = vim.fn.strcharpart(text, 0, fitting + 1)
    if display_width(candidate) > width - 1 then break end
    fitting = fitting + 1
  end

  return vim.fn.strcharpart(text, 0, fitting) .. "…"
end

--- Rows for the picker: one synthetic "new session" row plus stored sessions.
--- @param show_all boolean|nil Include sessions from other workspaces
--- @return table[] rows, number hidden
local function entries(show_all)
  local rows = {
    {
      id = NEW_SESSION_ID,
      text = "+ new session",
      ordinal = "new session create start",
    },
  }

  local current_cwd = canonical_path(vim.fn.getcwd())
  local records, hidden = {}, 0

  for _, item in ipairs(M.list()) do
    if show_all or same_path(canonical_path(item.cwd), current_cwd) then
      local workspace = ""
      if show_all and not same_path(canonical_path(item.cwd), current_cwd) and item.cwd ~= nil and item.cwd ~= "" then
        workspace = "@" .. vim.fs.basename(item.cwd)
      end

      records[#records + 1] = {
        id = item.id,
        item = item,
        age = item.age_label,
        state = item.has_turn and "used" or "blank",
        lock = item.lock == "locked" and "LIVE" or (item.lock == "unknown" and "LOCK?" or ""),
        session_id = item.id:sub(1, 8),
        workspace = workspace,
        title = item.label,
        ordinal = string.format("%s %s %s", item.label, item.id, item.cwd or ""),
      }
    else
      hidden = hidden + 1
    end
  end

  local title_cap = math.max(20, math.min(60, vim.o.columns - 50))
  local widths = { age = 0, state = 0, title = 0, lock = 0, id = 0 }
  for _, row in ipairs(records) do
    widths.age = math.max(widths.age, display_width(row.age))
    widths.state = math.max(widths.state, display_width(row.state))
    widths.title = math.max(widths.title, display_width(row.title))
    widths.lock = math.max(widths.lock, display_width(row.lock))
    widths.id = math.max(widths.id, display_width(row.session_id))
  end
  widths.title = math.min(widths.title, title_cap)

  for _, row in ipairs(records) do
    local parts = {}
    if widths.age > 0 then parts[#parts + 1] = pad_left(row.age, widths.age) end
    if widths.state > 0 then parts[#parts + 1] = pad_right(row.state, widths.state) end
    parts[#parts + 1] = pad_right(truncate_display(row.title, widths.title), widths.title)
    if widths.lock > 0 then parts[#parts + 1] = pad_right(row.lock, widths.lock) end
    if widths.id > 0 then parts[#parts + 1] = pad_right(row.session_id, widths.id) end
    if row.workspace ~= "" then parts[#parts + 1] = row.workspace end

    row.text = table.concat(parts, "  ")
    rows[#rows + 1] = row
  end

  return rows, hidden
end

local function open_entry(row)
  if row.id == NEW_SESSION_ID then
    M.new_session()
    return
  end

  M.open(row.id)
end

local function selected_items(rows, verb)
  local targets, new_requested = {}, false
  for _, row in ipairs(rows) do
    if row == nil then
      -- tolerate empty multi-select results
    elseif row.id == NEW_SESSION_ID then
      new_requested = true
    elseif row.item ~= nil then
      targets[#targets + 1] = row.item
    end
  end

  if new_requested then notify("the new-session row cannot be " .. verb, LEVELS.WARN) end

  return targets
end

local function delete_rows(rows) M.delete(selected_items(rows, "deleted")) end

local function destroy_rows(rows) return M.destroy(selected_items(rows, "destroyed")) end

--- Prompt for a new title and persist it, closing/reloading a live current session.
local function prompt_rename(item, done)
  if item == nil then
    done()
    return
  end

  vim.ui.input({ prompt = "Session title: ", default = item.title or "" }, function(input)
    if input == nil then
      done()
      return
    end

    local live = live_session(item.id)
    if live == nil then
      M.rename(item, input)
      done()
      return
    end

    local current = current_session()
    if current == nil or current.session_id ~= item.id then
      notify("session is open in another agentic session; close it before renaming", LEVELS.WARN)
      done()
      return
    end

    if live.is_generating then
      notify("session is generating; stop it before renaming", LEVELS.WARN)
      done()
      return
    end

    if vim.fn.confirm("Rename will close and reload this session. Continue?", "&Rename\n&Cancel", 2) ~= 1 then
      done()
      return
    end

    if not close_on_host(live, item.id) then
      notify("host did not confirm closing the session", LEVELS.WARN)
      done()
      return
    end

    if not vim.wait(2000, function() return lock_state(item.dir) == "free" end, 25) then
      notify("session is still locked by the host; try again", LEVELS.WARN)
      done()
      return
    end

    local destroyed, destroy_error = pcall(require("agentic").destroy_session)
    if not destroyed then
      notify("could not close the session widget: " .. tostring(destroy_error), LEVELS.ERROR)
      done()
      return
    end

    local renamed = M.rename(item, input)
    local restored, restore_error = pcall(require("agentic").restore_session_by_id, item.id)
    if not restored then
      notify("could not restore the session: " .. tostring(restore_error), LEVELS.ERROR)
    elseif not renamed then
      notify("session was restored without the new title", LEVELS.WARN)
    end

    -- The restored widget is the useful view; keep the picker closed.
  end)
end

--- Plain `vim.ui.select` fallback when Telescope is unavailable.
local function fallback_picker(rows, opts)
  opts = opts or {}

  local items = {}
  if not opts.show_all and (opts.hidden or 0) > 0 then
    items[#items + 1] = { kind = "all", label = string.format("Show all workspaces (%d elsewhere)", opts.hidden) }
  end

  for _, row in ipairs(rows) do
    items[#items + 1] = { kind = "row", label = row.text, row = row }
  end

  vim.ui.select(items, {
    prompt = "DSH sessions",
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice == nil then return end

    if choice.kind == "all" then
      M.picker({ show_all = true })
      return
    end

    local row = choice.row
    if row == nil then return end

    if row.id == NEW_SESSION_ID then
      M.new_session()
      return
    end

    vim.ui.select({ "Restore", "Rename", "Delete" }, { prompt = row.text }, function(action)
      if action == "Restore" then
        M.open(row.id)
      elseif action == "Rename" then
        prompt_rename(row.item, function() M.picker({ show_all = opts.show_all }) end)
      elseif action == "Delete" then
        delete_rows({ row })
      end
    end)
  end)
end

--- One picker for restore, rename, delete, new session, and workspace scope.
--- @param opts table|nil `show_all` opens every workspace
function M.picker(opts)
  opts = opts or {}
  local show_all = opts.show_all == true
  local rows, hidden = entries(show_all)

  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    fallback_picker(rows, { show_all = show_all, hidden = hidden })
    return
  end

  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function current_row()
    local entry = action_state.get_selected_entry()

    return entry ~= nil and entry.data or nil
  end

  local function marked_rows(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selected = picker ~= nil and picker:get_multi_selection() or {}
    local rows_selected = {}
    for _, entry in ipairs(selected) do
      rows_selected[#rows_selected + 1] = entry.data
    end

    if #rows_selected == 0 then
      local entry = action_state.get_selected_entry()
      if entry ~= nil then rows_selected[1] = entry.data end
    end

    return rows_selected
  end

  local results_title
  if show_all then
    results_title = string.format("%d stored · all workspaces · a this workspace", #rows - 1)
  elseif hidden > 0 then
    results_title = string.format("%d here · %d elsewhere · a all workspaces", #rows - 1, hidden)
  else
    results_title = string.format("%d stored in this workspace", #rows - 1)
  end

  local prompt_title = "DSH sessions — <CR> restore · r rename · d destroy · D delete · a "
    .. (show_all and "this workspace" or "all workspaces")

  pickers
    .new({}, {
      prompt_title = prompt_title,
      results_title = results_title,
      initial_mode = "normal",
      finder = finders.new_table({
        results = rows,
        entry_maker = function(row)
          return {
            value = row.id,
            display = row.text,
            ordinal = row.ordinal,
            data = row,
          }
        end,
      }),
      previewer = false,
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        local function close_and_reopen(all)
          actions.close(prompt_bufnr)
          M.picker({ show_all = all })
        end

        local function rename_selected()
          local row = current_row()
          if row == nil then return end
          if row.id == NEW_SESSION_ID then
            notify("the new-session row cannot be renamed", LEVELS.WARN)
            return
          end

          actions.close(prompt_bufnr)
          prompt_rename(row.item, function() M.picker({ show_all = show_all }) end)
        end

        actions.select_default:replace(function()
          local row = current_row()
          actions.close(prompt_bufnr)
          if row ~= nil then open_entry(row) end
        end)

        map("n", "r", rename_selected)

        map("n", "a", function() close_and_reopen(not show_all) end)

        map("n", "d", function()
          local targets = marked_rows(prompt_bufnr)
          actions.close(prompt_bufnr)
          destroy_rows(targets)
          M.picker({ show_all = show_all })
        end)

        map("n", "D", function()
          local targets = marked_rows(prompt_bufnr)
          actions.close(prompt_bufnr)
          delete_rows(targets)
        end)

        return true
      end,
    })
    :find()
end

--- Register the user command.
function M.setup()
  vim.api.nvim_create_user_command("DshSessions", M.picker, {
    desc = "DSH sessions: restore, rename, destroy, delete, or start a new one",
  })
end

return M
