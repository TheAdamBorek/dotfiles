return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    keywords = {
      TODO_FOR_ADAM = { icon = ' ', color = 'info' },
    },
  },
  keys = {
    {
      '<leader>Tq',
      function()
        local todoComments = require 'todo-comments.search'
        todoComments.setqflist {
          keywords = 'TODO_FOR_ADAM',
        }
      end,
      desc = 'Puts my todos to [q]uickfix list',
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
