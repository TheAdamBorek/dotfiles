return {
  'mason-org/mason.nvim',
  dependencies = {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  opts = function()
    -- Attio's Artifactory curation blocks npm packages (incl. transitive deps)
    -- younger than 7 days. Resolve every npm dependency to versions published
    -- before this rolling cutoff (~8 days ago) so installs aren't 403'd.
    local before = os.date('!%Y-%m-%d', os.time() - 8 * 24 * 60 * 60)
    return {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
      },
      npm = {
        install_args = { '--before', before },
      },
    }
  end,
}
