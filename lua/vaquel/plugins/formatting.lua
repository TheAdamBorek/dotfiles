return {
  enabled = false,
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'
    local jsFormatters = { 'prettierd', 'prettier', stop_after_first = true }

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
      },
    }

    vim.api.nvim_create_autocmd('BufReadPre', {
      pattern = '*',
      group = vim.api.nvim_create_augroup('conform-autosave', { clear = true }),
      callback = function(args)
        conform.format {
          bufnr = args.buf,
        }
      end,
    })

    vim.keymap.set({ 'n', 'v' }, '<leader>mf', function()
      conform.format {
        lsp_fallback = true,
        async = true,
        timeout_ms = 1000,
      }
    end, { desc = '[F]ormat file or range (in visual mode)' })
  end,
}
