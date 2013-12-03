# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# disable <C-S><C-Q>
stty -ixon -ixoff

#alias ls='ls -vGF'
#alias ll='ls -vGF -l'
#alias l.='ls -vGF -d .*'
alias ls='gls --color'
alias ll='gls --color -l'
alias l.='gls --color -d .*'
alias dircolors=gdircolors
alias dvtm="SHELL=/usr/local/bin/bash dvtm -m ^z"
alias dv="dtach -c /tmp/dvtm-session -r winch 'SHELL=/usr/local/bin/bash dvtm -m ^z'"
alias vim='mvim -v'
alias gvim=mvim

export PAGER='vimpager'
alias vp='vimpager'
alias perldoc='perldocjp -J'
alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
#export EDITOR=/usr/local/bin/mvim
#export VISUAL=$EDITOR
#export SUDO_EDITOR=$EDITOR
export H=$HOME
export ACK_PAGER='less -R'
alias tmux="TERM=screen-256color-bce tmux -f $HOME/git/dotfiles/.tmux.conf"

. /usr/local/etc/bash_completion.d/git-completion.bash
. /usr/local/etc/bash_completion.d/git-prompt.sh
. /usr/local/etc/bash_completion.d/git-flow-completion.bash
. /usr/local/etc/bash_completion.d/tmux

# unstated (*) stated (+)
export GIT_PS1_SHOWDIRTYSTATE=1
# stashed ($)
export GIT_PS1_SHOWSTASHSTATE=1
# untracked (%)
export GIT_PS1_SHOWUNTRACKEDFILES=1
# upstream (<=>)
export GIT_PS1_SHOWUPSTREAM="verbose"

YELLO_GREEN="\e[38;5;190m"
PROMPT_COMMAND='PS1="$YELLO_GREEN[\!] \e[38;5;83m$(__git_ps1 "[%s]") \`if [[ \$? = "0" ]]; then echo "\\e[38\\\;5\\\;119m"; else echo "\\e[38\\\;5\\\;196m"; fi\`[\u.\h: \`if [[ `pwd|wc -c|tr -d " "` > 50 ]]; then echo "\\W"; else echo "\\w"; fi\`]\e[0m\n\$ "; echo -ne "\e]0;`hostname -s`:`pwd`\007"'

#export MY_PERL_LOCAL_LIB="$HOME/perl5/libs/"
#locallib() {
#    eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$MY_PERL_LOCAL_LIB/$1)
#}

for i in autocd cdable_vars cdspell checkwinsize cmdhist dirspell expand_aliases extglob extquote force_fignore globstar hostcomplete interactive_comments progcomp promptvars sourcepath
do
	shopt -s $i
done

export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export PATH="$HOME/Library/Python/2.7/bin:/usr/local/Cellar/ruby/2.0.0-p247/bin:$HOME/.gem/ruby/2.0.0/bin:/usr/local/mysql/bin:$HOME/Dropbox/bin:$HOME/bin:/usr/local/sbin:/usr/local/bin:/bin:/usr/sbin:/sbin:/usr/bin:/usr/X11/bin"

# for perlomni.vim
export PATH="$HOME/.vim/bundle/perlomni.vim/bin:$PATH"

export PYTHONPATH="$HOME/Library/Python/2.7/lib/python/site-packages"
export MYPERL=`which perl`

eval `TERM=xterm-256color dircolors $HOME/git/dotfiles/submodules/dircolors-solarized/dircolors.ansi-dark`

# powerline
#. $PYTHONPATH/powerline/bindings/bash/powerline.sh

# for plenv
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"
