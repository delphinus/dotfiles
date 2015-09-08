#!/bin/sh
# Ken's Memo: screen + SSHエージェントフォワーディング
# http://kenmemo.blogspot.jp/2011/04/screen-ssh.html
if [ "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/auth_sock" ]; then
    ln -fs $SSH_AUTH_SOCK $HOME/.ssh/auth_sock
    export SSH_AUTH_SOCK=$HOME/.ssh/auth_sock
fi
