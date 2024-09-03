local M = {}

M.apply = function()
  vim.keymap.set('n', '<leader>dl', '<cmd>EslintFixAll<CR><cmd>w<CR>', { desc = 'Fix all ES[L]int problems' })
end

return M
