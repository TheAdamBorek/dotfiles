return {
  enabled = true,
  'sindrets/diffview.nvim',
  lazy = false,
  opts = {
    default_args = {
      DiffviewOpen = { '--imply-local' },
    },
  },
  keys = {
    { '<leader>gdq', mode = { 'n' }, '<cmd>DiffviewClose<CR>', desc = '[G]it [D]iffView [q]uit' },
    { '<leader>gdc', mode = { 'n' }, '<cmd>DiffviewOpen<CR>', desc = '[G]it Open [D]iffView [c]hanged' },
    { '<leader>gdm', mode = { 'n' }, '<cmd>DiffviewOpen master..HEAD<CR>', desc = '[G]it Open [D]iffView [m]aster' },
    { '<leader>gdh', mode = { 'n' }, '<cmd>DiffviewFileHistory % --first-parent --grep=".*pull request.*"<CR>', desc = 'Open Git file [h]istory' },
  },
}
