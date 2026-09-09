local load_nx_errors_to_qf = require 'vaquel.load-nx-errors-to-qf-list'

vim.api.nvim_create_user_command('VSCodeOpenIn', '!code . && code -g %', {})
vim.api.nvim_create_user_command('CursorOpenIn', '!cursor . && cursor -g %', {})

-- Copy relative path to clipboard (normal mode), or path with line range and selected text (visual mode)
vim.api.nvim_create_user_command('PathRelativeCopy', function(opts)
  local path = vim.fn.fnamemodify(vim.fn.expand '%', ':.')
  if opts.range > 0 then
    local result = path .. ':' .. opts.line1 .. '-' .. opts.line2
    vim.fn.setreg('+', result)
    vim.notify('Copied "' .. result .. '" to the clipboard!')
  else
    vim.fn.setreg('+', path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end
end, { range = true })

-- Regex to edit icons
vim.api.nvim_create_user_command('AttioIconsRegex', function()
  vim.cmd [[silent! %s/stroke="#\?\w*"/stroke="var(--color)"/g | silent! %s/fill="[^none|white]#\?\w*"/fill="var(--color)"/g]]
end, { bar = true })

vim.api.nvim_create_user_command('NxReadErrors', function()
  load_nx_errors_to_qf()
end, { nargs = '?' })
