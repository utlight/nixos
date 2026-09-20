vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- NOTE: C Sharp
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function() vim.api.nvim_set_hl(0, "@lsp.type.string.cs", {}) end,
})
