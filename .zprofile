# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi

export PAGER=vimpager
export VIMPAGER_RC=$HOME/.vim/vimpagerrc
export ACK_PAGER='less -R'
export EDITOR=vim
export EDITRC=$HOME/.editrc
export INPUTRC=$HOME/.inputrc
export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="/usr/local/mysql/bin:\
$HOME/Dropbox/bin:\
$HOME/bin:\
$HOME/git/dotfiles/bin:\
/usr/local/sbin:\
/usr/local/bin:\
/bin:\
/usr/sbin:\
/sbin:\
/usr/bin:\
/usr/X11/bin"
export PATH=$HOME/Library/Python/2.7/bin:$PATH
export PATH="$HOME/.vim/bundle/perlomni.vim/bin:$PATH"
export PYENV_ROOT=/usr/local/opt/pyenv
export PATH=$PYENV_ROOT/bin:$PATH
export RBENV_ROOT=/usr/local/opt/rbenv
export PATH=$RBENV_ROOT/bin:$PATH
export PLENV_ROOT=/usr/local/opt/plenv
export PATH=$PLENV_ROOT/bin:$PATH
export SYS_NOTIFIER=/usr/local/bin/terminal-notifier
export NOTIFY_COMMAND_COMPLETE_TIMEOUT=30
export CURL_CA_BUNDLE=~/git/dotfiles/ca-bundle.crt
