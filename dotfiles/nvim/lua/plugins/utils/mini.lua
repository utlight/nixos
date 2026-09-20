return {
  "nvim-mini/mini.nvim",
  version = "*",
  config = function()
    require("mini.surround").setup()
    require("mini.splitjoin").setup({ mappings = { toggle = "gs" } })
    require("mini.ai").setup({
      custom_textobjects = {
        i = require("mini.extra").gen_ai_spec.indent(),
        f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
      },
    })
    do
      require("mini.pairs").setup({
        mappings = {
          ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]" },
          [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]" },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(args) vim.keymap.set("i", "'", "'", { buffer = args.buf }) end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typescriptreact",
        callback = function(args)
          vim.keymap.set("i", "<", "<", { buffer = args.buf })
          vim.keymap.set("i", ">", ">", { buffer = args.buf })
        end,
      })
    end

    do
      require("mini.jump").setup({ delay = { highlight = 100 } })
      vim.api.nvim_set_hl(0, "MiniJump", { link = "Search" })

      vim.keymap.set({ "n", "x", "o" }, "<Esc>", function()
        vim.api.nvim_command("nohlsearch")
        if not MiniJump.state.jumping then return "<Esc>" end
        MiniJump.stop_jumping()
      end, { expr = true, desc = "Stop jumping" })
    end
  end,
}
