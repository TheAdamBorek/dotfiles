local function make_telescope_results(harpoon_list)
  local file_paths = {}
  for i = 1, #harpoon_list.items do
    local item = harpoon_list.items[i]
    if not (item == nil or item == vim.NIL) then
      table.insert(file_paths, item.value)
    end
  end
  return require('telescope.finders').new_table {
    results = file_paths,
  }
end

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

    local function toggle_telescope()
      local harpoon_list = harpoon:list()
      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = make_telescope_results(harpoon_list),
          previewer = telescopeConfig.file_previewer {},
          sorter = telescopeConfig.generic_sorter {},
          attach_mappings = function(prompt_buffer_number, map)
            map('i', '<C-r>', function()
              local state = require 'telescope.actions.state'
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_buffer_number)

              local harpoon_item, item_index = harpoon_list:get_by_value(selected_entry.value)
              if not (harpoon_item == nil or item_index == nil or item_index == -1) then
                -- Fix for https://github.com/ThePrimeagen/harpoon/issues/627
                table.remove(harpoon:list().items, item_index)
                local new_telescope_items = make_telescope_results(harpoon_list)

                current_picker:refresh(new_telescope_items)
              end
            end)

            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hl', function()
      toggle_telescope()
    end, { desc = 'Open harpoon [l]ist' })
  end,
}
