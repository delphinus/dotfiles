# 強力な補完を有効にする
autoload -Uz compinit
compinit

if [ -z "$H" ]; then
  export H=$HOME
fi

export PATH="\
$H/Dropbox/bin:\
$H/bin:\
$H/git/dotfiles/bin:\
$PATH"

# for python
if [ -d '/usr/local/opt/pyenv' ]; then
  export PYENV_ROOT=/usr/local/opt/pyenv
else
  export PYENV_ROOT=$HOME/.pyenv
fi
export PATH=$PYENV_ROOT/bin:$PATH
alias py=pyenv
alias pyv='pyenv versions'
if which pyenv > /dev/null; then eval "$(pyenv init - zsh)"; fi
user_base=`python -c 'import sys;import site;sys.stdout.write(site.USER_BASE)'`
export PATH=$user_base/bin:$PATH

# for ruby
if [ -d '/usr/local/opt/rbenv' ]; then
  export RBENV_ROOT=/usr/local/opt/rbenv
else
  export RBENV_ROOT=$HOME/.rbenv
fi
export PATH=$RBENV_ROOT/bin:$PATH
alias rb=rbenv
alias rbv='rbenv versions'
if which rbenv > /dev/null; then eval "$(rbenv init - zsh)"; fi

# for lua
if [ -d '/usr/local/opt/luaenv' ]; then
  export LUAENV_ROOT=/usr/local/opt/luaenv
else
  export LUAENV_ROOT=$HOME/.luaenv
fi
export PATH=$LUAENV_ROOT/bin:$PATH
alias lu=luaenv
alias luv='luaenv versions'
if which luaenv > /dev/null; then eval "$(luaenv init - zsh)"; fi

# perl
if [ -d "$HOME/perl5" ]; then
  local arch=$(perl -v | grep 'for \S\+$' | perl -pe 's/.*?(\S+)$/$1/')
  export PATH=$HOME/perl5/bin:$PATH
  export PERL5LIB=$HOME/perl5/lib/perl5:$HOME/perl5/lib/perl5/$arch/auto:$PERL5LIB
fi

# for perlbrew
if [ `uname` = 'Darwin' -a -f $HOME/perl5/perlbrew/etc/bashrc ]; then
  source $HOME/perl5/perlbrew/etc/bashrc
  source $HOME/perl5/perlbrew/etc/perlbrew-completion.bash
  alias perl='perl -I$HOME/perl5/lib/perl5'
else
  # for plenv
  if [ -d '/usr/local/opt/plenv' ]; then
    export PLENV_ROOT=/usr/local/opt/plenv
  else
    export PLENV_ROOT=$HOME/.plenv
  fi
  export PATH=$PLENV_ROOT/bin:$PATH
  alias pl=plenv
  alias plv='plenv versions'
  if which plenv > /dev/null; then eval "$(plenv init - zsh)"; fi
fi
