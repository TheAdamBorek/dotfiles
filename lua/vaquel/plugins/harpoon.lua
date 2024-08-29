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

    vim.keymap.set('n', '<leader>h1', function()
      harpoon:list():select(1)
    end)
    vim.keymap.set('n', '<leader>h2', function()
      harpoon:list():select(2)
    end)
    vim.keymap.set('n', '<leader>h3', function()
      harpoon:list():select(3)
    end)
    vim.keymap.set('n', '<leader>h4', function()
      harpoon:list():select(4)
    end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end)
    vim.keymap.set('n', '<leader>hn', function()
      harpoon:list():next()
    end)

    local function toggle_telescope(harpoon_files)
      local function make_telescope_results()
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end
        return require('telescope.finders').new_table {
          results = file_paths,
        }
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = make_telescope_results(),
          previewer = telescopeConfig.file_previewer {},
          sorter = telescopeConfig.generic_sorter {},
          attach_mappings = function(prompt_buffer_number, map)
            -- The keymap you need
            map('i', '<C-d>', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_buffer_number)

              harpoon:list():remove(selected_entry)
              current_picker:refresh(make_telescope_results())
            end)

            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hl', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Open harpoon [l]ist' })
  end,
}
