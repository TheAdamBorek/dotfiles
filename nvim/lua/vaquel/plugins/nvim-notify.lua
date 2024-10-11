return {
  'rcarriga/nvim-notify',
  priority = 1000,
  opts = {},
  config = function(_, opts)
    local notify = require 'notify'
    notify.setup(opts)

    -- This fixes an issue with annoying message on `K` hover
    -- https://github.com/neovim/neovim/pull/18308/files
    local banned_messages = { 'No information available' }

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg, ...)
      for _, banned in ipairs(banned_messages) do
        if msg == banned then
          return
        end
      end

      return notify(msg, ...)
    end
  end,
}
