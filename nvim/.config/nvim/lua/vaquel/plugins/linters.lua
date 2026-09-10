return {
  'mfussenegger/nvim-lint',
  enabled = false,
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    local oxc = require 'vaquel.shared.oxc'

    local jsLinters = { 'biomejs' }
    local oxcLinters = { 'oxlint' }

    lint.linters_by_ft = {
      javascript = jsLinters,
      typescript = jsLinters,
      javascriptreact = jsLinters,
      typescriptreact = jsLinters,
    }

    -- Same split as the formatters: oxlint in the repos that have an oxlint config, biome in the
    -- ones that don't. nvim-lint keys its linters by filetype, which can't tell the two apart, so
    -- the JS filetypes get theirs picked per buffer and linters_by_ft above is the fallback.
    local function linters_for(bufnr)
      if lint.linters_by_ft[vim.bo[bufnr].filetype] == jsLinters and oxc.lints_with_oxlint(bufnr) then
        return oxcLinters
      end
      -- nil leaves nvim-lint to look the filetype up in linters_by_ft itself
      return nil
    end

    local lint_augroup = require('vaquel.shared.lint-autogroup').lint_autogroup
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function(args)
        lint.try_lint(linters_for(args.buf))
      end,
    })
  end,
}
