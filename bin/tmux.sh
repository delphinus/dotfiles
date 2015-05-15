#!/bin/sh
export POWERLINE_LIB=$(python -c 'import sys;import site;sys.stdout.write(site.USER_SITE)')/powerline
TERM=xterm-256color
if [ -z "$tmux_cmd" ]; then
  tmux_cmd="tmux -u2 -f $HOME/.tmux.conf"
fi
if [ -z $TMUX ]; then
  if $(tmux has-session 2> /dev/null); then
    $tmux_cmd attach $@
  else
    $tmux_cmd $@
  fi
fi
