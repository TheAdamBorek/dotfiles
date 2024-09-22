return {
  'echasnovski/mini.ai',
  config = function()
    local mini_ai = require 'mini.ai'
    local spec_treesitter = mini_ai.gen_spec.treesitter

    mini_ai.setup {
      custom_textobjects = {
        f = spec_treesitter { a = '@function.outer', i = '@function.inner' },
      },
    }
  end,
}
