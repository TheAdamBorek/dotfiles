return {
  'sindrets/diffview.nvim',
  opts = {
    default_args = {
      DiffviewOpen = { '--imply-local' },
    },
  },
  keys = {
    { '<leader>gq', mode = { 'n' }, '<cmd>DiffviewClose<CR>', desc = 'Close DiffView' },
    { '<leader>gd', mode = { 'n' }, '<cmd>DiffviewOpen<CR>', desc = 'Open [D]iffView' },
    { '<leader>gf', mode = { 'n' }, '<cmd>DiffviewFileHistory %<CR>', desc = 'Open Git [f]ile history' },
  },
}
