return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavour = 'macchiato',
    custom_highlights = function(colors)
      return {
        LineNr = { fg = colors.overlay2 },
      }
    end,
    integrations = {
      nvim_surround = true,
      lsp_trouble = true,
      which_key = true,
      mason = true,
      cmp = true,
      nvimtree = true,
      telescope = {
        enabled = true,
      },
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { 'italic' },
          hints = { 'italic' },
          warnings = { 'italic' },
          information = { 'italic' },
        },
        underlines = {
          errors = { 'underline' },
          hints = { 'underline' },
          warnings = { 'underline' },
          information = { 'underline' },
        },
        inlay_hints = {
          background = true,
        },
      },
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme 'catppuccin'
  end,
}

-- return {
--   'folke/tokyonight.nvim',
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   config = function()
--     local bg = '#011628'
--     local bg_dark = '#011423'
--     local bg_highlight = '#143652'
--     local bg_search = '#0A64AC'
--     local bg_visual = '#275378'
--     local fg = '#CBE0F0'
--     local fg_dark = '#B4D0E9'
--     local fg_gutter = '#627E97'
--     local border = '#547998'
--     local comment = '#8a92ba'
--     local unusedSymbol = '#565f89'
--
--     require('tokyonight').setup {
--       style = 'night',
--       on_colors = function(colors)
--         colors.bg = bg
--         colors.bg_dark = bg_dark
--         colors.bg_float = bg_dark
--         colors.bg_highlight = bg_highlight
--         colors.bg_popup = bg_dark
--         colors.bg_search = bg_search
--         colors.bg_sidebar = bg_dark
--         colors.bg_statusline = bg_dark
--         colors.bg_visual = bg_visual
--         colors.border = border
--         colors.fg = fg
--         colors.fg_dark = fg_dark
--         colors.fg_float = fg
--         colors.fg_gutter = fg_gutter
--         colors.fg_sidebar = fg_dark
--         colors.comment = comment
--       end,
--       on_highlights = function(hl)
--         hl.DiagnosticUnnecessary = { fg = unusedSymbol }
--       end,
--     }
--     vim.cmd.colorscheme 'tokyonight'
--   end,
-- }
