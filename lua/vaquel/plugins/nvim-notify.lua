return {
  'rcarriga/nvim-notify',
  priority = 1000,
  opts = {},
  config = function(_, opts)
    local vim_notify = require 'notify'
    vim_notify.setup(opts)

    vim.notify = vim_notify
  end,
}
