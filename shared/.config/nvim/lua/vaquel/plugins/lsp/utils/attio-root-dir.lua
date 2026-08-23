local M = {}

--- @param lsp_name string
M.attio_root_dir = function(lsp_name)
  --- @param filepath string
  --- @return string
  return function(filepath)
    local default_config = require('lspconfig.configs.' .. lsp_name).default_config
    local utils = require 'lspconfig.util'
    if string.match(filepath, 'job/attio/') then
      return utils.root_pattern '.git'(filepath)
    else
      return default_config.root_dir(filepath)
    end
  end
end

return M
