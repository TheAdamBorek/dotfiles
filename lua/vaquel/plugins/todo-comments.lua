return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    keywords = {
      TODO_FOR_ADAM = { icon = ' ', color = 'info', alt = { 'TODO FOR ADAM', 'TODO for Adam', 'TODO ADAM', 'TODO Adam' } },
    },
  },
  keys = {
    {
      '<leader>ct',
      function()
        local todoComments = require 'todo-comments.search'
        todoComments.setqflist {
          keywords = 'TODO_FOR_ADAM',
        }
      end,
      desc = 'Puts my [t]odos to quickfix list',
    },
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      { desc = 'Next todo comment' },
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      { desc = 'Previous todo comment' },
    },
  },
}
