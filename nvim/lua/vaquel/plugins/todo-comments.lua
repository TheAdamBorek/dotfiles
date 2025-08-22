return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    keywords = {
      TODO_ADAM = { icon = ' ', color = 'info', alt = { 'TODO FOR ADAM', 'TODO for Adam', 'TODO Adam' } },
    },
  },
}
