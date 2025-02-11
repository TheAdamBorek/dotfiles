------------------------------------------------------------------------------
-- 1) Utility to get selected text
------------------------------------------------------------------------------
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

  -- Include the last character
  ecol = ecol + 1

  local lines = vim.api.nvim_buf_get_text(0, srow, scol, erow, ecol, {})
  return srow, scol, erow, ecol, lines
end

------------------------------------------------------------------------------
-- 2) Detect the input format: snake_case, kebab-case, or camelCase
------------------------------------------------------------------------------
local function detect_format(text)
  if text:find '_' then
    return 'snake'
  elseif text:find '-' then
    return 'kebab'
  else
    return 'camel' -- default assumption
  end
end

------------------------------------------------------------------------------
-- 3) Convert the text to a list of words
------------------------------------------------------------------------------
local function to_words(text, fmt)
  if fmt == 'snake' then
    return vim.split(text, '_', { plain = true })
  elseif fmt == 'kebab' then
    return vim.split(text, '-', { plain = true })
  else
    -- camelCase
    -- Insert a space between lowercase/number and uppercase letter,
    -- then split on whitespace
    text = text:gsub('([a-z0-9])([A-Z])', '%1 %2')
    local words = {}
    for w in text:gmatch '%S+' do
      table.insert(words, w:lower())
    end
    return words
  end
end

------------------------------------------------------------------------------
-- 4) Functions to rebuild words into the target format
------------------------------------------------------------------------------
local function words_to_snake(words)
  return table.concat(words, '_'):lower()
end

local function words_to_camel(words)
  -- First word all lowercase, subsequent words capitalized on the first letter
  local result = {}
  for i, w in ipairs(words) do
    if i == 1 then
      table.insert(result, w:lower())
    else
      table.insert(result, w:sub(1, 1):upper() .. w:sub(2):lower())
    end
  end
  return table.concat(result, '')
end

local function words_to_kebab(words)
  return table.concat(words, '-'):lower()
end

------------------------------------------------------------------------------
-- 5) Generic transform function
------------------------------------------------------------------------------
local function transform_selection(mode, target)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local srow, scol, erow, ecol, lines = getSelectedText(mode)

  local original_text = table.concat(lines, '\n')
  local fmt = detect_format(original_text)
  local words = to_words(original_text, fmt)

  local new_text
  if target == 'snake' then
    new_text = words_to_snake(words)
  elseif target == 'camel' then
    new_text = words_to_camel(words)
  elseif target == 'kebab' then
    new_text = words_to_kebab(words)
  else
    -- fallback to original
    new_text = original_text
  end

  -- Replace text
  vim.api.nvim_buf_set_text(0, srow, scol, erow, ecol, { new_text })
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

------------------------------------------------------------------------------
-- 6) Operator functions for each target format
------------------------------------------------------------------------------
function ConvertToSnakeOperator(mode)
  transform_selection(mode, 'snake')
end

function ConvertToCamelOperator(mode)
  transform_selection(mode, 'camel')
end

function ConvertToKebabOperator(mode)
  transform_selection(mode, 'kebab')
end

------------------------------------------------------------------------------
-- 7) Key mappings (example)
------------------------------------------------------------------------------
-- Convert to snake_case
vim.keymap.set('n', 'gss', function()
  vim.go.operatorfunc = 'v:lua.ConvertToSnakeOperator'
  return 'g@'
end, { expr = true, desc = 'Convert motion to snake_case' })

vim.keymap.set('v', 'gss', function()
  ConvertToSnakeOperator 'visual'
end, { desc = 'Convert selection to snake_case (visual)' })

-- Convert to camelCase
vim.keymap.set('n', 'gsc', function()
  vim.go.operatorfunc = 'v:lua.ConvertToCamelOperator'
  return 'g@'
end, { expr = true, desc = 'Convert motion to camelCase' })

vim.keymap.set('v', 'gsc', function()
  ConvertToCamelOperator 'visual'
end, { desc = 'Convert selection to camelCase (visual)' })

-- Convert to kebab-case
vim.keymap.set('n', 'gsk', function()
  vim.go.operatorfunc = 'v:lua.ConvertToKebabOperator'
  return 'g@'
end, { expr = true, desc = 'Convert motion to kebab-case' })

vim.keymap.set('v', 'gsk', function()
  ConvertToKebabOperator 'visual'
end, { desc = 'Convert selection to kebab-case (visual)' })
