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
        lualine_b = { { 'filename', path = 1 } },
        lualine_c = {},
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
