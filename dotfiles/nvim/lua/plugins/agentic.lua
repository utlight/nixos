return {
  "carlos-algms/agentic.nvim",
  -- dependencies = {
  --   {
  --     "MeanderingProgrammer/render-markdown.nvim",
  --     dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  --     opts = { file_types = { "markdown", "md", "AgenticChat" } },
  --   },
  -- },
  init = function() require("config.dsh_sessions").setup() end,
  config = function()
    local agentic = require("agentic")

    agentic.setup({
      provider = "deepseek-acp",
      acp_providers = {
        ["deepseek-acp"] = {
          name = "DeepSeek ACP",
          command = "/etc/profiles/per-user/utlight/bin/dsh",
          args = { "--profile", "nix-acp" },
          env = {
            DSH_ACP_STREAM_DELTAS = "false",
          },
        },
      },
      keymaps = {
        widget = {
          change_mode = "<localLeader>am",
          change_thought_level = "<localLeader>at",
          open_options = "<localLeader>ao",
          destroy_session = "noop",
          next_session = "noop",
          prev_session = "noop",
          switch_provider = "noop",
          select_session = "noop",
          switch_model = "noop",
        },
        prompt = {
          paste_image = "<localLeader>ap",
        },
      },
      folding = { tool_calls = { threshold = 0 } },
      windows = { width = "35%" },
      headers = {
        chat = function(parts, session_state)
          local header = ""

          if session_state then
            local provider_name = session_state:get_provider_name()
            if provider_name then header = header .. provider_name end

            if parts.context then header = header .. " | " .. parts.context end

            local thought_level = session_state:get_thought_level_name()
            if thought_level then header = header .. " | Thought Effort: " .. thought_level end

            local used = session_state:get_context_used()
            local size = session_state:get_context_size()
            if used and size then header = header .. " | " .. used .. "/" .. size end
          end
          return header
        end,
        input = function(parts) return parts.title end,
      },
    })

    vim.keymap.set("n", "<leader>as", require("config.dsh_sessions").picker, { desc = "DSH sessions" })
    vim.keymap.set(
      "n",
      "<leader>an",
      function() agentic.toggle({ focus_prompt = false, auto_add_to_context = false }) end,
      { desc = "Toggle Agentic" }
    )

    vim.keymap.set(
      "n",
      "<leader>ae",
      function() agentic.open({ focus_prompt = true, auto_add_to_context = false }) end,
      { desc = "Focus Agentic" }
    )
  end,
}
