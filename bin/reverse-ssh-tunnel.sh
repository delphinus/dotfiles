#!/bin/bash
# http://qiita.com/syoyo/items/d31e9db6851dfee3ef82
SSH_AUTH_SOCK=$("$HOME/.ghg/bin/gosshauth" list -f '{{.Path}}' | head -1)
export SSH_AUTH_SOCK
COMMAND='/usr/local/bin/autossh -M 50000 -N -f -R 20023:localhost:22 git@remora.cx'
/usr/bin/pgrep -f -x "$COMMAND" > /dev/null 2>&1 || $COMMAND
