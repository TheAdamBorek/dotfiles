return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    'mason-org/mason.nvim',
    'neovim/nvim-lspconfig',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  opts = function()
    local config = require 'vaquel.config'
    -- tsgo is installed (and version-pinned) via mason-tool-installer below, since
    -- mason-lspconfig's ensure_installed can't pin versions and tsgo's latest build
    -- is always too new for Artifactory's 7-day curation. automatic_enable still
    -- enables it once installed.
    local ensure_installed = {
      'html',
      'cssls',
      'tailwindcss',
      'lua_ls',
      'jsonls',
      'yamlls',
      'bashls',
      'astro',
    }
    if not config.use_tsgo then
      table.insert(ensure_installed, 'ts_ls')
    end
    return {
      ensure_installed = ensure_installed,
      automatic_enable = {
        exclude = { config.use_tsgo and 'ts_ls' or 'tsgo' },
      },
    }
  end,
  config = function(_, opts)
    local config = require 'vaquel.config'
    local mason_lspconfig = require 'mason-lspconfig'
    local mason_tool_installer = require 'mason-tool-installer'

    -- enable mason-lspconfig and configure icons
    mason_lspconfig.setup(opts)

    local tools = {
      'stylua',
      'xmlformatter',
      'biome',
      'fixjson',
      'superhtml',
    }
    if config.use_tsgo then
      -- Must be >=7 days old AND older than mason.nvim's rolling --before cutoff
      -- (~8 days). @typescript/native-preview publishes daily; bump this manually
      -- to a date-stamped build that is at least ~8 days old when you want a newer one.
      table.insert(tools, { 'tsgo', version = '7.0.0-dev.20260527.2' })
    end

    -- enable mason-tool-installer
    mason_tool_installer.setup {
      ensure_installed = tools,
    }
  end,
}
