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

source $H/git/dotfiles/.zsh/basic.zshrc
source $H/git/dotfiles/.zsh/peco-select-history.zsh
source $H/git/dotfiles/.zsh/peco-git.zsh
source $H/git/dotfiles/.zsh/peco-ghq.zsh
source $H/git/dotfiles/.zsh/peco-z.zsh
source $H/git/dotfiles/.zsh/peco-bundler.zsh
source $H/git/dotfiles/.zsh/peco-brew-directories.zsh
source $H/git/dotfiles/.zsh/peco-open-pullrequest.zsh
source $H/git/dotfiles/.zsh/set-ssh-auth-sock.sh
source $H/git/dotfiles/.zsh/export-alias.zsh
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
if which brew > /dev/null; then
  . $(brew --prefix)/etc/profile.d/z.sh
elif [ -f /etc/profile.d/z.sh ]; then
  . /etc/profile.d/z.sh
elif [ -f $(ghq list --full-path rupa/z)/z.sh ]; then
  . $(ghq list --full-path rupa/z)/z.sh
fi

# grc
# needed for prezto `git` module
if (( $+commands[grc] )); then
  unalias grc
fi
if which brew > /dev/null; then
  . $(brew --prefix)/etc/grc.bashrc
elif [ -f '/etc/profile.d/grc.bashrc' ]; then
  . /etc/profile.d/grc.bashrc
  manpath=(/usr/local/shae/man $manpath)
fi

# custom mysql
mysql_bin=/usr/local/opt/mysql/bin
if which mysql > /dev/null; then
  path=($path $mysql_bin(N-/))
else
  path=($mysql_bin(N-/) $path)
fi

# github access token
local homebrew_github_api_token=$H/.homebrew_github_api_token
if [ -f "$homebrew_github_api_token" ]; then
  . $homebrew_github_api_token
fi

# PHP composer
path=($H/.composer/vendor/bin(N-/) $path)

# node
path=(/usr/local/node/bin(N-/) $path)

# fssh
if [ -n "$TMUX" ]; then
  $H/git/dotfiles/bin/set_env_for_fssh.rb
fi

# local settings
zshrc_local=$H/.zshrc.local
if [ -f "$zshrc_local" ]; then
  . $zshrc_local
fi

# for vim solarized
typeset -x TERM_PROGRAM
TERM_PROGRAM=${TERM_PROGRAM:-iTerm.app}

# for GnuPG
# http://unix.stackexchange.com/questions/257061/gentoo-linux-gpg-encrypts-properly-a-file-passed-through-parameter-but-throws-i
typeset -x GPG_TTY
GPG_TTY=$(tty)

if type zprof > /dev/null 2>&1; then
  zprof | less
fi
