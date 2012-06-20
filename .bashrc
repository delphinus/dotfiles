# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

#export TERM=xterm-256color

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

# http://henrik.nyh.se/2008/12/git-dirty-prompt
# http://www.simplisticcomplexity.com/2008/03/13/show-your-git-branch-name-in-your-prompt/
# username@Machine ~/dev/dir[master]$ # clean working directory
# username@Machine ~/dev/dir[master*]$ # dirty working directory

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)] /"
}

if [ -f ~/bin/git-completion.bash ]; then
    . ~/bin/git-completion.bash
fi

# User specific aliases and functions
PS1='\e[1;45m$(parse_git_branch)\e[m\e[1;47m[\u@\h \w]\e[m \e[1;31m\D{%x %p%l:%M}\e[m\n\$ '

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
