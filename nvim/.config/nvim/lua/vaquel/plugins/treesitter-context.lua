return {
  'nvim-treesitter/nvim-treesitter-context',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    max_lines = 3,
    mode = 'cursor',
  },
  keys = {
    { '<leader>ut', function() require('treesitter-context').toggle() end, desc = 'Toggle treesitter context' },
  },
}
