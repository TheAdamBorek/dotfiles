return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    'mason-org/mason.nvim',
    'neovim/nvim-lspconfig',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  opts = function()
    local config = require 'vaquel.config'
    return {
      ensure_installed = {
        config.use_tsgo and 'tsgo' or 'ts_ls',
        'html',
        'cssls',
        'tailwindcss',
        'lua_ls',
        'jsonls',
        'yamlls',
        'bashls',
        'astro',
      },
      automatic_enable = {
        exclude = { config.use_tsgo and 'ts_ls' or 'tsgo' },
      },
    }
  end,
  config = function(_, opts)
    local mason_lspconfig = require 'mason-lspconfig'
    local mason_tool_installer = require 'mason-tool-installer'

    -- enable mason-lspconfig and configure icons
    mason_lspconfig.setup(opts)

    -- enable mason-tool-installer
    mason_tool_installer.setup {
      ensure_installed = {
        'stylua',
        'xmlformatter',
        'biome',
        'fixjson',
        'superhtml',
      },
    }
  end,
}
