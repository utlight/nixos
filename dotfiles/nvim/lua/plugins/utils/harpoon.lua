return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>hX", function() harpoon:list():clear() end, { desc = "[H]arpoon Clear" })

    vim.keymap.set("n", "<leader>hA", function() harpoon:list():replace_at(1) end, { desc = "[H]arpoon Set 1" })
    vim.keymap.set("n", "<leader>hS", function() harpoon:list():replace_at(2) end, { desc = "[H]arpoon Set 2" })
    vim.keymap.set("n", "<leader>hD", function() harpoon:list():replace_at(3) end, { desc = "[H]arpoon Set 3" })
    vim.keymap.set("n", "<leader>hF", function() harpoon:list():replace_at(4) end, { desc = "[H]arpoon Set 4" })

    vim.keymap.set("n", "<leader>ha", function() harpoon:list():select(1) end, { desc = "[H]arpoon 1" })
    vim.keymap.set("n", "<leader>hs", function() harpoon:list():select(2) end, { desc = "[H]arpoon 2" })
    vim.keymap.set("n", "<leader>hd", function() harpoon:list():select(3) end, { desc = "[H]arpoon 3" })
    vim.keymap.set("n", "<leader>hf", function() harpoon:list():select(4) end, { desc = "[H]arpoon 4" })

    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    vim.keymap.set("n", "<leader>hl", function() toggle_telescope(harpoon:list()) end, { desc = "[H]arpoon [L]ist" })
  end,
}
