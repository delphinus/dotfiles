# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# disable <C-S><C-Q>
stty -ixon -ixoff
# disable <C-Z>
stty susp undef

#alias ls='ls -vGF'
#alias ll='ls -vGF -l'
#alias l.='ls -vGF -d .*'
alias ls='gls --color'
alias ll='gls --color -l'
alias l.='gls --color -d .*'
alias dircolors=gdircolors
eval `TERM=xterm-256color dircolors $HOME/git/dotfiles/submodules/dircolors-solarized/dircolors.ansi-dark`
alias dvtm="SHELL=/usr/local/bin/bash dvtm -m ^z"
alias dv="dtach -A /tmp/dvtm-session -r winch dvtm.sh"
#alias vim='mvim -v'
#alias gvim=mvim

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

# Bash prompts: showing the command in the window title :: Random notes from mg
# http://mg.pov.lt/blog/bash-prompt.html
#case "$TERM" in
#xterm*|rxvt*|dvtm*)
#    PROMPT_COMMAND='PS1="$YELLO_GREEN[\!] \`if [[ \$? = "0" ]]; then echo "\\e[38\\\;5\\\;119m"; else echo "\\e[38\\\;5\\\;196m"; fi\`[\u.\h: \`if [[ `pwd|wc -c|tr -d " "` > 50 ]]; then echo "\\W"; else pwd; fi\`]\n\[\e[0m\]\$ "'
#
#    # Show the currently running command in the terminal title:
#    # http://www.davidpashley.com/articles/xterm-titles-with-bash.html
#    show_command_in_title_bar()
#    {
#        case "$BASH_COMMAND" in
#            eval*|PS1*|*\033]0*)
#                # The command is trying to set the title bar as well;
#                # this is most likely the execution of $PROMPT_COMMAND.
#                # In any case nested escapes confuse the terminal, so don't
#                # output them.
#                ;;
#            *)
#                echo -ne "\033]0;${USER}@${HOSTNAME}: ${BASH_COMMAND}\007"
#                ;;
#        esac
#    }
#    trap show_command_in_title_bar DEBUG
#    ;;
#*)
#    ;;
#esac

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
export PATH="$HOME/Library/Python/2.7/bin:\
/usr/local/Cellar/ruby/2.0.0-p247/bin:\
$HOME/.gem/ruby/2.0.0/bin:\
/usr/local/mysql/bin:\
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

# for perlomni.vim
export PATH="$HOME/.vim/bundle/perlomni.vim/bin:$PATH"

export PYTHONPATH="$HOME/Library/Python/2.7/lib/python/site-packages"
export MYPERL=`which perl`

# for python
[[ -s $HOME/.pythonz/etc/bashrc ]] && source $HOME/.pythonz/etc/bashrc
source `which virtualenvwrapper.sh`
export WORKON_HOME=$HOME/.virtualenvs
export PIP_RESPECT_VIRTUALENV=true
workon 3.3.3

# powerline
. $HOME/git/powerline/powerline/bindings/bash/powerline.sh

# for plenv
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"

echo "$USER@$HOSTNAME"
