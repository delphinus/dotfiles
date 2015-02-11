source $HOME/git/dotfiles/.zsh/basic.zshrc
source $HOME/git/dotfiles/.zsh/peco-select-history.zsh
source $HOME/git/dotfiles/.zsh/peco-git.zsh
source $HOME/git/dotfiles/bin/set-ssh-auth-sock.sh

export PAGER=vimpager
export VIMPAGER_RC=$HOME/.vim/vimpagerrc
export ACK_PAGER='less -R'
export EDITOR=vim
export EDITRC=$HOME/.editrc
export INPUTRC=$HOME/.inputrc

OS=`uname`
if [ "$OS" = 'Darwin' ]; then
  LS=gls
  alias dircolors=gdircolors
  alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
else
  LS=ls
fi
alias ls="$LS --color"
alias ll="$LS --color -l"
alias l.="$LS --color -d .*"
eval `TERM=xterm-256color dircolors $HOME/git/dotfiles/submodules/dircolors-solarized/dircolors.ansi-dark`
alias dvtm="SHELL=/bin/zsh dvtm -m ^z"
alias dv="dtach -A /tmp/dvtm-session -r winch dvtm.sh"
alias dvim="dtach -A /tmp/vim-session -e \^\^ vim"
alias lv='lv -c'

alias vp='vimpager'
alias tmux="tmux_cmd='tmux -u2 -f $HOME/git/dotfiles/.tmux.conf' tmux.sh"

export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="$HOME/Dropbox/bin:\
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

# for python
export PYENV_ROOT=/usr/local/opt/pyenv
export PATH=$PYENV_ROOT/bin:$PATH
alias py=pyenv
alias pyv='pyenv versions'
if which pyenv > /dev/null; then eval "$(pyenv init - zsh)"; fi

# for ruby
export RBENV_ROOT=/usr/local/opt/rbenv
export PATH=$RBENV_ROOT/bin:$PATH
alias rb=rbenv
alias rbv='rbenv versions'
if which rbenv > /dev/null; then eval "$(rbenv init - zsh)"; fi

# for plenv
export PLENV_ROOT=/usr/local/opt/plenv
export PATH=$PLENV_ROOT/bin:$PATH
alias pl=plenv
alias plv='plenv versions'
if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi

if [ "$OS" = 'Darwin' ]; then
  # http://qiita.com/kei_s/items/96ee6929013f587b5878
  export SYS_NOTIFIER=/usr/local/bin/terminal-notifier
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
  source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh
fi

export CURL_CA_BUNDLE=~/git/dotfiles/ca-bundle.crt

# powerline
user_site=`python -c 'import site;import sys;sys.stdout.write(site.USER_SITE)'`
user_base=`python -c 'import site;import sys;sys.stdout.write(site.USER_BASE)'`
export PATH=$user_base/bin:$PATH
module_path=($module_path /usr/local/lib/zpython)
. $user_site/powerline/bindings/zsh/powerline.zsh
