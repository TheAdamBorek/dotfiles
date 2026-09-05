return {
  'ThePrimeagen/harpoon',
  enabled = false, -- I've stopped using it. Trying out using global marks instead
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim', 'folke/which-key.nvim' },
  opts = {
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
    },
  },
  config = function(_, opts)
    local harpoon = require 'harpoon'
    local whichKey = require 'which-key'

    harpoon:setup(opts)

    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = '[A]dd file to harpoon' })
    vim.keymap.set('n', '<leader>hc', function()
      harpoon:list():clear()
    end, { desc = '[C]lears harpoon list' })

    -- Helper functions to reduce repetition
    local function setup_harpoon_select_keys(harpoon, prefix, count)
      for i = 1, count do
        local ordinal = (i == 1 and '1st') or (i == 2 and '2nd') or (i == 3 and '3rd') or (i .. 'th')
        vim.keymap.set('n', prefix .. i % 10, function()
          harpoon:list():select(i)
        end, { desc = 'Opens ' .. ordinal .. ' harpooned file' })
      end
    end

    local function setup_harpoon_replace_keys(harpoon, prefix, count)
      for i = 1, count do
        local ordinal = (i == 1 and '1st') or (i == 2 and '2nd') or (i == 3 and '3rd') or (i .. 'th')
        vim.keymap.set('n', prefix .. i % 10, function()
          harpoon:list():replace_at(i)
        end, { desc = 'Replace ' .. ordinal .. ' harpooned file' })
      end
    end

    -- Setup numeric shortcuts for selecting files
    setup_harpoon_select_keys(harpoon, '<leader>', 10)
    setup_harpoon_select_keys(harpoon, '<leader>h', 10)

    -- Setup shortcuts for replacing files
    setup_harpoon_replace_keys(harpoon, '<leader>hr', 10)

    whichKey.add {
      { '<leader>hr', group = '[R]eplace' },
    }

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set('n', '<leader>hp', function()
      harpoon:list():prev()
    end, { desc = 'Selects previous harpooned file' })
    vim.keymap.set('n', '<leader>hn', function()
      harpoon:list():next()
    end, { desc = 'Selects next harpooned file' })

    vim.keymap.set('n', '<leader>hl', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Open harpoon [l]ist' })
  end,
}
