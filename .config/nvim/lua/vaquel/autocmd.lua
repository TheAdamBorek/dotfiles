-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Reload buffers when files change on disk (e.g. when Claude modifies files externally)
-- autoread alone doesn't detect changes; checktime forces Neovim to check file timestamps
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Reload buffers when file changed on disk',
  group = vim.api.nvim_create_augroup('vaquel-checktime', { clear = true }),
  command = 'checktime',
})

-- Update global marks when leaving buffer
vim.api.nvim_create_autocmd('BufLeave', {
  desc = 'Update global marks to current position when leaving buffer',
  group = vim.api.nvim_create_augroup('vaquel-update-global-marks', { clear = true }),
  callback = function(opts)
    local current_line = vim.fn.line '.'
    local current_col = vim.fn.col '.'

    -- Check all uppercase letters (global marks)
    for i = 65, 90 do -- ASCII A-Z
      local mark_char = string.char(i)
      local mark_pos = vim.fn.getpos("'" .. mark_char)

      -- mark_pos[1] is buffer number, mark_pos[2] is line, mark_pos[3] is column
      if mark_pos[1] == opts.buf then -- Mark exists
        vim.fn.setpos("'" .. mark_char, { opts.buf, current_line, current_col })
      end
    end
  end,
})
