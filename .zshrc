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
# vi 風キーバインドにする
bindkey -v

export LANG=ja_JP.UTF-8
setopt print_eight_bit   # 日本語ファイル名を表示可能にする
setopt no_flow_control   # フローコントロールを無効にする
setopt transient_rprompt # 最後以外の右プロンプトを消す
setopt auto_cd           # ディレクトリ名だけで移動する
setopt EXTENDED_GLOB     # 色んな glob
setopt HIST_IGNORE_SPACE # 最初にスペースのあるコマンドを履歴に追加しない
setopt auto_cd           # ディレクトリ名だけで異動する

# disable <C-S><C-Q>
stty -ixon -ixoff
# disable <C-Z>
stty susp undef

alias ls='gls --color'
alias ll='gls --color -l'
alias l.='gls --color -d .*'
alias dircolors=gdircolors
eval `TERM=xterm-256color dircolors $HOME/git/dotfiles/submodules/dircolors-solarized/dircolors.ansi-dark`
alias dvtm="SHELL=/bin/zsh dvtm -m ^z"
alias dv="dtach -A /tmp/dvtm-session -r winch dvtm.sh"

export PAGER='vimpager'
alias vp='vimpager'
alias perldoc='perldocjp -J'
alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
export H=$HOME
export ACK_PAGER='less -R'
alias tmux="TERM=screen-256color-bce tmux -f $HOME/git/dotfiles/.tmux.conf"

export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="/usr/local/Cellar/ruby/2.0.0-p247/bin:\
$HOME/.gem/ruby/2.0.0/bin:\
/usr/local/mysql/bin:\
$HOME/Dropbox/bin:\
$HOME/bin:\
$HOME/git/dotfiles/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/bin:\
/usr/sbin:\
/sbin:\
/usr/bin:\
/usr/X11/bin"
# for perlomni.vim
export PATH="$HOME/.vim/bundle/perlomni.vim/bin:$PATH"

export MYPERL=`which perl`

# for python
[[ -s $HOME/.pythonz/etc/bashrc ]] && source $HOME/.pythonz/etc/bashrc
source `which virtualenvwrapper.sh`
export WORKON_HOME=$HOME/.virtualenvs
export PIP_RESPECT_VIRTUALENV=true
workon 3.3.3

# powerline
module_path=($module_path /usr/local/lib/zpython)
. $HOME/git/powerline/powerline/bindings/zsh/powerline.zsh

# for plenv
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"
