return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  keys = {
    { 'x', '<leader>re', ':Refactor extract ' },
    { 'x', '<leader>rf', ':Refactor extract_to_file ' },

    { 'x', '<leader>rv', ':Refactor extract_var ' },

    { { 'n', 'x' }, '<leader>ri', ':Refactor inline_var' },

    { 'n', '<leader>rI', ':Refactor inline_func' },

    { 'n', '<leader>rb', ':Refactor extract_block' },
    { 'n', '<leader>rbf', ':Refactor extract_block_to_file' },
  },
  opts = {},
}
