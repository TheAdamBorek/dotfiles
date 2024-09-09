return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    modes = {
      jump = {
        autojump = true,
      },
      search = {
        enabled = true,
      },
      char = { -- Mode for 'f' and 'F'
        jump_labels = true,
        autohide = true,
      },
    },
  },
  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash',
    },
    {
      'S',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash Treesitter',
    },
    {
      'r',
      mode = 'o',
      function()
        require('flash').remote()
      end,
      desc = 'Remote Flash',
    },
    {
      'R',
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
