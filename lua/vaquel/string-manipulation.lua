-- Converts a CamelCase to kebab-case
vim.keymap.set('v', 'gk', '<cmd>s/\\([a-zA-Z]\\)\\([A-Z]\\)/\\1-\\l\\2/g<CR><cmd>s/^\\([A-Z]\\)/\\l\\1/<CR><Esc>', { desc = 'Convert camelCase to kebab-case' })
