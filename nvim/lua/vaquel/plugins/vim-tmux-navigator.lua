return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.g.tmux_navigator_disable_when_zoomed = 1
    vim.g.tmux_navigator_disable_netrw_workaround = 1

    vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>')
    vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>')
    vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>')
    vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>')
    vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>')
    vim.keymap.set('t', '<C-h>', '<C-\\><C-n><cmd>TmuxNavigateLeft<cr>')
    vim.keymap.set('t', '<C-j>', '<C-\\><C-n><cmd>TmuxNavigateDown<cr>')
    vim.keymap.set('t', '<C-k>', '<C-\\><C-n><cmd>TmuxNavigateUp<cr>')
    vim.keymap.set('t', '<C-l>', '<C-\\><C-n><cmd>TmuxNavigateRight<cr>')
  end,
}
