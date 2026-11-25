#!/bin/sh
# Fuzzy-find any tmux pane by title (Claude Code session names), command, or path.
# Bound to prefix+F in ~/.tmux.conf; runs inside a display-popup.
# Claude Code panes (command is "claude" or a bare version like 2.1.326) get a "claude:" tag
# so typing "claude:" lists only Claude sessions.
pane=$(tmux list-panes -a -F '#{pane_id}	#{session_name}:#{window_index}.#{pane_index}	#{pane_current_command}	#{?#{||:#{==:#{pane_current_command},claude},#{m/r:^[0-9]+\.[0-9]+\.[0-9]+$,#{pane_current_command}}},claude: ,}#{pane_title}	#{pane_current_path}' |
  fzf --delimiter='\t' --with-nth=2.. --reverse --prompt='pane> ' \
      --preview 'tmux capture-pane -ep -t {1}' --preview-window=right:50% |
  cut -f1)
[ -n "$pane" ] && tmux switch-client -t "$pane" \; select-window -t "$pane" \; select-pane -t "$pane"
