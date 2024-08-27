return {
  'vim-test/vim-test',
  lazy = false,
  dependencies = {
    'preservim/vimux',
  },
  keys = {
    vim.keymap.set('n', '<leader>tn', '<cmd>TestNearest<CR>'),
    vim.keymap.set('n', '<leader>tf', '<cmd>TestFile<CR>'),
    vim.keymap.set('n', '<leader>ts', '<cmd>TestSuite<CR>'),
    vim.keymap.set('n', '<leader>tl', '<cmd>TestLast<CR>'),
    -- vim.keymap.set('n', '<leader>g', ':TestVisit<CR>'),
  },
  opt = {},
  config = function()
    vim.cmd 'let test#strategy = "vimux"'
  end,
}
