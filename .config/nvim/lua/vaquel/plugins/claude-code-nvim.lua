return {
  {
    'greggh/claude-code.nvim',
    enabled = false,
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for git operations
    },
    config = function()
      require('claude-code').setup {
        window = {
          position = 'vertical',
        },
      }
    end,
  },
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    config = true,
    keys = {
      {
        '<leader>ac',
        function()
          vim.cmd 'ClaudeCode'
          vim.cmd 'wincmd ='
        end,
        desc = 'Toggle Claude',
      },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles' },
      },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
    opts = {
      terminal = {
        snacks_win_opts = {
          keys = {
            claude_hide_ctrl = {
              '<C-,>',
              function(self)
                self:hide()
              end,
              mode = 't',
              desc = 'Hide (Ctrl+,)',
            },
          },
        },
      },
    },
  },
  {
    enabled = false,
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    opts = {},
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    keys = {},
    dependencies = {
      'MeanderingProgrammer/render-markdown.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'stevearc/dressing.nvim', -- for input provider dressing
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      -- { -- This breaks text pasting - Adam (14 07 2025)
      --   -- support for image pasting
      --   'HakonHarnes/img-clip.nvim',
      --   event = 'VeryLazy',
      --   opts = {
      --     -- recommended settings
      --     default = {
      --       embed_image_as_base64 = false,
      --       prompt_for_file_name = false,
      --       drag_and_drop = {
      --         insert_mode = true,
      --       },
      --       -- required for Windows users
      --       use_absolute_path = true,
      --     },
      --   },
      -- },
    },
  },
}
