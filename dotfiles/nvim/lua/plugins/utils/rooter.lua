return {
  "wsdjeg/rooter.nvim",
  lazy = false,
  config = function()
    require("rooter").setup({
      root_patterns = { ".git/", "cargo.toml", ".sln", ".gitconfig" },
      outermost = false,
      command = "tcd",
      trigger_dir_changed = true,
      exclude_patterns = { "^neo%-tree" },
    })
  end,
}
