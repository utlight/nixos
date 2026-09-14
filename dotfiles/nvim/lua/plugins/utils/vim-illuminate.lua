return {
  "RRethy/vim-illuminate",
  config = function()
    require("illuminate").configure({
      providers = { "lsp" },
      disable_keymaps = true,
    })
  end,
}
