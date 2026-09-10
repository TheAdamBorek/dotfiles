return {
  'stevearc/conform.nvim',
  version = '*',
  enabled = true,
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'
    local conform_util = require 'conform.util'
    local oxc = require 'vaquel.shared.oxc'

    -- oxfmt in the repos that have migrated to it, biome in the ones that haven't. The two are
    -- mutually exclusive by config file: oxfmt only runs where one sits above the file
    -- (require_cwd below) and biome is switched off there, so a repo is never formatted twice, and
    -- a migrated repo never gets biome's defaults applied to it.
    local jsFormatters = { 'oxfmt', 'biome', stop_after_first = true }

    conform.setup {
      default_format_opts = {
        async = false,
        timeout_ms = 5000,
      },
      formatters_by_ft = {
        javascript = jsFormatters,
        typescript = jsFormatters,
        javascriptreact = jsFormatters,
        typescriptreact = jsFormatters,
        css = jsFormatters,
        html = { 'superhtml' },
        yaml = jsFormatters,
        markdown = jsFormatters,
        graphql = jsFormatters,
        -- fixjson repairs the JSON first, so this list always runs to the end. The formatter that
        -- follows it is picked by the same config-file check as jsFormatters.
        json = { 'fixjson', 'oxfmt', 'biome' },
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        svg = { 'xmlformatter' },
        xml = { 'xmlformatter' },
      },
      formatters = {
        -- conform has no built-in oxfmt definition yet.
        oxfmt = {
          command = conform_util.from_node_modules 'oxfmt',
          stdin = true,
          args = function(_, ctx)
            local args = { '--stdin-filepath=' .. ctx.filename }
            local editor_config = oxc.find_editor_config(ctx.dirname)
            if editor_config then
              -- Loading a TypeScript config needs node ^20.19 || >=22.18 on the PATH nvim was
              -- started with. oxfmt fails loudly when it's older, rather than formatting without
              -- the config.
              table.insert(args, 1, '--config=' .. editor_config)
            end
            return args
          end,
          cwd = conform_util.root_file(oxc.fmt_config_files),
          require_cwd = true,
        },
        biome = {
          condition = function(_, ctx)
            return oxc.find_fmt_root(ctx.dirname) == nil
          end,
        },
        ['biome-check'] = {
          args = { 'check', '--write', '--unsafe', '--stdin-file-path', '$FILENAME' },
        },
        -- Deliberately not in formatters_by_ft: this is the lint half of `biome check --write`,
        -- run by hand from <leader>cl. --fix leaves the problems it can't fix as warnings, which
        -- oxlint reports with exit code 1.
        oxlint = {
          command = conform_util.from_node_modules 'oxlint',
          stdin = false,
          args = { '--fix', '$FILENAME' },
          exit_codes = { 0, 1 },
        },
      },
      format_on_save = {
        async = false,
      },
    }

    -- There seems to be a bug with vim.lsp.get_clients({ method = 'textDocument/formatting' }) inside conform.
    -- The lsp.get_clients crashes on some files. Passing a name to options filters out every LSPs so there's nothing to filter by method.
    -- local fix_has_lsp_bug = 'DOESNT_MATTER'
    -- vim.api.nvim_create_autocmd('BufWritePre', {
    --   pattern = '*',
    --   group = vim.api.nvim_create_augroup('conform-autosave', { clear = true }),
    --   callback = function(args)
    --     conform.format {
    --       bufnr = args.buf,
    --       async = false,
    --     }
    --   end,
    -- })

    vim.keymap.set({ 'n', 'v' }, '<leader>mf', function()
      conform.format()
    end, { desc = '[F]ormat file or range' })
  end,
}
