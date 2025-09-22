return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require 'lualine'
    local lazy_status = require 'lazy.status' -- to configure lazy pending updates count

    lualine.setup {
      options = {
        theme = 'catppuccin',
      },
      extensions = { 'nvim-tree' },
      sections = {
        lualine_b = {
          {
            'filename',
            path = 1,
            fmt = function(name)
              return name:gsub('^packages/runtimes/', ''):gsub('^packages/libraries/[^/]+/', '')
            end,
          },
        },
        lualine_c = {},
        lualine_z = {
          {
            'lsp_status',
            icon = '', -- f013
            symbols = {
              -- Standard unicode symbols to cycle through for LSP progress:
              spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
              -- Standard unicode symbol for when LSP is done:
              done = '✓',
              -- Delimiter inserted between LSP names:
              separator = ' ',
            },
            -- List of LSP names to ignore (e.g., `null-ls`):
            ignore_lsp = { 'biome', 'tailwindcss', 'node', 'GitHub Copilot' },
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = '#ff9e64' },
          },
          {
            'diff',
            'diagnostics',
            sources = { 'nvim_lsp', 'nvim_diagnostic' },
            sections = { 'error', 'warn', 'info', 'hint' },
          },
          { 'encoding' },
          { 'fileformat' },
          { 'filetype' },
        },
      },
    }
  end,
}
