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
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      },
    }

    vim.keymap.set({ 'n', 'v' }, '<leader>df', function()
      conform.format {
        lsp_fallback = true,
        async = true,
        timeout_ms = 1000,
      }
    end, { desc = '[F]ormat file or range (in visual mode)' })
  end,
}
