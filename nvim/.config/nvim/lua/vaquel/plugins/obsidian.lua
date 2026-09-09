return {
  'obsidian-nvim/obsidian.nvim',
  enabled = false,
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = 'SlipBox',
        path = '/Users/adamborek/Documents/SlipBox',
      },
      {
        name = 'Documents',
        path = '/Users/adamborek/Library/Mobile Documents/iCloud~md~obsidian/Documents',
      },
    },
    new_notes_location = 'current_dir',
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    templates = {
      folder = 'Templates',
    },
  },
}
