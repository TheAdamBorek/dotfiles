return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  version = '*', -- recommended, use latest release instead of latest commit
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
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

        local function goToNextDiagnosticError()
          vim.diagnostic.jump {
            count = 1,
            severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
          }
        end

        local function goToPreviousDiagnosticError()
          vim.diagnostic.jump {
            count = -1,
            severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
          }
        end

        -- set keybinds
        map('n', 'gr', Snacks.picker.lsp_references, 'Show LSP references') -- show definition, references
        map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration') -- go to declaration
        map('n', 'gd', Snacks.picker.lsp_definitions, 'Show LSP definitions') -- show lsp definitions
        map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'See available code actions') -- see available code actions, in visual mode will apply to selection
        map('n', '<leader>rr', vim.lsp.buf.rename, 'Smart [r]ename') -- smart rename
        map('n', ']d', goToNextDiagnosticError, 'Go to next diagnostic') -- jump to next diagnostic in buffer
        map('n', '[d', goToPreviousDiagnosticError, 'Go to previous diagnostic') -- jump to previous diagnostic in buffer
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

    vim.lsp.config('*', {
      capabilities = capabilities,
      root_dir = vim.fn.getcwd(),
    })
    vim.lsp.config('biome', {
      settings = {
        biome = {
          configurationPath = vim.fn.getcwd() .. '/biome.editor.jsonc',
        },
      },
    })
    vim.lsp.config('eslint', {
      root_markers = {
        '.eslintrc',
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        '.eslintrc.json',
        'eslint.config.js',
        'eslint.config.mjs',
      },
    })
    vim.lsp.config('lua_ls', {
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
    })

    -- TypeScript server configuration with styled-components plugin
    local function get_styled_components_plugin()
      local npmRoot = string.gsub(vim.fn.system 'npm root -g', '\\n', '')
      local styledComponentsPath = npmRoot .. '/@styled/typescript-styled-plugin'
      if vim.fn.isdirectory(styledComponentsPath) ~= 1 then
        return nil
      end
      return {
        name = '@styled/typescript-styled-plugin',
        location = styledComponentsPath,
        languages = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
      }
    end

    vim.lsp.config('ts_ls', {
      init_options = {
        plugins = vim.tbl_filter(function(plugin)
          return plugin ~= nil
        end, { get_styled_components_plugin() }),
        settings = {
          typescript = {
            tsserver = {
              maxTsServerMemory = 8192,
              nodePath = utils.cli_command 'command -v node',
            },
          },
        },
      },
    })
    vim.lsp.config('astro', {
      init_options = {
        typescript = {
          tsdk = vim.fs.normalize 'node_modules/typescript/lib',
        },
      },
    })
    vim.lsp.config('jsonls', {
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
    })
    vim.lsp.config('yamlls', {
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
    })
  end,
}
