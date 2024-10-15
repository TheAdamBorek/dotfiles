return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'folke/which-key.nvim' },
  event = 'BufEnter',
  keys = {
    { '<leader>re', ':Refactor extract ', mode = { 'v' }, desc = 'Extract' },
    { '<leader>rf', ':Refactor extract_to_file ', mode = { 'v' }, desc = 'Extract to a file' },
    { '<leader>rv', ':Refactor extract_var ', mode = { 'v' }, desc = 'Extract var' },
    { '<leader>ri', ':Refactor inline_var', mode = { 'n', 'v' }, desc = 'Inline var' },
    { '<leader>rI', ':Refactor inline_func', mode = { 'n' }, desc = 'inline func' },
    { '<leader>rb', ':Refactor extract_block_to_file', mode = { 'n' }, desc = 'Extract block to a file' },
    -- stylua: ignore
    { '<leader>rl', function() require('refactoring').debug.printf { below = false } end, mode = {'n', 'v'}, desc = '[L]og message' },
    -- stylua: ignore
    { '<leader>rp', function() require('refactoring').debug.print_var({}) end, mode = { 'n'},  desc = '[P]rint var' },
    -- stylua: ignore
    { '<leader>rc', function() require('refactoring').debug.cleanup({}) end, mode = { 'n'},  desc = 'Clean debug print & logs' },
  },
  opts = {},
  config = function(_, opts)
    require('which-key').add {
      { '<leader>r', group = '[R]efector' },
    }

    require('refactoring').setup(opts)
  end,
}
