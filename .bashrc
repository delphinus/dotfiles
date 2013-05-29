# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

#export TERM=xterm-256color

#alias ls='ls -vGF'
#alias ll='ls -vGF -l'
#alias l.='ls -vGF -d .*'
alias ls='gls --color'
alias ll='gls --color -l'
alias l.='gls --color -d .*'
alias dircolors=gdircolors

alias vi='/Applications/MacVim.app/Contents/MacOS/Vim'
alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias gvim='open -a /Applications/MacVim.app "$@"'
export PAGER='vimpager'
#export PAGER=less
alias vp='vimpager'
alias perldoc='perldocjp -J'
alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
export EDITOR='/Applications/MacVim.app/Contents/MacOS/Vim'
export VISUAL='/Applications/MacVim.app/Contents/MacOS/Vim'
export SUDO_EDITOR='/Applications/MacVim.app/Contents/MacOS/Vim'
export H=$HOME
alias tmux="TERM=screen-256color-bce tmux -f $HOME/git/dotfiles/.tmux.conf"

#export MY_PERL_LOCAL_LIB="$HOME/perl5/libs/"
. /usr/local/etc/bash_completion.d/git-completion.bash

#locallib() {
#    eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$MY_PERL_LOCAL_LIB/$1)
#}

for i in autocd cdable_vars cdspell checkwinsize cmdhist dirspell expand_aliases extglob extquote force_fignore globstar hostcomplete interactive_comments progcomp promptvars sourcepath
do
	shopt -s $i
done

export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="$HOME/Library/Python/2.7/bin:/usr/local/mysql/bin:$HOME/Dropbox/bin:$HOME/bin:/usr/local/sbin:/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin:/usr/X11/bin"
#export PROMPT_COMMAND="echo -ne '\033k\033\'"
export PYTHONPATH="$HOME/Library/Python/2.7/lib/python/site-packages"
#export proxy=http://127.0.0.1:8123/
#export http_proxy=$proxy
#export ALL_PROXY=$proxy
source $HOME/perl5/perlbrew/etc/bashrc
export MYPERL=`which perl`
source $HOME/bin/bash_completion_tmux.sh

source $HOME/git/dotfiles/.tmux/bash_completion_tmux.sh
eval `dircolors $HOME/git/dotfiles/dircolors-solarized/dircolors.ansi-dark`

# powerline
. $PYTHONPATH/powerline/bindings/bash/powerline.sh
