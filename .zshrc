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

if [ -n "$path_in_zshenv" ]; then
  export PATH=$path_in_zshenv
fi

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
  . /usr/local/etc/profile.d/z.sh
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
  . /usr/local/etc/grc.bashrc
elif [ -f '/etc/profile.d/grc.bashrc' ]; then
  . /etc/profile.d/grc.bashrc
  export MANPATH=/usr/local/share/man:$MANPATH
fi

# custom mysql
local mysql_bin=/usr/local/opt/mysql/bin
if [ -d "$mysql_bin" ] && which mysql > /dev/null; then
  export PATH=$PATH:$mysql_bin
else
  export PATH=$mysql_bin:$PATH
fi

# github access token
local homebrew_github_api_token=$H/.homebrew_github_api_token
if [ -f "$homebrew_github_api_token" ]; then
  . $homebrew_github_api_token
fi

# PHP composer
local composer_vender_bin=$H/.composer/vendor/bin
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
  local fssh_env=$H/git/dotfiles/bin/fssh_env
  if [ -f "$fssh_env" ]; then
    rm -f $fssh_env
  fi
  env | grep FSSH | ruby -pe '$_.sub!(/^(LC_FSSH_[A-Z_]*)=(.*)$/) { %Q[export #$1="#$2"] }' > $fssh_env
  chmod +x $fssh_env
fi

# local settings
local zshrc_local=$H/.zshrc.local
if [ -f "$zshrc_local" ]; then
  . $zshrc_local
fi

# for vim solarized
if [ -z "$TERM_PROGRAM" ]; then
  export TERM_PROGRAM=iTerm.app
fi

if type zprof > /dev/null 2>&1; then
  zprof | less
fi
