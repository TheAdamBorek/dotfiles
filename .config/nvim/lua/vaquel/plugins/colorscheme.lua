-- return {
--   'EdenEast/nightfox.nvim',
--   priority = 1000,
--   lazy = false,
--   opts = {},
--   config = function(opts)
--     require('nightfox').setup(opts)
--     vim.cmd.colorscheme 'dayfox'
--     -- vim.opt.background = 'light'
--   end,
-- }

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'latte',
      auto_integrations = true,
    }
    vim.cmd.colorscheme 'catppuccin'
  end,
}

-- return {
--   'folke/tokyonight.nvim',
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   lazy = false,
--   opts = { style = 'day' },
--   config = function(opts)
--     require('tokyonight').setup(opts)
--     vim.cmd.colorscheme 'tokyonight-day'
--   end,
-- }
