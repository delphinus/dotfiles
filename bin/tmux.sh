#!/bin/sh
if [ -n "$TMUX" ]; then
  exec tmux $@
fi

if $(tmux has-session 2> /dev/null); then
  $H/git/dotfiles/bin/set_env_for_fssh.rb
  $tmux_cmd attach $@
else
  $tmux_cmd $@
fi
