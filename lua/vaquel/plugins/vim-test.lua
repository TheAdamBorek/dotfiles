return {
  'vim-test/vim-test',
  lazy = false,
  enabled = false,
  dependencies = {
    'preservim/vimux',
    'folke/which-key.nvim',
  },
  keys = {
    vim.keymap.set('n', '<leader>Tn', '<cmd>TestNearest<CR>'),
    vim.keymap.set('n', '<leader>Tf', '<cmd>TestFile<CR>'),
    vim.keymap.set('n', '<leader>Ts', '<cmd>TestSuite<CR>'),
    vim.keymap.set('n', '<leader>Tl', '<cmd>TestLast<CR>'),
  },
  opt = {},
  config = function(_, opts)
    vim.cmd 'let test#strategy = "vimux"'
  end,
}
