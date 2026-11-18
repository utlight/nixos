vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Write and Quit" })
vim.keymap.set("n", "<leader>qr", "<cmd>restart<cr>", { desc = "Restart" })

vim.keymap.set({ "n", "o" }, "U", function()
  vim.fn.setreg("/", [[\%.l\u]])
  vim.o.hlsearch = true
end, { silent = true })
