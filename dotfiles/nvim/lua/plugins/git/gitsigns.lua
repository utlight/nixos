return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup()

    local gitsigns = require("gitsigns.actions")
    vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "[P]review Hunk" })
    vim.keymap.set("n", "<leader>gs", gitsigns.stage_hunk, { desc = "[S]tage Hunk" })
    vim.keymap.set("n", "<leader>gS", gitsigns.stage_buffer, { desc = "[S]tage Buffer" })
    vim.keymap.set("n", "<leader>gr", gitsigns.reset_hunk, { desc = "[R]eset Hunk" })
    vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "[B]lame Line" })

    vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "[H]unk" })

    vim.keymap.set("n", "<leader>gn", function()
      gitsigns.nav_hunk("next", nil, function()
        gitsigns.preview_hunk_inline()
        vim.cmd.normal({ "zz", bang = true })
      end)
    end, { desc = "[N]ext Hunk" })

    vim.keymap.set("n", "<leader>gN", function()
      gitsigns.nav_hunk("prev", nil, function()
        gitsigns.preview_hunk_inline()
        vim.cmd.normal({ "zz", bang = true })
      end)
    end, { desc = "[P]revious Hunk" })
  end,
}
