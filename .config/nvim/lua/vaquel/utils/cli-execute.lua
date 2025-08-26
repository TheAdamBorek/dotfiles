--- @param command string
local function cli_command(command)
  local trim = require 'vaquel.utils.trim'
  local handle = io.popen(command)
  if not handle then
    error('Failed to execute command: ' .. command)
  end
  local output = handle:read '*a'
  handle:close()

  return trim(output)
end

return cli_command
