#!/bin/sh
if [ -n "$TMUX" ]; then
  exec tmux $@
fi

if [ `uname` = 'Darwin' ]; then
  python=/usr/bin/python
else
  python=python
fi
export POWERLINE_LIB=$($python -c 'import sys;import site;sys.stdout.write(site.USER_SITE)')/powerline
export TERM=xterm-256color-italic
if [ -z "$tmux_cmd" ]; then
  tmux_cmd="tmux -u2 -f $HOME/.tmux.conf"
fi
if $(tmux has-session 2> /dev/null); then
  $tmux_cmd attach $@
else
  $tmux_cmd $@
fi
