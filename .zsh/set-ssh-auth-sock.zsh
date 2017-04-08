#!/usr/bin/env zsh
sock_link=$HOME/.ssh/auth_sock

function set_sock_link() {
  sock=$(ls /tmp/**/Listeners 2> /dev/null || true)
  if [ -n "$sock" ]; then
    ln -fs $sock $sock_link
  else
    sock=$(ls /tmp/ssh*/agent* 2> /dev/null || true)
    if [ -n "$sock" ]; then
      ln -fs $sock $sock_link
    else
      >&2 echo 'sock file cannot be found'
      exit 1
    fi
  fi
}

if [ -n "$SSH_AUTH_SOCK" ]; then
  if [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/auth_sock" ]; then
    ln -fs $SSH_AUTH_SOCK $HOME/.ssh/auth_sock
  fi
  if ! [ -S "$SSH_AUTH_SOCK" ]; then
    set_sock_link
  fi
else
  rm -f $sock_link
  set_sock_link
fi
