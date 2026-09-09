local M = {}

M.lint_autogroup_name = 'lint'
M.lint_autogroup = vim.api.nvim_create_augroup(M.lint_autogroup_name, { clear = true })

return M
