vim.api.nvim_create_user_command('VSCodeOpenIn', '!code . && code -g %', {})

-- Copy relative path to clipboard
vim.api.nvim_create_user_command('PathRelativeCopy', function()
  local path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})
