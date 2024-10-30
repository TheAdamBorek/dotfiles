-- Helper function to build the range and get the selected text
local function getSelectedText(mode)
  local srow, scol, erow, ecol

  if mode == 'visual' then
    srow = vim.fn.line "'<" - 1
    scol = vim.fn.col "'<" - 1
    erow = vim.fn.line "'>" - 1
    ecol = vim.fn.col "'>" - 1
  else
    srow = vim.fn.line "'[" - 1
    scol = vim.fn.col "'[" - 1
    erow = vim.fn.line "']" - 1
    ecol = vim.fn.col "']" - 1
  end

  -- Adjust the end column to include the last character
  ecol = ecol + 1

  -- Get the selected text
  local lines = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})
  return srow, scol, erow, ecol, lines
end

-- Function to perform the CamelCase to kebab-case transformation
function CamelToKebabOperator(mode)
  -- Save the current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the selected text and positions
  local srow, scol, erow, ecol, lines = getSelectedText(mode)

  -- Join the lines into a single string
  local text = table.concat(lines, '\n')

  -- Perform the transformation
  local new_text = text
    -- Insert hyphens between lowercase and uppercase letters
    :gsub('(%l)(%u)', '%1-%2')
    -- Insert hyphens between multiple uppercase letters followed by lowercase letters
    :gsub('(%u)(%u%l)', '%1-%2')
    -- Lowercase the entire string
    :lower()

  -- Replace the text in the buffer
  vim.api.nvim_buf_set_text(0, srow, scol, erow, ecol, vim.split(new_text, '\n'))

  -- Restore the cursor position
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

-- Function to perform the CamelCase to snake_case transformation
function CamelToSnakeOperator(mode)
  -- Save the current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Get the selected text and positions
  local srow, scol, erow, ecol, lines = getSelectedText(mode)

  -- Join the lines into a single string
  local text = table.concat(lines, '\n')

  -- Perform the transformation
  local new_text = text
    -- Insert underscores between lowercase and uppercase letters
    :gsub('(%l)(%u)', '%1_%2')
    -- Insert underscores between multiple uppercase letters followed by lowercase letters
    :gsub('(%u)(%u%l)', '%1_%2')
    -- Lowercase the entire string
    :lower()

  -- Replace the text in the buffer
  vim.api.nvim_buf_set_text(0, srow, scol, erow, ecol, vim.split(new_text, '\n'))

  -- Restore the cursor position
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

-- Map 'gk' in normal mode as an operator
vim.keymap.set('n', 'gk', function()
  vim.go.operatorfunc = 'v:lua.CamelToKebabOperator'
  return 'g@'
end, { expr = true, desc = 'Convert CamelCase to kebab-case over a motion' })

-- Map 'gk' in visual mode
vim.keymap.set('v', 'gk', function()
  CamelToKebabOperator 'visual'
end, { desc = 'Convert CamelCase to kebab-case in visual mode' })

vim.keymap.set('n', 'gs', function()
  vim.go.operatorfunc = 'v:lua.CamelToSnakeOperator'
  return 'g@'
end, { expr = true, desc = 'Convert CamelCase to snake_case over a motion' })

vim.keymap.set('v', 'gs', function()
  CamelToSnakeOperator 'visual'
end, { desc = 'Convert CamelCase to snake_case in visual mode' })
