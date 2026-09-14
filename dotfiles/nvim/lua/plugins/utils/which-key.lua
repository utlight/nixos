return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        delay = 0,
        icons = { mappings = true },
        spec = {
            { "<leader>f", group = "[F]ind", mode = { "n", "v" } },
            { "<leader>u", group = "[U]tils", mode = { "n", "v" } },
            { "gr", group = "Lsp Actions", mode = { "n" } },
            { "g", group = "[G]it", mode = { "n", "v" } },
        },
    },
}
