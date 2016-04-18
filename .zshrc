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
source $H/git/dotfiles/.zsh/set-ssh-auth-sock.sh
source $H/git/dotfiles/.zsh/export-alias.zsh
