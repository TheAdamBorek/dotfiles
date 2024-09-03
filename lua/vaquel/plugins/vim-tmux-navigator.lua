local open_terminal_window = function()
  -- Check the number of panes in the current tmux window
  local pane_count = tonumber(vim.fn.system 'tmux list-panes | wc -l')
  local need_to_create_pane = pane_count < 2
  if need_to_create_pane then
    -- Create a new horizontal split if there's only one pane (horizontal means split below)
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
