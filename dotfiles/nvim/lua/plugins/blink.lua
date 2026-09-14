return {
  "saghen/blink.cmp",
  build = function()
    require("blink.cmp").build():pwait()
  end,
  dependencies = {
    "saghen/blink.lib",
    "xzbdmw/colorful-menu.nvim",
    {
      "saecki/crates.nvim",
      tag = "stable",
      config = function()
        require("crates").setup({
          lsp = {
            enabled = true,
            actions = true,
            completion = true,
            hover = true,
          },
        })
      end,
    },
  },
  opts = {
    signature = {
      enabled = true,
      window = { show_documentation = false, direction_priority = { "n" } },
    },
    completion = {
      menu = {
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
          },
        },
      },
    },
  },
}
