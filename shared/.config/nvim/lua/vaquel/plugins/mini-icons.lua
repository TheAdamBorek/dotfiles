return {
  'echasnovski/mini.icons',
  lazy = true,
  opts = {},
  init = function()
    -- Provide backward compat so plugins requiring nvim-web-devicons still work
    package.preload['nvim-web-devicons'] = function()
      require('mini.icons').mock_nvim_web_devicons()
      return package.loaded['nvim-web-devicons']
    end
  end,
}
