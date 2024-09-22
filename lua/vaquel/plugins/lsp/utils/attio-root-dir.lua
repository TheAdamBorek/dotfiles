--- @param lsp_name string
return function(lsp_name)
  --- @param filepath string
  --- @return string
  return function(filepath)
    local default_config = require('lspconfig.server_configurations.' .. lsp_name)
    local utils = require 'lspconfig.util'
    if string.match(filepath, 'attio/Phoenix') then
      return utils.root_pattern '.git'(filepath)
    else
      return default_config.root_dir(filepath)
    end
  end
end
