source $H/git/dotfiles/.zsh/basic.zshrc
source $H/git/dotfiles/.zsh/peco-select-history.zsh
source $H/git/dotfiles/.zsh/peco-git.zsh
source $H/git/dotfiles/.zsh/peco-ghq.zsh
source $H/git/dotfiles/.zsh/peco-z.zsh
source $H/git/dotfiles/.zsh/peco-bundler.zsh
source $H/git/dotfiles/.zsh/peco-brew-directories.zsh
source $H/git/dotfiles/.zsh/set-ssh-auth-sock.sh
source $H/git/dotfiles/.zsh/export-alias.zsh

if [ -n "$path_in_zshenv" ]; then
  export PATH=$path_in_zshenv
fi

# for perlomni.vim
export PATH="$H/.vim/bundle/perlomni.vim/bin:$PATH"

# for Test::Pretty
export TEST_PRETTY_COLOR_NAME=BRIGHT_GREEN

# terminal-notifier
if [[ "$OSTYPE" == "darwin"* ]]; then
  # http://qiita.com/kei_s/items/96ee6929013f587b5878
  export SYS_NOTIFIER=/usr/local/bin/terminal-notifier
  export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
  source ~/git/dotfiles/.zsh/zsh-notify/notify.plugin.zsh
fi

# powerline
#module_path=($module_path /usr/local/lib/zpython)
user_site=`python -c 'import site;import sys;sys.stdout.write(site.USER_SITE)'`
. $user_site/powerline/bindings/zsh/powerline.zsh

# z
if which brew > /dev/null; then
  . `brew --prefix`/etc/profile.d/z.sh
elif [ -f /etc/profile.d/z.sh ]; then
  . /etc/profile.d/z.sh
elif [ -f $(ghq list --full-path rupa/z)/z.sh ]; then
  . $(ghq list --full-path rupa/z)/z.sh
fi

# grc
if which brew > /dev/null; then
  . "`brew --prefix`/etc/grc.bashrc"
elif [ -f '/etc/profile.d/grc.bashrc' ]; then
  . /etc/profile.d/grc.bashrc
  export MANPATH=/usr/local/share/man:$MANPATH
fi

# ansible
if which brew > /dev/null; then
else
  export ANSIBLE_PATH=$(ghq list --full-path ansible)
  export PATH=$ANSIBLE_PATH/bin:$PATH
  export PYTHONPATH=$ANSIBLE_PATH/lib
  export MANPATH=$ANSIBLE_PATH/docs/man:$MANPATH
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
  env | grep FSSH | ruby -pe '$_.sub!(/^(LC_FSSH_[A-Z_]*)=(.*)$/) { %Q[export #$1="#$2"] }' > $fssh_env
  chmod +x $fssh_env
fi

# local settings
local zshrc_local=$H/.zshrc.local
if [ -f "$zshrc_local" ]; then
  . $zshrc_local
fi
