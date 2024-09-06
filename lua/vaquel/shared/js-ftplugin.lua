local M = {}

local function setup_eslint_on_save()
  vim.keymap.set('n', '<leader>dl', '<cmd>EslintFixAll<CR><cmd>w<CR>', { desc = 'Fix all ES[L]int problems' })
  local linter = require 'lint'

  local autogroup_name = require('vaquel.shared.lint-autogroup').lint_autogroup_name
  local on_safe_autogroup = vim.api.nvim_create_augroup(autogroup_name, { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = on_safe_autogroup,
    callback = function()
      vim.cmd [[
        EslintFixAll
      ]]

      linter.try_lint()
    end,
  })

  local report_only_autogroup = vim.api.nvim_create_augroup('lint_readonly', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave' }, {
    group = report_only_autogroup,
    callback = function()
      linter.try_lint()
    end,
  })
end

M.apply = function()
  setup_eslint_on_save()
end

return M
