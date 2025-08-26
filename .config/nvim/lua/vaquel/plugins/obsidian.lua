return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    workspaces = {
      {
        name = 'SlipBox',
        path = '/Users/adamborek/Documents/SlipBox',
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
      ['<CR>'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true },
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
    ui = {
      checkboxes = {
        [' '] = { order = 1, char = '󰄱', hl_group = 'ObsidianTodo' },
        ['x'] = { order = 2, char = '', hl_group = 'ObsidianDone' },
        -- ['>'] = { order = 3, char = '', hl_group = 'ObsidianRightArrow' },
        -- ['~'] = { order = 4, char = '󰰱', hl_group = 'ObsidianTilde' },
        -- ['!'] = { order = 5, char = '', hl_group = 'ObsidianImportant' },
      },
    },
  },
  config = function(_, opts)
    require('obsidian').setup(opts)
    vim.opt.conceallevel = 2
  end,
}
