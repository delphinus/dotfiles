if [ -n "$SSH_AUTH_SOCK" ]; then
  if [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/auth_sock" ]; then
    ln -fs $SSH_AUTH_SOCK $HOME/.ssh/auth_sock
    export SSH_AUTH_SOCK=$HOME/.ssh/auth_sock
  fi
  if ! [ -S "$SSH_AUTH_SOCK" ]; then
    sock=$(ls /tmp/**/Listeners || true)
    if [ -n "$sock" ]; then
      ln -fs $sock $SSH_AUTH_SOCK
    else
      sock=$(ls /tmp/ssh*/agent* || true)
      if [ -n "$sock" ]; then
        ln -fs $sock $SSH_AUTH_SOCK
      else
        echo 'sock file cannot be found'
        exit 1
      fi
    fi
  fi
fi
