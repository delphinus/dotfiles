#!/bin/bash
export GODO_MAIL_USER=delphinus@remora.cx
export GODO_MAIL_RECIPIENTS=delphinus35@me.com
export GODO_MAIL=delphinus@remora.cx
pass="$(cat ~/.godo_gmail_password)"
export GODO_MAIL_PASSWORD="$pass"

now=$(date +'%F %T')
export GODO_MAIL_SUBJECT="アドレスを更新しました $now"

"$HOME/.go/bin/godo" renew -z remora.cx -d remora.cx -m
"$HOME/.go/bin/godo" renew -z remora.cx -d remora.cx -m -6
