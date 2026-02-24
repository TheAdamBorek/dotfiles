set -g @plugin 'catppuccin/tmux#latest'
set -g @catppuccin_flavor 'latte' # latte,frappe, macchiato or mocha
set -g @catppuccin_window_status_style "rounded"
set -gu @catppuccin_window_current_left_separator
set -gu @catppuccin_window_current_middle_separator
set -gu @catppuccin_window_current_right_separator

set -g @catppuccin_window_text " #W"

set -g @catppuccin_window_current_text " #W"

set -g @catppuccin_status_modules_right "directory session"
set -g @catppuccin_status_fill "icon"
set -g @catppuccin_status_connect_separator "no"

set -g @catppuccin_directory_text "#{pane_current_path}"
