-- Trim leading and trailing whitespace (spaces, tabs, newlines, etc.)
---@param s string
---@return string
---@diagnostic disable-next-line: lowercase-global
local function trim(s)
  -- %s* matches zero or more whitespace at start/end
  -- (.-) captures the middle content (non-greedy)
  return (s:gsub('^%s*(.-)%s*$', '%1'))
end

return trim
