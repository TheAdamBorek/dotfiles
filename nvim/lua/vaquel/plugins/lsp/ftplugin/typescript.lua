local function styled_components_path()
  local npmRoot = string.gsub(vim.fn.system 'npm root -g', '\n', '')
  local styledComponentsPath = npmRoot .. '/@styled/typescript-styled-plugin'
  if vim.fn.isdirectory(styledComponentsPath) ~= 1 then
    vim.notify("Couldn't find styled-components plugin. Run `npm install -g @styled/typescript-styled-plugin`", 'error')
    return {}
  end

  return {
    name = '@styled/typescript-styled-plugin',
    location = styledComponentsPath,
    languages = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  }
end

return function(capabilities)
  local lspconfig = require 'lspconfig'

  lspconfig['ts_ls'].setup {
    capabilities = capabilities,
    root_dir = require 'vaquel.plugins.lsp.utils.attio-root-dir'.attio_root_dir 'ts_ls',
    init_options = {
      plugins = {
        styled_components_path(),
      },
    },
  }
end
