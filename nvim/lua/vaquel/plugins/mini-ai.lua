return {
  'echasnovski/mini.ai',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = function()
    local mini_ai = require 'mini.ai'
    local spec_treesitter = mini_ai.gen_spec.treesitter

    mini_ai.setup {
      custom_textobjects = {
        f = spec_treesitter { a = '@function.outer', i = '@function.inner' },
        p = spec_treesitter { a = '@parameter.outer', i = '@parameter.inner' },
      },
      n_lines = 100,
      mappings = {
        goto_right = 'q',
        goto_left = 'Q',
      },
    }
  end,
}
