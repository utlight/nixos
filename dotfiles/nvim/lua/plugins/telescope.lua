return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local themes = require("telescope.themes")
    require("telescope").setup({
      defaults = themes.get_ivy(),
      extensions = {
        ["ui-select"] = {
          themes.get_cursor(),
        },
        ["fzf"] = {},
      },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]iles" })
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[D]iagnostics" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[B]uffers" })
    vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "[S]earch" })
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "[O]ld Files" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[H]elp" })
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "[S]ymbols" })
    vim.keymap.set("n", "<leader>f/", builtin.live_grep, { desc = "[S]earch Workspace" })
    vim.keymap.set("n", "<leader>fn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[N]vim Files" })
  end,
}
