return {
  'epwalsh/obsidian.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = "/Users/adamborek/Documents/Adam's Obsidian Vault",
      },
    },
    mappings = {
      ['gf'] = {
        action = function()
          return require('obsidian').util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ['<leader>oc'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true, desc = 'Toggle [c]heckbox' },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ['<leader>os'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true, desc = '[S]mart actions' },
      },
    },
    new_notes_location = '0. Inbox',
  },
}
