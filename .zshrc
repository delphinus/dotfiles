# 強力な補完を有効にする
autoload -Uz compinit
compinit

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

bindkey -v               # vi 風キーバインドにする
bindkey "" history-incremental-search-backward # bash の <C-R> と一緒
# http://d.hatena.ne.jp/kei_q/20110308/1299594629
show_buffer_stack() {
  POSTDISPLAY="
stack: $LBUFFER"
  zle push-line
}
zle -N show_buffer_stack
bindkey "^[q" show_buffer_stack

export LANG=ja_JP.UTF-8
setopt print_eight_bit   # 日本語ファイル名を表示可能にする
setopt no_flow_control   # フローコントロールを無効にする
setopt transient_rprompt # 最後以外の右プロンプトを消す
setopt auto_cd           # ディレクトリ名だけで移動する
setopt EXTENDED_GLOB     # 色んな glob
setopt HIST_IGNORE_SPACE # 最初にスペースのあるコマンドを履歴に追加しない

# disable <C-S><C-Q>
stty -ixon -ixoff
# disable <C-Z>
stty susp undef
