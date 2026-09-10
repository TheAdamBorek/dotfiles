local M = {}

-- The oxfmt config editors are pointed at: what CI enforces plus import sorting. attio's
-- .vscode/settings.json and .zed/settings.json use it, so imports get sorted on save and nothing
-- checks them on CI. Formatting through it keeps nvim in line with the rest of the team.
M.editor_config_file = 'oxfmt.editor.config.ts'

-- Everything oxfmt discovers on its own, plus the editor-only config above.
M.fmt_config_files = {
  M.editor_config_file,
  'oxfmt.config.ts',
  'oxfmt.config.js',
  'oxfmt.config.mjs',
  '.oxfmtrc.json',
  '.oxfmtrc.jsonc',
}

M.lint_config_files = {
  'oxlint.config.ts',
  'oxlint.config.js',
  'oxlint.config.mjs',
  '.oxlintrc.json',
}

---@param bufnr integer|nil defaults to the current buffer
---@return string directory to search a config upwards from
local function search_dir(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  return name ~= '' and vim.fs.dirname(name) or vim.fn.getcwd()
end

---The nearest directory above `path` holding an oxfmt config, i.e. the project formats with oxfmt.
---@param path string directory to search upwards from
---@return string|nil
M.find_fmt_root = function(path)
  return vim.fs.root(path, M.fmt_config_files)
end

---@param path string directory to search upwards from
---@return string|nil absolute path to the editor config, when the project has one
M.find_editor_config = function(path)
  local root = vim.fs.root(path, M.editor_config_file)
  return root and vim.fs.joinpath(root, M.editor_config_file)
end

---@param bufnr integer|nil defaults to the current buffer
---@return boolean
M.formats_with_oxfmt = function(bufnr)
  return M.find_fmt_root(search_dir(bufnr)) ~= nil
end

---@param bufnr integer|nil defaults to the current buffer
---@return boolean
M.lints_with_oxlint = function(bufnr)
  return vim.fs.root(search_dir(bufnr), M.lint_config_files) ~= nil
end

return M
