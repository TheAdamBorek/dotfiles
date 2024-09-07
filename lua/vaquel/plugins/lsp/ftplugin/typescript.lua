return function(lspconfig, capabilities)
  local npmRoot = string.gsub(vim.fn.system 'npm root -g', '\n', '')
  local styledComponentsPath = npmRoot .. '/@styled/typescript-styled-plugin'
  if vim.fn.isdirectory(styledComponentsPath) == 1 then
    lspconfig['ts_ls'].setup {
      capabilities = capabilities,
      init_options = {
        plugins = {
          {
            name = '@styled/typescript-styled-plugin',
            location = styledComponentsPath,
            languages = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
          },
        },
      },
    }
  else
    print "Couldn't load styled-components/typescript-styled-plugin"
  end
end
