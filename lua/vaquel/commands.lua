vim.api.nvim_create_user_command('VSCodeOpenIn', '!code . && code -g %', {})

-- Copy relative path to clipboard
vim.api.nvim_create_user_command('PathRelativeCopy', function()
  local path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, {})

-- Regex to edit icons
vim.api.nvim_create_user_command('AttioIconsRegex', function()
  vim.cmd [[silent! %s/stroke="#\?\w*"/stroke="var(--color)"/g | silent! %s/fill="[^none|white]#\?\w*"/fill="var(--color)"/g]]
end, {})
