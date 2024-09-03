local open_terminal_window = function()
  print 'hello'
  local command = [[
  tmux list-panes -F "#{pane_active} #{pane_top}" | awk '
  $1 == "1" {current_top = $2}
  $2 > current_top {print "Pane below exists"; found=1; exit 0}
  END {if (!found) print "No pane below"; exit 1}'
  ]]
  local result = vim.fn.system(command)
  local has_pane_below = result == 'Pane below exists\n'
  if not has_pane_below then
    vim.fn.system 'tmux split-window -v -l 33%'
  else
    vim.fn.system 'tmux resize-pane -Z'
    vim.fn.system 'tmux select-pane -D'
  end
end

return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.g.tmux_navigator_disable_when_zoomed = 1
    vim.g.tmux_navigator_disable_netrw_workaround = 1
    vim.keymap.set('n', '<C-w>t', open_terminal_window, { desc = 'Open [t]erminal window' })
  end,
}
