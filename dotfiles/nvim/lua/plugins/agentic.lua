return {
  "carlos-algms/agentic.nvim",
  init = function() require("config.dsh_sessions").setup() end,
  config = function()
    local agentic = require("agentic")

    local dsh_sessions = require("config.dsh_sessions")
    dsh_sessions.install_session_patch()

    agentic.setup({
      provider = "deepseek-acp",
      acp_providers = {
        ["deepseek-acp"] = {
          name = "DeepSeek ACP",
          command = "dsh",
          args = { "--profile", "nix-acp-enhanced" },
          default_thought_level = "high",
          default_mode = "workspace-write",
          env = {
            DSH_ACP_STREAM_DELTAS = "false",
          },
        },
      },
      keymaps = {
        widget = {
          change_mode = "<localLeader>am",
          change_thought_level = "<localLeader>at",
          open_options = "<localLeader>ao",
          destroy_session = "noop",
          next_session = "noop",
          prev_session = "noop",
          switch_provider = "noop",
          select_session = "noop",
          switch_model = "noop",
        },
        prompt = {
          paste_image = "<localLeader>ap",
        },
      },
      folding = { tool_calls = { threshold = 0 } },
      windows = { width = "35%" },
      headers = {
        chat = function(parts, session_state)
          local header = ""

          if session_state then
            local provider_name = session_state:get_provider_name()
            if provider_name then header = header .. provider_name end

            if parts.context then header = header .. " | " .. parts.context end

            local thought_level = session_state:get_thought_level_name()
            if thought_level then header = header .. " | Thought Effort: " .. thought_level end
          end
          return header
        end,
        input = function(parts, session_state)
          local pieces = { parts.title }
          local summary = session_state and dsh_sessions.summary(session_state) or { severity = 0 }
          local severity = summary.severity or 0

          if session_state then
            local used = "Used: --"
            if summary.percent ~= nil then used = string.format("Used: %d%%", summary.percent) end

            local tokens = "Σ --"
            if summary.total_in and summary.total_out then
              tokens = string.format(
                "Σ %s/%s",
                dsh_sessions.format_token_count(summary.total_in),
                dsh_sessions.format_token_count(summary.total_out)
              )
            end

            local hit = "Hit: --"
            if summary.hit_percent ~= nil then hit = string.format("Hit: %.1f%%", summary.hit_percent) end

            pieces[#pieces + 1] = used
            pieces[#pieces + 1] = tokens
            pieces[#pieces + 1] = hit
          end

          local text = table.concat(pieces, " | "):gsub("%%", "%%%%")

          if severity >= 2 then
            return "%#DiagnosticError#" .. text .. "%#Normal#"
          elseif severity == 1 then
            return "%#DiagnosticWarn#" .. text .. "%#Normal#"
          end
          return text
        end,
      },
    })

    vim.keymap.set("n", "<leader>as", require("config.dsh_sessions").picker, { desc = "DSH sessions" })
    vim.keymap.set("n", "<leader>ad", agentic.add_current_line_diagnostics, { desc = "Add diagnostics" })
    vim.keymap.set(
      { "n", "v" },
      "<leader>af",
      agentic.add_selection_or_file_to_context,
      { desc = "Add file/selection" }
    )
    vim.keymap.set(
      "n",
      "<leader>an",
      function() agentic.toggle({ focus_prompt = false, auto_add_to_context = false }) end,
      { desc = "Toggle Agentic" }
    )

    vim.keymap.set(
      "n",
      "<leader>ae",
      function() agentic.open({ focus_prompt = true, auto_add_to_context = false }) end,
      { desc = "Focus Agentic" }
    )
  end,
}
