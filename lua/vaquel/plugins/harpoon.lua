return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    local telescopeConfig = require('telescope.config').values

    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = '[A]dd file to harpoon' })
    vim.keymap.set('n', '<leader>hd', function()
      harpoon:list():remove()
    end, { desc = '[D]elete the file from harpoon' })

    vim.keymap.set('n', '<C-m>', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<C-,>', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<C-.>', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<C-/>', function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<leader>hn', function()harp
      harpoon:list():next()
    end)

    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = telescopeConfig.file_previewer {},
          sorter = telescopeConfig.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hl', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon [l]ist' })
  end,
}
