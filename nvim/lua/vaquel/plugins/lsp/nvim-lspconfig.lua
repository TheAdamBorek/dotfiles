return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'williamboman/mason-lspconfig.nvim' },
    { 'antosha417/nvim-lsp-file-operations', config = true },
    { 'folke/lazydev.nvim', opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require 'lspconfig'

    -- import mason_lspconfig plugin
    local mason_lspconfig = require 'mason-lspconfig'

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require 'cmp_nvim_lsp'

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local map = function(mode, key, action, desc)
          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          vim.keymap.set(mode, key, action, { buffer = ev.buf, silent = true, desc = desc })
        end

        -- set keybinds
        map('n', 'gr', '<cmd>Telescope lsp_references<CR>', 'Show LSP references') -- show definition, references
        map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration') -- go to declaration
        map('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', 'Show LSP definitions') -- show lsp definitions
        map('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', 'Show LSP implementations') -- show lsp implementations
        map('n', 'gt', '<cmd>Telescope lsp_type_definitions<CR>', 'Show LSP type definitions') -- show lsp type definitions
        map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'See available code actions') -- see available code actions, in visual mode will apply to selection
        map('n', '<leader>rr', vim.lsp.buf.rename, 'Smart [r]ename') -- smart rename
        map('n', '[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic') -- jump to previous diagnostic in buffer
        map('n', ']d', vim.diagnostic.goto_next, 'Go to next diagnostic') -- jump to next diagnostic in buffer
        map('n', 'K', vim.lsp.buf.hover, 'Show documentation for what is under cursor') -- show documentation for what is under cursor
        map('n', 'L', vim.diagnostic.open_float, 'Show line diagnostics') -- show diagnostics for line
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = ' ', Warn = ' ', Hint = '󰠠 ', Info = ' ' }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
    end

    mason_lspconfig.setup_handlers {
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup {
          capabilities = capabilities,
        }
      end,
      ['lua_ls'] = function()
        -- configure lua server (with special settings)
        lspconfig['lua_ls'].setup {
          capabilities = capabilities,
          settings = {
            Lua = {
              workspace = {
                library = {
                  '${3rd}/luv/library',
                  unpack(vim.api.nvim_get_runtime_file('', true)),
                },
              },
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { 'vim' },
              },
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        }
      end,
      ['ts_ls'] = function()
        local ts_lsp_config = require 'vaquel.plugins.lsp.ftplugin.typescript'
        ts_lsp_config(capabilities)
      end,
      ['eslint'] = function()
        lspconfig['eslint'].setup {
          capabilities = capabilities,
          root_dir = require('vaquel.plugins.lsp.utils.attio-root-dir').attio_root_dir 'eslint',
        }
      end,
      ['tailwindcss'] = function()
        lspconfig['tailwindcss'].setup {
          capabilities = capabilities,
          root_dir = require('vaquel.plugins.lsp.utils.attio-root-dir').attio_root_dir 'tailwindcss',
        }
      end,
      jsonls = function()
        lspconfig['jsonls'].setup {
          capabilities = capabilities,
          filetypes = { 'json', 'jsonc' },
          settings = {
            json = {
              -- Schemas https://www.schemastore.org
              schemas = {
                {
                  fileMatch = { 'package.json' },
                  url = 'https://json.schemastore.org/package.json',
                },
                {
                  fileMatch = { 'tsconfig*.json' },
                  url = 'https://json.schemastore.org/tsconfig.json',
                },
                {
                  fileMatch = {
                    '.prettierrc',
                    '.prettierrc.json',
                    'prettier.config.json',
                  },
                  url = 'https://json.schemastore.org/prettierrc.json',
                },
                {
                  fileMatch = { '.eslintrc', '.eslintrc.json' },
                  url = 'https://json.schemastore.org/eslintrc.json',
                },
                {
                  fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
                  url = 'https://json.schemastore.org/babelrc.json',
                },
                {
                  fileMatch = { 'lerna.json' },
                  url = 'https://json.schemastore.org/lerna.json',
                },
                {
                  fileMatch = { 'now.json', 'vercel.json' },
                  url = 'https://json.schemastore.org/now.json',
                },
                {
                  fileMatch = {
                    '.stylelintrc',
                    '.stylelintrc.json',
                    'stylelint.config.json',
                  },
                  url = 'http://json.schemastore.org/stylelintrc.json',
                },
              },
            },
          },
        }
      end,
      yamlls = function()
        lspconfig['yamlls'].setup {
          settings = {
            yaml = {
              -- Schemas https://www.schemastore.org
              schemas = {
                ['http://json.schemastore.org/gitlab-ci.json'] = { '.gitlab-ci.yml' },
                ['https://json.schemastore.org/bamboo-spec.json'] = {
                  'bamboo-specs/*.{yml,yaml}',
                },
                ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = {
                  'docker-compose*.{yml,yaml}',
                },
                ['http://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
                ['http://json.schemastore.org/github-action.json'] = '.github/action.{yml,yaml}',
                ['http://json.schemastore.org/prettierrc.json'] = '.prettierrc.{yml,yaml}',
                ['http://json.schemastore.org/stylelintrc.json'] = '.stylelintrc.{yml,yaml}',
                ['http://json.schemastore.org/circleciconfig'] = '.circleci/**/*.{yml,yaml}',
              },
            },
          },
        }
      end,
    }
  end,
}