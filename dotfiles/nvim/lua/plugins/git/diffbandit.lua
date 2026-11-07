return {
  "CoreyKaylor/diffbandit.nvim",
  config = function()
    require("diffbandit").setup({
      actions = {
        keys = {
          toggle_stage = "<leader>gs",
        },
      },
      merge = {
        auto_apply_non_conflicting = true,
      },
    })

    local diffbandit = require("diffbandit")

    vim.keymap.set(
      "n",
      "<leader>gf",
      function() diffbandit.git_file(vim.api.nvim_buf_get_name(0)) end,
      { desc = "Git Diff File" }
    )

    vim.keymap.set("n", "<leader>gg", diffbandit.git_panel, { desc = "Diff All" })
  end,
}
