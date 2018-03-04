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
  $H/bin(N-/)
  $H/git/dotfiles/bin(N-/)
  $H/.ghg/bin(N-/)
  $path)

# for python
if (( $+commands[pyenv] )); then
  eval "$(pyenv init - --no-rehash zsh)"
elif (( $+commands[python3.6] )); then
  if ! (( $+commands[python3] )); then
    mkdir -p $H/bin
    ln -s $(which python3.6) $H/bin/python3
  fi
  if ! (( $+commands[pip3] )); then
    mkdir -p $H/bin
    ln -s $(which pip3.6) $H/bin/pip3
  fi
else
  typeset -xT PYENV_ROOT pyenv_root
  pyenv_root=$HOME/.pyenv
  path=($pyenv_root/bin(N-/) $path)
  if [[ -x $pyenv_root/bin/pyenv ]]; then eval "$(pyenv init - --no-rehash zsh)"; fi
fi
if [[ $OSTYPE == darwin* ]]; then
  path=($HOME/Library/Python/{3.6,2.7}/bin(N-/) $path)
else
  path=($HOME/.local/bin(N-/) $path)
fi

# for ruby
if (( $+commands[rbenv] )); then
  eval "$(rbenv init - --no-rehash zsh)"
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
path=(/usr/local/opt/perl/bin(N-/) $path)

# for plenv
alias perl='perl -I$HOME/perl5/lib/perl5'
if (( $+commands[plenv] )); then
  eval "$(plenv init - zsh)"
else
  typeset -xT PLENV_ROOT plenv_root
  plenv_root=$HOME/.plenv
  path=($plenv_root/bin(N-/) $path)
  if [[ -x $plenv_root/bin/plenv ]]; then eval "$(plenv init - --no-rehash zsh)"; fi
fi

# for go
typeset -xT GOPATH gopath
gopath=$H/.go
path=($gopath/bin(N-/) $path)
if (( $+commands[goenv] )); then
  eval "$(goenv init - --no-rehash zsh)"
else
  typeset -xT GOENV_ROOT goenv_root
  goenv_root=$HOME/.goenv
  path=($goenv_root/bin(N-/) $path)
  if [[ -x $goenv_root/bin/goenv ]]; then eval "$(goenv init - --no-rehash zsh)"; fi
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
path=($H/usr{/local,}/bin(N-/) $path)

typeset -xT ZSHENV_LOADED zshenv_loaded
typeset -xT PATH_IN_ZSHENV path_in_zshenv
zshenv_loaded=1
path_in_zshenv=$PATH
