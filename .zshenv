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
if [[ $SHLVL -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
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
  path=(
    /usr{/local,}/bin
    /bin
    {/usr,}/sbin
    /opt/X11/bin
    )
fi

path=(
  $HOME/bin(N-/)
  $HOME/git/dotfiles/bin(N-/)
  $HOME/.ghg/bin(N-/)
  $path)

# for python
if (( $+commands[pyenv] )); then
  eval "$(pyenv init - --no-rehash zsh)"
elif (( $+commands[python3.7] )); then
  if ! (( $+commands[python3] )); then
    mkdir -p $HOME/bin
    ln -s $(which python3.7) $HOME/bin/python3
  fi
  if ! (( $+commands[pip3] )); then
    mkdir -p $HOME/bin
    ln -s $(which pip3.7) $HOME/bin/pip3
  fi
else
  typeset -xT PYENV_ROOT pyenv_root
  pyenv_root=$HOME/.pyenv
  path=($pyenv_root/bin(N-/) $path)
  if [[ -x $pyenv_root/bin/pyenv ]]; then eval "$(pyenv init - --no-rehash zsh)"; fi
fi
if [[ $OSTYPE == darwin* ]]; then
  path=($HOME/Library/Python/{3.7,2.7}/bin(N-/) $path)
else
  path=($HOME/.local/bin(N-/) $path)
fi

# for ruby
path=($HOME/.gem/ruby/2.3.0/bin(N-/) $path)
if (( $+commands[rbenv] )); then
  eval "$(rbenv init - --no-rehash zsh)"
elif [[ -x /usr/local/opt/ruby/bin/ruby ]]; then
  path=(/usr/local/opt/ruby/bin(N-/) $path)
else
  typeset -xT RBENV_ROOT rbenv_root
  rbenv_root=$HOME/.rbenv
  path=($rbenv_root/bin(N-/) $path)
  if [[ -x $rbenv_root/bin/rbenv ]]; then eval "$(rbenv init - --no-rehash zsh)"; fi
fi

# for lua
if (( $+commands[luaenv] )); then
  eval "$(luaenv init - --no-rehash zsh)"
else
  typeset -xT LUAENV_ROOT luaenv_root
  luaenv_root=$HOME/.luaenv
  path=($luaenv_root/bin(N-/) $path)
  if [ -x $luaenv_root/bin/luaenv ]; then eval "$(luaenv init -)"; fi
fi

# perl
if [[ -d $HOME/perl5 ]]; then
  if [[ $OSTYPE == darwin* ]]; then
    arch=darwin-2level
  fi
  typeset -xT PERL5LIB perl5lib
  path=($HOME/perl5/bin(N-/) $path)
  perl5lib=(
    $HOME/perl5/lib/perl5(N-/)
    $HOME/perl5/lib/perl5/$arch/auto(N-/)
    $perl5lib)
fi

# for plenv
alias perl='perl -I$HOME/perl5/lib/perl5'
if (( $+commands[plenv] )); then
  eval "$(plenv init - zsh)"
elif [[ -x /usr/local/opt/perl/bin/perl ]]; then
  path=(/usr/local/opt/perl/bin(N-/) $path)
else
  typeset -xT PLENV_ROOT plenv_root
  plenv_root=$HOME/.plenv
  path=($plenv_root/bin(N-/) $path)
  if [[ -x $plenv_root/bin/plenv ]]; then eval "$(plenv init - --no-rehash zsh)"; fi
fi

# for go
typeset -xT GO111MODULE go111module
go111module=on
typeset -xT GOPATH gopath
gopath=$HOME/.go
path=($gopath/bin(N-/) $path)
if (( $+commands[goenv] )); then
  export GOENV_GOPATH_PREFIX=$gopath
  eval "$(goenv init - --no-rehash zsh)"
else
  typeset -xT GOENV_ROOT goenv_root
  goenv_root=$HOME/.goenv
  path=($goenv_root/bin(N-/) $path)
  if [[ -x $goenv_root/bin/goenv ]]; then eval "$(goenv init - --no-rehash zsh)"; fi
fi

# for Node.js
if (( $+commands[nodenv] )); then
  eval "$(nodenv init - --no-rehash zsh)"
elif [[ -f /usr/local/opt/nvm/nvm.sh ]]; then
  typeset -xT NVM_DIR nvm_dir
  nvm_dir=$HOME/.nvm
  mkdir -p $nvm_dir
  # https://qiita.com/uasi/items/80865646607b966aedc8
  # pseudo nvm() to delay initialization until nvm() is executed
  nvm() {
    source /usr/local/opt/nvm/nvm.sh
    nvm "$@"
  }
fi

# for hub
if (( $+commands[hub] )); then
  alias git=hub
fi

# for Rust
if [[ -d $HOME/.cargo/bin ]]; then
  path=($HOME/.cargo/bin $path)
fi

# home usr directory
path=($HOME/usr{/local,}/bin(N-/) $path)

typeset -xT ZSHENV_LOADED zshenv_loaded
typeset -xT PATH_IN_ZSHENV path_in_zshenv
zshenv_loaded=1
path_in_zshenv=$PATH
