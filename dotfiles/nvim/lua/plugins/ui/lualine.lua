return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = { globalstatus = true, refresh = { statusline = 100 } },
      extensions = { "neo-tree", "quickfix" },
      sections = {
        lualine_a = {
          { "mode", separator = { left = "▎", right = "" } },
          { "", draw_empty = true, separator = { left = "", right = "" } },
        },
        lualine_b = {
          { "filetype", colored = true, icon_only = true, icon = { align = "left" } },
          { "filename", symbols = { modified = " ", readonly = " " }, separator = { right = "" } },
          { "", draw_empty = true, separator = { left = "", right = "" } },
        },
        lualine_c = {
          {
            "diff",
            colored = false,
            diff_color = { added = "DiffAdd", modified = "DiffChange", removed = "DiffDelete" },
            symbols = { added = "+", modified = "~", removed = "-" },
            separator = { right = "" },
          },
        },
        lualine_x = {
          {
            "lsp_status",
            icon = " ",
            ignore_lsp = { "stylua" },
            separator = { left = "" },
          },
          {
            "diagnostics",
            symbols = { error = "󰅙  ", warn = "  ", info = "  ", hint = "󰌵 " },
            colored = true,
            update_in_insert = false,
            always_visible = false,
            diagnostics_color = {
              color_error = { fg = "red" },
              color_warn = { fg = "yellow" },
              color_info = { fg = "cyan" },
            },
          },
        },
        lualine_y = {
          { "", draw_empty = true, separator = { left = "", right = "" } },
          { "branch", separator = { left = "" } },
        },
        lualine_z = {
          { "", draw_empty = true, separator = { left = "", right = "" } },
          { "location", separator = { left = "" } },
          { "fileformat", color = { fg = "black" }, symbols = { unix = "", dos = "", mac = "" } },
        },
      },
    })
  end,
}
