return {
  "dlyongemallo/diffview-plus.nvim",
  version = "*",
  config = function()
    local actions = require("diffview.actions")

    require("diffview").setup({
      enhanced_diff_hl = true,
      show_root_path = false,
      view = {
        default = { focus_diff = true },
        merge_tool = { layout = "diff3_mixed", focus_diff = true },
      },
      file_panel = { show = false },
      keymaps = {
        disable_defaults = true,
        diff3 = {
          { "n", "<leader>go", actions.diffget("ours"), { desc = "[O]urs Hunk" } },
          { "n", "<leader>gt", actions.diffget("theirs"), { desc = "[T]heirs Hunk" } },
          { "n", "<leader>ga", actions.conflict_choose("all"), { desc = "[A]ll Hunks" } },
        },
      },
    })

    vim.keymap.set("n", "<leader>gg", require("diffview").toggle, { desc = "[D]iff" })
  end,
}
