source $HOME/git/dotfiles/.zsh/basic.zshrc
source $HOME/git/dotfiles/.zsh/peco-select-history.zsh
source $HOME/git/dotfiles/.zsh/peco-git.zsh
source $HOME/git/dotfiles/.zsh/peco-ghq.zsh
source $HOME/git/dotfiles/.zsh/peco-z.zsh
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
alias path='echo $PATH | perl -aF: -le "print for sort @F"'
alias g='git'
alias gh='ghq'
alias be='bundle exec'
alias stripcolors='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?[mGK]//g"'

alias vp='vimpager'
alias tm="tmux_cmd='tmux -u2 -f $HOME/git/dotfiles/.tmux.conf' tmux.sh"

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
/usr/X11/bin:\
$PATH"

export CURL_CA_BUNDLE=~/git/dotfiles/ca-bundle.crt

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

# for lua
export LUAENV_ROOT=/usr/local/opt/luaenv
export PATH=$LUAENV_ROOT/bin:$PATH
alias lu=luaenv
alias luv='luaenv versions'
if which luaenv > /dev/null; then eval "$(luaenv init - zsh)"; fi

# perl
if [ -d $HOME/perl5 ]; then
  local arch=$(perl -v | grep 'for \S\+$' | perl -pe 's/.*?(\S+)$/$1/')
  export PATH=$HOME/perl5/bin:$PATH
  export PERL5LIB=$HOME/perl5/lib/perl5:$HOME/perl5/lib/perl5/$arch/auto:$PERL5LIB
fi

if [[ $OS = Darwin && -d $HOME/perl5 ]]; then
  # for perlbrew
  if [ -f $HOME/perl5/perlbrew/etc/bashrc ]; then
    source $HOME/perl5/perlbrew/etc/bashrc
    source $HOME/perl5/perlbrew/etc/perlbrew-completion.bash
    alias perl='perl -I$HOME/perl5/lib/perl5'
  fi
else
  # for plenv
  export PLENV_ROOT=/usr/local/opt/plenv
  export PATH=$PLENV_ROOT/bin:$PATH
  alias pl=plenv
  alias plv='plenv versions'
  if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi
fi

# terminal-notifier
if [ "$OS" = 'Darwin' ]; then
  # http://qiita.com/kei_s/items/96ee6929013f587b5878
  export SYS_NOTIFIER=/usr/local/bin/terminal-notifier
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
  source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh
fi

# powerline
if [ "$OS" = 'Darwin' ]; then
  user_site=`/usr/bin/python -c 'import site;import sys;sys.stdout.write(site.USER_SITE)'`
  user_base=`/usr/bin/python -c 'import site;import sys;sys.stdout.write(site.USER_BASE)'`
else
  user_site=`python -c 'import site;import sys;sys.stdout.write(site.USER_SITE)'`
  user_base=`python -c 'import site;import sys;sys.stdout.write(site.USER_BASE)'`
fi
export PATH=$user_base/bin:$PATH
module_path=($module_path /usr/local/lib/zpython /usr/local/lib/zsh/5.0.5-dev-0/zsh)
. $user_site/powerline/bindings/zsh/powerline.zsh

# z
if [ "$OS" = 'Darwin' ]; then
  . `brew --prefix`/etc/profile.d/z.sh
elif [ -f /etc/profile.d/z.sh ]; then
  . /etc/profile.d/z.sh
elif [ -f $(ghq list --full-path rupa/z)/z.sh ]; then
  . $(ghq list --full-path rupa/z)/z.sh
fi

# grc
if which brew > /dev/null; then
  if [ -f "`brew --prefix`/etc/grc.bashrc" ]; then
    . "`brew --prefix`/etc/grc.bashrc"
  fi
elif [ -f '/etc/profile.d/grc.bashrc' ]; then
  . /etc/profile.d/grc.bashrc
  export MANPATH=/usr/local/share/man:$MANPATH
fi

# ansible
if which brew > /dev/null; then
else
  export ANSIBLE_PATH=$(ghq list --full-path ansible)
  export PATH=$ANSIBLE_PATH/bin:$PATH
  export PYTHONPATH=$ANSIBLE_PATH/lib
  export MANPATH=$ANSIBLE_PATH/docs/man:$MANPATH
fi

# custom mysql
local mysql_bin=/usr/local/opt/mysql/bin
if [ -d "$mysql_bin" ]; then
  export PATH=$mysql_bin:$PATH
fi

# github access token
local homebrew_github_api_token=$HOME/.homebrew_github_api_token
if [ -f "$homebrew_github_api_token" ]; then
  . $homebrew_github_api_token
fi

# PHP composer
local composer_vender_bin=$HOME/.composer/vendor/bin
if [ -d "$composer_vender_bin" ]; then
  export PATH="$composer_vender_bin:$PATH"
fi

# node
local node_dir=/usr/local/node/bin
if [ -d "$node_dir" ]; then
  export PATH=$node_dir:$PATH
fi

# fssh
if [ -z "$TMUX" -a -n "$LC_FSSH_PORT" ]; then
  local fssh_env=$HOME/git/dotfiles/bin/fssh_env
  env | grep FSSH | ruby -pe '$_.sub!(/^(LC_FSSH_[A-Z_]*)=(.*)$/) { %Q[export #$1="#$2"] }' > $fssh_env
  chmod +x $fssh_env
fi

# local settings
local zshrc_local=$HOME/.zshrc.local
if [ -f "$zshrc_local" ]; then
  . $zshrc_local
fi
