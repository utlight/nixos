local function get_source()
  local source_name = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      local ok, src = pcall(vim.api.nvim_buf_get_var, buf, "neo_tree_source")
      if ok then
        source_name = src
        break
      end
    end
  end

  return source_name or "filesystem"
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
    require("neo-tree").setup({
      close_if_last_window = true,
      sources = { "filesystem", "dotnet-tree" },
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
          },
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

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        require("neo-tree.command").execute({
          action = "show",
          reveal = true,
          focus = false,
          dir = vim.fn.getcwd(),
        })
      end,
    })
  end,
}
