local function nearest_csproj(start_dir)
  local dir = start_dir
  while dir and dir ~= "/" and dir ~= "" do
    local hit = vim.fn.glob(dir .. "/*.csproj")
    if hit ~= "" then
      return dir, hit:match("([^\\/]+)%.csproj$")
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil, nil
end

local function cs_namespace()
  local file_dir = vim.fn.expand("%:p:h")
  local root, proj_name = nearest_csproj(file_dir)
  if not root then
    return vim.fn.expand("%:t:r")
  end
  local rel = file_dir:sub(#root + 2)
  local ns = proj_name
  if rel ~= "" then
    ns = ns .. "." .. rel:gsub("[/\\]", ".")
  end
  return ns
end

local function cs_template(file_name)
  if file_name:match("Command$") then
    return {
      lines = {
        "using Dapper;",
        "using TP.Application.Common.Connections.Interface.Shards;",
        "using TP.Application.Common.Requests.Interface.Commands;",
        "",
        "namespace " .. cs_namespace() .. ";",
        "",
        "public abstract class " .. file_name,
        "{",
        "\tpublic record Request() : ICommand<Response>;",
        "\tpublic record Response : ICommandResponse;",
        "",
        "\tpublic class Handler(IShardDbConnection dbConnection) : ICommandHandler<Request, Response>",
        "\t{",
        "\t\tpublic async Task<Response> HandleAsync(Request request)",
        "\t\t{",
        "\t\t\tvar sql =",
        '\t\t\t\t"""',
        "\t\t\t\t\t",
        '\t\t\t\t""";',
        "",
        "\t\t\tvar parameters = new",
        "\t\t\t{",
        "\t\t\t\t",
        "\t\t\t};",
        "",
        "\t\t\tawait dbConnection.Connection.ExecuteAsync(sql, parameters);",
        "",
        "\t\t\treturn new Response();",
        "\t\t}",
        "\t}",
        "}",
      },
      cursor = { 18, 20 },
    }
  end

  if file_name:match("Query$") then
    return {
      lines = {
        "using Dapper;",
        "using TP.Application.Common.Connections.Interface.Shards;",
        "using TP.Application.Common.Requests.Interface.Queries;",
        "",
        "namespace " .. cs_namespace() .. ";",
        "",
        "public abstract class " .. file_name,
        "{",
        "\tpublic record Request() : IQuery<Response>;",
        "\tpublic record Response : IQueryResponse;",
        "",
        "\tpublic class Handler(IShardDbConnection dbConnection) : IQueryHandler<Request, Response>",
        "\t{",
        "\t\tpublic async Task<Response> HandleAsync(Request request)",
        "\t\t{",
        "\t\t\tvar sql =",
        '\t\t\t\t"""',
        "\t\t\t\t\t",
        '\t\t\t\t""";',
        "",
        "\t\t\tvar parameters = new",
        "\t\t\t{",
        "\t\t\t\t",
        "\t\t\t};",
        "",
        "\t\t\tvar response = await dbConnection.Connection.QueryAsync(sql, parameters);",
        "",
        "\t\t\treturn new Response();",
        "\t\t}",
        "\t}",
        "}",
      },
      cursor = { 18, 20 },
    }
  end

  local kind = file_name:match("^I[A-Z]") and "interface" or "class"

  return {
    lines = {
      "namespace " .. cs_namespace() .. ";",
      "",
      "public " .. kind .. " " .. file_name,
      "{",
      "    ",
      "}",
    },
    cursor = { 5, 5 },
  }
end

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.cs",
  callback = function(args)
    local fileName = vim.fn.expand("%:t:r")

    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)

    if #lines > 1 or lines[1] ~= "" then
      return
    end

    local template = cs_template(fileName)

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, template.lines)
    vim.api.nvim_win_set_cursor(0, template.cursor)
    vim.cmd("retab")
    vim.cmd("startinsert")
  end,
})
