-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', 'Q', '<Nop>')
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('n', '<leader><C-w>', '<cmd>w<CR>', { desc = 'Save the buffer', noremap = true })

-- Keep cursor in the middle
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- WARNING: has problems with lazygit
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-w><C-q>', '<cmd>close<CR>', { desc = 'Close current split' })

-- Quickfix list navigation
vim.keymap.set('n', '<C-n>', '<cmd>cnext<CR>', { desc = 'Move to next Quickfix item' })
vim.keymap.set('n', '<C-p>', '<cmd>cprev<CR>', { desc = 'Move to prev Quickfix item' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- System yanking, deleting etc.
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from the system clipboard' })
vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste from the system clipboard' })
vim.keymap.set('v', '<leader>p', '"+p', { desc = 'Paste from the system clipboard' })
vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')

--
vim.keymap.set('n', '<leader><C-s>', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Move highlighted lines
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Map '\' to start and stop macro recording (like 'q' does by default)
vim.api.nvim_set_keymap('n', '\\', 'q', { noremap = true })
vim.api.nvim_set_keymap('n', 'q', '<Nop>', { noremap = true })
