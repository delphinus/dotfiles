# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

export TERM=xterm-256color

alias ls='ls -vGF'
alias ll='ls -vGF -l'
alias l.='ls -vGF -d .*'

alias vi='/Applications/MacVim.app/Contents/MacOS/Vim'
alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias gvim='open -a /Applications/MacVim.app "$@"'
export PAGER='vimpager'
#export PAGER=less
alias vp='vimpager'
alias perldoc='perldocjp -J'
export EDITOR='/Applications/MacVim.app/Contents/MacOS/Vim'
export VISUAL='/Applications/MacVim.app/Contents/MacOS/Vim'
export SUDO_EDITOR='/Applications/MacVim.app/Contents/MacOS/Vim'

if [ -f $H/bin/git-completion.bash ]; then
    . $H/bin/git-completion.bash
    # unstated (*) stated (+)
    export GIT_PS1_SHOWDIRTYSTATE=1
    # stashed ($)
    export GIT_PS1_SHOWSTASHSTATE=1
    # untracked (%)
    export GIT_PS1_SHOWUNTRACKEDFILES=1
    # upstream (<=>)
    export GIT_PS1_SHOWUPSTREAM="verbose"
    PS1='\e[1;45m$(__git_ps1 "[%s] ")\e[1;47m[\u@\h \w]\e[m \e[1;31m\D{%x %p%l:%M}\e[m\n\$ '
else
    PS1='\e[1;47m[\u@\h \w] \e[1;31m\D{%x %p%l:%M}\e[m\n\$ '
fi

export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="$HOME/build/rakudo-star-2011.04/install/bin:/usr/local/mysql/bin:$HOME/Dropbox/bin:$HOME/bin:/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin:/usr/X11/bin"
export PROMPT_COMMAND="echo -ne '\033k\033\'"
#export proxy=http://127.0.0.1:8123/
#export http_proxy=$proxy
#export ALL_PROXY=$proxy
source $HOME/perl5/perlbrew/etc/bashrc
source $HOME/.pythonbrew/etc/bashrc
source $HOME/bin/bash_completion_tmux.sh
