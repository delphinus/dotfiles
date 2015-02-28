#!/bin/sh
TERM=xterm-256color
if [ "$tmux_cmd" == "" ]; then
  tmux_cmd="tmux -u2 -f $HOME/.tmux.conf" $@
fi
if [ -z $TMUX ]; then
  if $(tmux has-session 2> /dev/null); then
    $tmux_cmd attach
  else
    $tmux_cmd
  fi
fi
