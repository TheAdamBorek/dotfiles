return {
  'mfussenegger/nvim-lint',
  enabled = false,
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    local jsLinters = { 'biomejs' }

    lint.linters_by_ft = {
      javascript = jsLinters,
      typescript = jsLinters,
      javascriptreact = jsLinters,
      typescriptreact = jsLinters,
    }

    local lint_augroup = require('vaquel.shared.lint-autogroup').lint_autogroup
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
