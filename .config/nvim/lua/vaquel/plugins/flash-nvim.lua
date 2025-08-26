return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    modes = {
      jump = {
        autojump = true,
      },
      search = {
        enabled = false,
      },
      char = { -- Mode for 'f' and 'F'
        enabled = false,
        multi_line = false,
        autojump = true,
        label = { exclude = 'g' },
        jump_labels = false,
      },
    },
  },
  keys = {
    {
      '<leader>ss',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      '<leader>sS',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      '<leader>sr',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      '<leader>sR',
      mode = { 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Treesitter Search',
    },
    {
      '<c-s>',
      mode = { 'c' },
      function()
        require('flash').toggle()
      end,
      desc = 'Toggle Flash Search',
    },
  },
  config = function(_, opts)
    local flash = require 'flash'
    flash.setup(opts)
  end,
}
