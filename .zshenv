#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# my setting

if [ -z "$H" ]; then
  export H=$HOME
fi

export PATH=
if [ -x /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
else
  export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin
fi

export PATH="\
$H/Dropbox/bin:\
$H/bin:\
$H/git/dotfiles/bin:\
$H/.ghg/bin:\
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
if which pyenv > /dev/null; then eval "$(pyenv init - --no-rehash zsh)"; fi
if [[ $OSTYPE == darwin* ]]; then
  user_base="$HOME/Library/Python/2.7"
else
  user_base="$HOME/.local"
fi
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
if which rbenv > /dev/null; then eval "$(rbenv init - --no-rehash zsh)"; fi

# for lua
if [ -d '/usr/local/opt/luaenv' ]; then
  export LUAENV_ROOT=/usr/local/opt/luaenv
else
  export LUAENV_ROOT=$HOME/.luaenv
fi
export PATH=$LUAENV_ROOT/bin:$PATH
alias lu=luaenv
alias luv='luaenv versions'
if which luaenv > /dev/null; then eval "$(luaenv init - --no-rehash zsh)"; fi

# perl
if [ -d "$HOME/perl5" ]; then
  if [[ $OSTYPE == darwin* ]]; then
    arch=darwin-2level
  fi
  export PATH=$HOME/perl5/bin:$PATH
  export PERL5LIB=$HOME/perl5/lib/perl5:$HOME/perl5/lib/perl5/$arch/auto:$PERL5LIB
fi

# for perlbrew
if [[ $OSTYPE == darwin* && -f $HOME/perl5/perlbrew/etc/bashrc ]]; then
  autoload -U compinit
  compinit -C
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
  if which plenv > /dev/null; then eval "$(plenv init - --no-rehash zsh)"; fi
fi

# for go
export GOPATH=$H/.go
export PATH=$GOPATH/bin:$PATH

#if [ -d /usr/local/opt/goenv ]; then
#  export GOENV_ROOT=/usr/local/opt/goenv
#else
#  export GOENV_ROOT=$H/.goenv
#fi
#export PATH=$GOENV_ROOT/bin:$PATH
#if which goenv > /dev/null; then eval "$(goenv init - --no-rehash zsh)"; fi

# for hub
if which hub > /dev/null; then
  alias git=hub
fi

# for nvm
if [ -d "$H/.nvm" ]; then
  export NVM_DIR=$H/.nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# for Google Cloud SDK
export GCSDK_PATH=/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
if [ -f "$GCSDK_PATH/path.zsh.inc" ]; then
  source $GCSDK_PATH/path.zsh.inc
  source $GCSDK_PATH/completion.zsh.inc
fi

export path_in_zshenv=$PATH
