return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  -- optional for floating window border decoration
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { '<leader>gt', '<cmd>LazyGit<cr>', desc = 'Open LazyGit [t]ree' },
    -- { '<leader>gf', '<cmd>LazyGitFilterCurrentFile<cr>', desc = 'Open current [b]uffer git history' },
  },
}
