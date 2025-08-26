local M = {}

--- @param cwd string
--- @param patterns string[]
M.does_eslint_config_exists = function(cwd, patterns)
  local eslint_config_exists = false
  for _, file in ipairs(patterns) do
    local config_file = cwd .. '/' .. file
    if vim.fn.filereadable(config_file) == 1 then
      eslint_config_exists = true
      break
    end
  end

  return eslint_config_exists
end

return M
