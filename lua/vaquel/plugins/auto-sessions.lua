return {
  'rmagatti/auto-session',
  opts = {
    auto_session_suppress_dirs = { '~/', '~/Developer/', '~/Downloads', '~/Documents', '~/Desktop/' },
  },
  keys = {
    { '<leader>wr', '<cmd>SessionRestore<CR>', { desc = 'Restore session for cwd' } },
    { '<leader>ws', '<cmd>SessionSave<CR>', { desc = 'Save session for auto session root dir' } },
  },
}
