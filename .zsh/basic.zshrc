# vim:se ft=zsh:

# http://d.hatena.ne.jp/kei_q/20110308/1299594629
show_buffer_stack() {
  POSTDISPLAY="
stack: $LBUFFER"
  zle push-line
}
zle -N show_buffer_stack
bindkey "^[q" show_buffer_stack

setopt print_eight_bit   # 日本語ファイル名を表示可能にする
setopt no_flow_control   # フローコントロールを無効にする
setopt auto_cd           # ディレクトリ名だけで移動する
setopt EXTENDED_GLOB     # 色んな glob
setopt HIST_IGNORE_SPACE # 最初にスペースのあるコマンドを履歴に追加しない
setopt inc_append_history hist_ignore_dups # 複数のターミナルで history を共有する

# zsh-notify x Growl - 人生いきあたりばったりで生きてます@はてな
# http://moqada.hatenablog.com/entry/2014/03/26/121915
autoload -Uz add-zsh-hook

# for brewed zsh
if [ -d /usr/local/share/zsh/help ]; then
  unalias run-help
  autoload run-help
  HELPDIR=/usr/local/share/zsh/help
fi

# 補完で大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# disable <C-S><C-Q>
stty -ixon -ixoff
# disable <C-Z>
stty susp undef

# MacVimにzshの環境変数読み込ませる方法 - エンジニアですよ！
# http://totem3.hatenablog.jp/entry/2013/10/17/055942
typeset -U path
