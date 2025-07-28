return {
  'folke/todo-comments.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    keywords = {
      TODO_ADAM = { icon = ' ', color = 'info', alt = { 'TODO FOR ADAM', 'TODO for Adam', 'TODO Adam' } },
    },
  },
  keys = {
    {
      '<leader>tt',
      function()
        local todoComments = require 'todo-comments.search'
        todoComments.setqflist {
          keywords = 'TODO_ADAM',
        }
      end,
      desc = 'Puts my [t]odos to quickfix list',
    },
    -- {
    --   ']t',
    --   function()
    --     require('todo-comments').jump_next { keywords = { 'TODO_ADAM' } }
    --   end,
    --   { desc = 'Next todo comment' },
    -- },
    -- {
    --   '[t',
    --   function()
    --     require('todo-comments').jump_prev { keywords = { 'TODO_ADAM' } }
    --   end,
    --   { desc = 'Previous todo comment' },
    -- },
  },
}
