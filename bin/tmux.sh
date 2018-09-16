#!/bin/bash
if [[ -n $TMUX ]]; then
  exec tmux "$@"
fi

tmux_cmd="tmux -u2 -f $HOME/git/dotfiles/.tmux.conf"
if tmux has-session 2> /dev/null; then
  "$HOME/git/dotfiles/bin/set_env_for_fssh.rb"
  $tmux_cmd "$@" attach
else
  $tmux_cmd "$@"
fi
