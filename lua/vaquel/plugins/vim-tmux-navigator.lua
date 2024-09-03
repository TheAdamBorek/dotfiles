local open_terminal_window = function()
  local command = [[
tmux list-panes -F "#{pane_active} #{pane_top}" | awk -v bottom=$(tmux display-message -p "#{pane_bottom}") '
$1 == "1" {current_bottom=bottom}
$2 > current_bottom {print "Pane below exists"; found=1; exit}
END {if (!found) print "No pane below"}'
]]
  local has_pane_below = vim.fn.system(command) == 'Pane below exists\n'
  if not has_pane_below then
    os.execute 'tmux split-window -v -l 33%'
  else
    os.execute 'tmux resize-pane -Z'
    os.execute 'tmux select-pane -D'
  end
end

return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.g.tmux_navigator_disable_when_zoomed = 1

    vim.keymap.set('n', '<C-w>t', open_terminal_window, { desc = 'Open [t]erminal window' })
  end,
}
