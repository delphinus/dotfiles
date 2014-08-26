#!/bin/sh
TERM=xterm-256color
tmux_cmd="tmux -u2 -f $HOME/.tmux.conf"
if [ -z $TMUX ]; then
  if $(tmux has-session 2> /dev/null); then
    $tmux_cmd attach
  else
    $tmux_cmd
  fi
fi
