return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")

      if ok then capabilities = cmp_lsp.default_capabilities(capabilities) end

      vim.lsp.config("*", { capabilities = capabilities })

      local servers = {}
      local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
      for name, ftype in vim.fs.dir(lsp_dir) do
        if ftype == "file" and name:match("%.lua$") then table.insert(servers, (name:gsub("%.lua$", ""))) end
      end
      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local builtin = require("telescope.builtin")

          vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
          vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementations" })
          vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })

          vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { buffer = buf, desc = "[G]oto Code [A]ction" })
          vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = buf, desc = "[R]e[n]ame" })
          vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { buffer = buf, desc = "[G]oto Code [A]ction" })

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight", args.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = args.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = args.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event.buf })
              end,
            })
          end

          if client and client:supports_method("textDocument/inlayHint", args.buf) then
            vim.keymap.set(
              "n",
              "<leader>uh",
              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })) end,
              { desc = "Inlay [H]ints" }
            )
          end
        end,
      })
    end,
  },
}
