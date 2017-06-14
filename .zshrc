#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# change shortcut for autosuggestion on prezto
bindkey '^e' autosuggest-accept

# disable some bindings
# expand-cmd-path
bindkey -r '^[e'
bindkey -r '^[E'

source $H/git/dotfiles/.zsh/basic.zshrc
source $H/git/dotfiles/.zsh/peco-select-history.zsh
source $H/git/dotfiles/.zsh/peco-git.zsh
source $H/git/dotfiles/.zsh/peco-ghq.zsh
source $H/git/dotfiles/.zsh/peco-z.zsh
source $H/git/dotfiles/.zsh/peco-bundler.zsh
source $H/git/dotfiles/.zsh/peco-brew-directories.zsh
source $H/git/dotfiles/.zsh/peco-open-pullrequest.zsh
source $H/git/dotfiles/.zsh/peco-view-sources.zsh
source $H/git/dotfiles/.zsh/set-ssh-auth-sock.zsh
source $H/git/dotfiles/.zsh/export-alias.zsh
source $H/git/dotfiles/.zsh/git-foresta.zsh
#source $H/git/dotfiles/.zsh/iterm2_shell_integration.zsh

PATH=${PATH_IN_ZSHENV:-$PATH}

# for Test::Pretty
export TEST_PRETTY_COLOR_NAME=BRIGHT_GREEN

# terminal-notifier
if [[ $OSTYPE == darwin* ]]; then
  # http://qiita.com/kei_s/items/96ee6929013f587b5878
  export SYS_NOTIFIER=/usr/local/bin/terminal-notifier
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
  source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh
fi

# z
if (( $+commands[brew] )); then
  . $(brew --prefix)/etc/profile.d/z.sh
elif [[ -f /etc/profile.d/z.sh ]]; then
  . /etc/profile.d/z.sh
else
  z=$(ghq list --full-path rupa/z)
  if [[ -f $z/z.sh ]]; then
    . $z/z.sh
  fi
fi

typeset -xT LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path
ld_library_path=($H/usr/lib(N-/) $ld_library_path)

# grc
# needed for prezto `git` module
if (( $+commands[grc] )); then
  unalias grc
fi
if (( $+commands[brew] )) && [[ -f $(brew --prefix)/etc/grc.bashrc ]]; then
  . $(brew --prefix)/etc/grc.bashrc
elif [[ -f /etc/profile.d/grc.bashrc ]]; then
  . /etc/profile.d/grc.bashrc
  manpath=(/usr/local/share/man(N-/) $manpath)
elif [[ -f $H/etc/profile.d/grc.bashrc ]]; then
  . $H/etc/profile.d/grc.bashrc
  manpath=($H/usr/share/man(N-/) $manpath)
fi

# custom mysql
mysql_bin=/usr/local/opt/mysql/bin
if (( $+commands[mysql] )); then
  path=($path $mysql_bin(N-/))
else
  path=($mysql_bin(N-/) $path)
fi

# github access token
local homebrew_github_api_token=$H/.homebrew_github_api_token
if [[ -f $homebrew_github_api_token ]]; then
  . $homebrew_github_api_token
fi

# PHP composer
path=($H/.composer/vendor/bin(N-/) $path)

# node
if (( $+commands[brew] )); then
  path=($(brew --prefix)/node/bin(N-/) $path)
fi

# fssh
if [[ -n $TMUX ]]; then
  $H/git/dotfiles/bin/set_env_for_fssh.rb
fi

# local settings
zshrc_local=$H/.zshrc.local
if [[ -f $zshrc_local ]]; then
  . $zshrc_local
fi

# for vim solarized
typeset -xT TERM_PROGRAM term_program
term_program=${term_program:-iTerm.app}

# for GnuPG
# http://unix.stackexchange.com/questions/257061/gentoo-linux-gpg-encrypts-properly-a-file-passed-through-parameter-but-throws-i
typeset -xT GPG_TTY gpg_tty
gpg_tty=$(tty)

# update powerline setting according to $COLORFGBG
if [[ -z $TMUX ]]; then
  local tmux_powerline_color=solarized
  if [[ $COLORFGBG = '11;15' ]]; then # for solarized light
    tmux_powerline_color=solarizedlight
  fi
  local config_json=$H/.config/powerline/config.json
  perl -i -0pe 's/(?<="tmux": \{\n\t\t\t"colorscheme": ")([^"]*)/'"$tmux_powerline_color"'/' $config_json
fi
