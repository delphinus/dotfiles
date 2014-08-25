source $HOME/git/dotfiles/.zsh/basic.zshrc
source $HOME/git/dotfiles/.zsh/peco-select-history.zsh
source $HOME/git/dotfiles/bin/set-ssh-auth-sock.sh

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
alias dvim="dtach -A /tmp/vim-session -e \^\^ vim"
alias b='bundle'
alias pl='perl -M"feature qw!say!" -M"Date::Manip qw!UnixDate ParseDate!" -e'

export PAGER='vimpager'
alias vp='vimpager'
alias perldoc='perldocjp -J'
alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
export H=$HOME
export ACK_PAGER='less -R'
alias tmux="TERM=xterm-256color tmux -2 -f $HOME/git/dotfiles/.tmux.conf"
alias pt=pt_darwin

export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="/usr/local/mysql/bin:\
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
export PYENV_ROOT=/usr/local/opt/pyenv
export PATH=$PYENV_ROOT/bin:$PATH
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# for ruby
export RBENV_ROOT=/usr/local/opt/rbenv
export PATH=$RBENV_ROOT/bin:$PATH
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# for plenv
export PLENV_ROOT=/usr/local/opt/plenv
export PATH=$PLENV_ROOT/bin:$PATH
if which plenv > /dev/null; then eval "$(plenv init -)"; fi

# for go
export GOPATH=$HOME/go
export PATH=/usr/local/opt/go/libexec/bin:$GOPATH/bin:$PATH

# powerline
module_path=($module_path /usr/local/lib/zpython)
. $HOME/git/powerline/powerline/bindings/zsh/powerline.zsh

# http://qiita.com/kei_s/items/96ee6929013f587b5878
autoload -U add-zsh-hook
export SYS_NOTIFIER=`which terminal-notifier`
export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh

export CURL_CA_BUNDLE=~/git/dotfiles/ca-bundle.crt
