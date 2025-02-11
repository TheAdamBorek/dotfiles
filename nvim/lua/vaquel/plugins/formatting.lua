return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'
    local jsFormatters = { 'prettier', stop_after_first = true }

    conform.setup {
      formatters_by_ft = {
        javascript = jsFormatters,
        typescript = jsFormatters,
        javascriptreact = jsFormatters,
        typescriptreact = jsFormatters,
        svelte = jsFormatters,
        css = jsFormatters,
        html = jsFormatters,
        json = jsFormatters,
        yaml = jsFormatters,
        markdown = jsFormatters,
        graphql = jsFormatters,
        liquid = jsFormatters,
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        svg = { 'xmlformatter' },
        xml = { 'xmlformatter' },
      },
    }

    -- There seems to be a bug with vim.lsp.get_clients({ method = 'textDocument/formatting' }) inside conform.
    -- The lsp.get_clients crashes on some files. Passing a name to options filters out every LSPs so there's nothing to filter by method.
    local fix_has_lsp_bug = 'DOESNT_MATTER'
    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*',
      group = vim.api.nvim_create_augroup('conform-autosave', { clear = true }),
      callback = function(args)
        conform.format {
          bufnr = args.buf,
          async = false,
          name = fix_has_lsp_bug,
        }
      end,
    })

    vim.keymap.set({ 'n', 'v' }, '<leader>mf', function()
      conform.format {
        async = false,
        name = fix_has_lsp_bug,
      }
    end, { desc = '[F]ormat file or range (in visual mode)' })
  end,
}
