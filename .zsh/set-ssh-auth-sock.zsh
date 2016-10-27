if [ -n "$SSH_AUTH_SOCK" ]; then
  if [ -n "$SSH_CONNECTION"]; then
    if [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/auth_sock" ]; then
        ln -fs $SSH_AUTH_SOCK $HOME/.ssh/auth_sock
    fi
  elif ! [ -S "$SSH_AUTH_SOCK" ]; then
    sock=$(ls /tmp/**/Listeners)
    ln -fs $sock $SSH_AUTH_SOCK
  fi
  export SSH_AUTH_SOCK=$HOME/.ssh/auth_sock
fi
