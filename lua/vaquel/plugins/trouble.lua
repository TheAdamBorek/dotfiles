return {
  'folke/trouble.nvim',
  enabled = false,
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/todo-comments.nvim', 'folke/which-key.nvim' },
  opts = {
    focus = true,
  },
  cmd = 'Trouble',
  init = function()
    require('which-key').add { '<leader>T', group = '[T]rouble' }
  end,
  keys = {
    { '<leader>Tw', '<cmd>Trouble diagnostics toggle<CR>', desc = 'Open trouble workspace diagnostics' },
    { '<leader>Td', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'Open trouble document diagnostics' },
    { '<leader>Tl', '<cmd>Trouble loclist toggle<CR>', desc = 'Open trouble location list' },
  },
}
