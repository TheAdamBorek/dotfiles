return {
  'echasnovski/mini.ai',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = function()
    local mini_ai = require 'mini.ai'
    local spec_treesitter = mini_ai.gen_spec.treesitter

    -- You can find more language-specific text objects in `after` directory
    mini_ai.setup {
      custom_textobjects = {
        f = spec_treesitter { a = { '@function.outer' }, i = '@function.inner' },
      },
      n_lines = 2,
    }
  end,
}
