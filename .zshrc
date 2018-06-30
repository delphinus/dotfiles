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

source $HOME/git/dotfiles/.zsh/basic.zshrc
source $HOME/git/dotfiles/.zsh/peco-select-history.zsh
source $HOME/git/dotfiles/.zsh/peco-git.zsh
source $HOME/git/dotfiles/.zsh/peco-ghq.zsh
source $HOME/git/dotfiles/.zsh/peco-z.zsh
source $HOME/git/dotfiles/.zsh/peco-bundler.zsh
source $HOME/git/dotfiles/.zsh/peco-brew-directories.zsh
source $HOME/git/dotfiles/.zsh/peco-open-pullrequest.zsh
source $HOME/git/dotfiles/.zsh/peco-view-sources.zsh
source $HOME/git/dotfiles/.zsh/set-ssh-auth-sock.zsh
source $HOME/git/dotfiles/.zsh/export-alias.zsh
source $HOME/git/dotfiles/.zsh/git-foresta.zsh
source $HOME/git/dotfiles/.zsh/iterm2.zsh
#source $HOME/git/dotfiles/.zsh/iterm2_shell_integration.zsh

PATH=${PATH_IN_ZSHENV:-$PATH}

# for Test::Pretty
export TEST_PRETTY_COLOR_NAME=BRIGHT_GREEN

# terminal-notifier
if [[ $OSTYPE == darwin* ]]; then
  # http://qiita.com/kei_s/items/96ee6929013f587b5878
  typeset -xT SYS_NOTIFIER sys_notifier
  SYS_NOTIFIER=$(which terminal-notifier)
  typeset -xT NOTIFY_COMMAND_COMPLETE_TIMEOUT notify_command_complete_timeout
  NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
  source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh
fi

# z
if (( $+commands[brew] )); then
  . $(brew --prefix)/etc/profile.d/z.sh
elif [[ -f /etc/profile.d/z.sh ]]; then
  . /etc/profile.d/z.sh
elif (( $+commands[ghq] )); then
  z=$(ghq list --full-path rupa/z)
  if [[ -f $z/z.sh ]]; then
    . $z/z.sh
  fi
fi

typeset -xT LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path
ld_library_path=($HOME/usr/lib(N-/) $ld_library_path)

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
elif [[ -f $HOME/usr/etc/profile.d/grc.bashrc ]]; then
  . $HOME/usr/etc/profile.d/grc.bashrc
  manpath=($HOME/usr/share/man(N-/) $manpath)
fi

# custom mysql
mysql_bin=/usr/local/opt/mysql/bin
if (( $+commands[mysql] )); then
  path=($path $mysql_bin(N-/))
else
  path=($mysql_bin(N-/) $path)
fi

# github access token
local homebrew_github_api_token=$HOME/.homebrew_github_api_token
if [[ -f $homebrew_github_api_token ]]; then
  . $homebrew_github_api_token
fi

# PHP composer
path=($HOME/.composer/vendor/bin(N-/) $path)

# node
if (( $+commands[brew] )); then
  path=($(brew --prefix)/node/bin(N-/) $path)
fi

# fssh
if [[ -n $TMUX ]]; then
  $HOME/git/dotfiles/bin/set_env_for_fssh.rb
fi

# local settings
zshrc_local=$HOME/.zshrc.local
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

# for direnv
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# for Google Cloud SDK
typeset -xT GCSDK_PATH gcsdk_path
typeset -xT GAE_ROOT gae_root
gcsdk_path=/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk
if [[ -d $gcsdk_path ]]; then
  gae_root=$gcsdk_path/platform/google_appengine
  path=(
    $gae_root(N-/)
    $gcsdk_path/bin(N-/)
    $path)
  source $gcsdk_path/completion.zsh.inc
fi

# for kubectl
if (( $+commands[kubectl] )); then
  source <(kubectl completion zsh)
fi

# for grep
export GREP_COLOR='3;4;93'          # BSD.
export GREP_COLORS="mt=$GREP_COLOR" # GNU.

# for 3llo - the client for Trello
if [[ -f $HOME/.3llo ]]; then
  source $HOME/.3llo
fi

# if in NeoVim, set chpwd function
neovim-pwd() {
  (( $+commands[neovim_pwd.py] )) && neovim_pwd.py -v
}
if [[ -n $NVIM_LISTEN_ADDRESS ]]; then
  neovim-pwd
  chpwd_functions+=( neovim-pwd )
fi

# http://qiita.com/scalper/items/86da115e6c76a692d687
if which zprof > /dev/null 2>&1; then
  zprof
fi
