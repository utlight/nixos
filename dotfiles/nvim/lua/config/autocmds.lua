vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- NOTE: C Sharp
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function() vim.api.nvim_set_hl(0, "@lsp.type.string.cs", {}) end,
})

-- NOTE: Markdown
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown-settings", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.colorcolumn = ""
    vim.opt_local.relativenumber = false
  end,
})
