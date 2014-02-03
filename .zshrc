source $HOME/git/dotfiles/.zsh/basic.zshrc

export PAGER=vimpager
export VIMPAGER_RC=$HOME/.vim/vimpagerrc
export ACK_PAGER='less -R'
export EDITOR=vim
export EDITRC=$HOME/.editrc
export INPUTRC=$HOME/.inputrc

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
alias pt=pt_darwin

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

# http://qiita.com/kei_s/items/96ee6929013f587b5878
autoload -U add-zsh-hook
export SYS_NOTIFIER=`which terminal-notifier`
export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh
