#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# http://qiita.com/scalper/items/86da115e6c76a692d687
if [[ -n $ZPROF ]]; then
  zmodload zsh/zprof && zprof
fi

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# my setting

# do not register duplicated paths
typeset -U path cdpath fpath manpath

typeset -x H
H=${H:-$HOME}

path=
if [ -x /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
else
  path=(\
    /usr/local/bin\
    /usr/bin\
    /bin\
    /usr/sbin\
    /sbin\
    /opt/X11/bin\
    )
fi

path=(\
  $H/Dropbox/bin(N-/)\
  $H/bin(N-/)\
  $H/git/dotfiles/bin(N-/)\
  $H/.ghg/bin(N-/)\
  $path)

# for python
if which pyenv > /dev/null; then
  eval "$(pyenv init - --no-rehash zsh)"
else
  typeset -x PYENV_ROOT
  PYENV_ROOT=$HOME/.pyenv
  path=($PYENV_ROOT/bin(N-/) $path)
  if [ -x "$PYENV_ROOT/bin/pyenv" ]; then eval "$(pyenv init - --no-rehash zsh)"; fi
fi
if [[ $OSTYPE == darwin* ]]; then
  user_base="$HOME/Library/Python/2.7"
else
  user_base="$HOME/.local"
fi
path=($user_base/bin(N-/) $path)

# for ruby
if which rbenv > /dev/null; then
  eval "$(rbenv init - --no-rehash zsh)"
else
  typeset -x RBENV_ROOT
  RBENV_ROOT=$HOME/.rbenv
  path=($RBENV_ROOT/bin(N-/) $path)
  if [ -x "$RBENV_ROOT/bin/rbenv" ]; then eval "$(rbenv init - --no-rehash zsh)"; fi
fi

# for lua
if which luaenv > /dev/null; then
  eval "$(luaenv init - --no-rehash zsh)"
else
  typeset -x LUAENV_ROOT
  LUAENV_ROOT=$HOME/.luaenv
  path=($LUAENV_ROOT/bin(N-/) $path)
  if [ -x "$LUAENV_ROOT/bin/luaenv" ]; then eval "$(luaenv init -)"; fi
fi

# perl
if [ -d "$HOME/perl5" ]; then
  if [[ $OSTYPE == darwin* ]]; then
    arch=darwin-2level
  fi
  typeset -x PERL5LIB
  path=($HOME/perl5/bin(N-/) $path)
  PERL5LIB=(\
    $HOME/perl5/lib/perl5(N-/)\
    $HOME/perl5/lib/perl5/$arch/auto(N-/)\
    $PERL5LIB)
fi

# for perlbrew
if [[ $OSTYPE == darwin* && -f $HOME/perl5/perlbrew/etc/bashrc ]]; then
  source $HOME/perl5/perlbrew/etc/bashrc
  alias perl='perl -I$HOME/perl5/lib/perl5'
else
  # for plenv
  if which plenv > /dev/null; then
    eval "$(plenv init - zsh)"
  else
    typeset -x PLENV_ROOT
    PLENV_ROOT=$HOME/.plenv
    path=($PLENV_ROOT/bin(N-/) $path)
    if [ -x "$PLENV_ROOT/bin/plenv" ]; then eval "$(plenv init - --no-rehash zsh)"; fi
  fi
fi

# for go
typeset -x GOPATH
GOPATH=$H/.go
path=($GOPATH/bin(N-/) $path)
if which goenv > /dev/null; then
  eval "$(goenv init - --no-rehash zsh)"
else
  typeset -x GOENV_ROOT
  GOENV_ROOT=$HOME/.goenv
  path=($GOENV_ROOT/bin(N-/) $path)
  if [ -x "$GOENV_ROOT/bin/goenv" ]; then eval "$(goenv init - --no-rehash zsh)"; fi
fi

# for hub
if which hub > /dev/null; then
  alias git=hub
fi

# for nvm
if [ -d "$H/.nvm" ]; then
  typeset -x NVM_DIR
  NVM_DIR=$H/.nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# for Google Cloud SDK
typeset -x GCSDK_PATH GAE_ROOT
GCSDK_PATH=/usr/local/google-cloud-sdk
if [ -d "$GCSDK_PATH" ]; then
  source $GCSDK_PATH/path.zsh.inc
  # do not use original completions. it has redundant compinit.
  #source $GCSDK_PATH/completion.zsh.inc
  GAE_ROOT=$GCSDK_PATH/platform/google_appengine
  path=($GAE_ROOT(N-/) $path)
fi

typeset -x ZSHENV_LOADED PATH_IN_ZSHENV
ZSHENV_LOADED=1
PATH_IN_ZSHENV=$PATH
