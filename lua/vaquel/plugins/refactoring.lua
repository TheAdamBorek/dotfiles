return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'folke/which-key.nvim' },
  event = 'BufEnter',
  keys = {
    { '<leader>re', ':Refactor extract ', mode = { 'x' }, desc = 'Extract' },
    { '<leader>rf', ':Refactor extract_to_file ', mode = { 'x' }, desc = 'Extract to a file' },

    { '<leader>rv', ':Refactor extract_var ', mode = { 'x' }, desc = 'Extract var' },

    { '<leader>ri', ':Refactor inline_var', mode = { 'n', 'x' }, desc = 'Inline var' },

    { '<leader>rI', ':Refactor inline_func', mode = { 'n' }, desc = 'inline func' },

    { '<leader>rb', ':Refactor extract_block', mode = { 'n' }, desc = 'Extract bloc' },
    { '<leader>rbf', ':Refactor extract_block_to_file', mode = { 'n' }, desc = 'Extract block to a file' },
  },
  opts = {},
  config = function(_, opts)
    require('which-key').add {
      { '<leader>r', group = '[R]efector' },
    }

    require('refactoring').setup(opts)
  end,
}
