local function is_dotnet_project(dir)
  local ok, iter = pcall(vim.fs.dir, dir)
  if not ok then return false end
  for name, type in iter do
    if type == "file" then
      for _, pattern in ipairs({ "%.slnx$", "%.sln$", "%.csproj$" }) do
        if name:match(pattern) then return true end
      end
    end
  end
  return false
end

local function get_source()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      local ok, src = pcall(vim.api.nvim_buf_get_var, buf, "neo_tree_source")
      if ok then return src end
    end
  end

  return is_dotnet_project(vim.fn.getcwd()) and "dotnet-tree" or "filesystem"
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "alessandropietrobelli/dotnet-tree.nvim",
  },
  lazy = false,
  config = function()
    local dotnet_tree_commands = require("dotnet-tree.commands")
    local neo_tree_commands = require("neo-tree.sources.common.commands")

    require("neo-tree").setup({
      close_if_last_window = true,
      use_popups_for_input = false,
      sources = { "filesystem", "dotnet-tree" },
      ["dotnet-tree"] = {
        follow_current_file = { enabled = true },
        window = {
          mappings = {
            ["a"] = neo_tree_commands.add,
            ["A"] = dotnet_tree_commands.add,
            ["d"] = neo_tree_commands.delete,
            ["D"] = dotnet_tree_commands.debug,
            ["r"] = neo_tree_commands.rename,
            ["b"] = "noop",
            ["B"] = "noop",
            ["t"] = "noop",
          },
        },
      },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true, leave_dirs_open = true },
        use_libuv_file_watcher = true,
        filtered_items = { visible = true },
      },
      default_component_configs = {
        git_status = {
          symbols = {
            added = "",
            deleted = "",
          },
        },
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "noop",
        },
      },
    })

    vim.keymap.set(
      "n",
      "<leader>n",
      function()
        require("neo-tree.command").execute({
          action = "show",
          source = get_source(),
          toggle = true,
          reveal = true,
          focus = false,
          dir = vim.fn.getcwd(),
        })
      end,
      { desc = "Open [N]eoTree" }
    )

    vim.keymap.set("n", "<leader>N", function()
      vim.cmd("Neotree close")
      require("neo-tree.command").execute({
        action = "show",
        position = "current",
        source = get_source(),
        reveal = true,
        dir = vim.fn.getcwd(),
      })
    end, { desc = "Open [N]eotree Current" })

    vim.keymap.set("n", "<leader>e", function()
      local state = require("neo-tree.sources.manager").get_state(get_source())
      if not state then return end

      if state.winid and vim.api.nvim_get_current_win() == state.winid then
        vim.cmd("wincmd p")
      else
        require("neo-tree.command").execute({
          action = "focus",
          source = get_source(),
        })
      end
    end, { desc = "Focus [N]eoTree" })
  end,
}
