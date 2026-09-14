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
  },
  lazy = false,
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      sources = { "filesystem", "git_status" },
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true, leave_dirs_open = true },
        use_libuv_file_watcher = true,
        filtered_items = { visible = true },
      },
      git_status = {
        window = {
          mappings = {
            ["<cr>"] = "diff_selected_file",
            ["e"] = "open",
          },
        },
      },
      commands = {
        diff_selected_file = function(state)
          local node = state.tree:get_node()
          if not node then
            return
          end
          if node.type ~= "file" then
            state.commands["toggle_node"](state)
            return
          end

          local path = node.path or node:get_id()

          require("diffview").open({ "--", path })
        end,
      },
    })

    vim.keymap.set("n", "<leader>n", function()
      require("neo-tree.command").execute({
        action = "show",
        source = get_source(),
        toggle = true,
        reveal = true,
        focus = false,
        dir = vim.fn.getcwd(),
      })
    end, { desc = "Open [N]eoTree" })

    vim.keymap.set("n", "<leader>e", function()
      local state = require("neo-tree.sources.manager").get_state(get_source())
      if not state then
        return
      end

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
