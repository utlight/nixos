return {
  "dlyongemallo/diffview-plus.nvim",
  version = "*",
  config = function()
    local actions = require("diffview.actions")
    require("diffview").setup({
      enhanced_diff_hl = true,
      status_icons = {
        ["A"] = "", -- Added   
        ["?"] = "", -- Untracked
        ["M"] = "", -- Modified
        ["R"] = "", -- Renamed
        ["C"] = "", -- Copied
        ["U"] = "", -- Unmerged
        ["D"] = "", -- Deleted
      },
      hooks = {
        diff_buf_win_enter = function(_, winid) vim.wo[winid].foldenable = false end,
      },
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_mixed", disable_diagnostics = false },
      },
      keymaps = {
        disable_defaults = true,
        view = {
          { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
          { "n", "<leader>n", actions.toggle_files, { desc = "Toggle the file panel." } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
        },
        file_panel = {
          { "n", "<leader>e", "<cmd>wincmd p<cr>", { desc = "Bring focus to the last diff panel" } },
          { "n", "<leader>n", actions.toggle_files, { desc = "Toggle the file panel." } },
          { "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
          { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
          { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
          { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
          { "n", "l", actions.open_fold, { desc = "Expand fold" } },
          { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
          { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
          { "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
          {
            "n",
            "<cr>",
            function()
              actions.select_entry()
              actions.focus_entry()
            end,
            { desc = "Open the diff for the selected entry" },
          },
        },
        file_history_panel = {
          { "n", "<leader>e", "<cmd>wincmd p<cr>", { desc = "Bring focus to the last diff panel" } },
          { "n", "<leader>n", actions.toggle_files, { desc = "Toggle the file panel." } },
          { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
          { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
          { "n", "l", actions.open_fold, { desc = "Expand fold" } },
          { "n", "l", actions.select_entry, { desc = "Expand fold" } },
          { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
          { "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
          { "n", "g!", actions.options, { desc = "Open the option panel" } },
          { "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
        },
        diff2 = {
          { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
        },
        diff3 = {
          { "n", "<<", actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
          { "n", ">>", actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
          { "n", "><", actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
          { "n", "<>", actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
          { "n", "g?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
        },
        commit_log_panel = {
          { "n", "q", actions.close, { desc = "Close commit log" } },
          { "n", "<esc>", actions.close, { desc = "Close commit log" } },
        },
        option_panel = {
          { "n", "<cr>", actions.select_entry, { desc = "Change the current option" } },
          { "n", "q", actions.close, { desc = "Close the panel" } },
          { "n", "<esc>", actions.close, { desc = "Close the panel" } },
          { "n", "g?", actions.help("option_panel"), { desc = "Open the help panel" } },
        },
        help_panel = {
          { "n", "q", actions.close, { desc = "Close help menu" } },
          { "n", "<esc>", actions.close, { desc = "Close help menu" } },
        },
      },
    })

    vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewToggle<cr>", { desc = "[Git] Diff" })
    vim.keymap.set("n", "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", { desc = "[Git] [F]ile History" })

    vim.opt.fillchars:append({ diff = "╱" })
  end,
}
