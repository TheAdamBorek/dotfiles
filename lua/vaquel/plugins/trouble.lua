return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/todo-comments.nvim', 'folke/which-key.nvim' },
  opts = {
    focus = true,
  },
  cmd = 'Trouble',
  config = function(_, opts)
    require('which-key').add { '<leader>t', group = '[t]rouble' }
    require('trouble').setup(opts)
  end,
  keys = {
    { '<leader>tw', '<cmd>Trouble diagnostics toggle<CR>', desc = 'Open trouble workspace diagnostics' },
    { '<leader>td', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Open trouble document diagnostics' },
    { '<leader>tl', '<cmd>Trouble loclist toggle<CR>', desc = 'Open trouble location list' },
  },
}
