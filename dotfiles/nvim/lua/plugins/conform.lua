return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      default_format_opts = { lsp_format = "fallback" },
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        nix = { "alejandra" },
        zsh = { "shfmt" },
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>uf", function() require("conform").format() end, { desc = "[F]ormat buffer" })
  end,
}
