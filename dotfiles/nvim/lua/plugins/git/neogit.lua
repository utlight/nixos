return {
  "NeogitOrg/neogit",
  lazy = true,
  dependencies = {
    "m00qek/baleia.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" },
  },
  opts = {
    status = {
      mode_text = {
        M = "",
        N = "",
        A = "",
        D = "",
        C = "",
        R = "",
        DD = "",
        AU = "",
        UD = "",
        UA = "",
        DU = "",
        AA = "",
        UU = "",
      },
    },
  },
}
