if [ "$H" != "$HOME" ]; then
  alias vim="vim -u $H/.vim/vimrc"
  alias git="HOME=$H git"
  alias ghq="HOME=$H ghq"
  alias tig="HOME=$H tig"
fi

export PAGER=vimpager
export VIMPAGER_RC=$H/.vim/vimpagerrc
export EDITOR=vim
export EDITRC=$H/.editrc
export INPUTRC=$H/.inputrc
export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export CURL_CA_BUNDLE=~/git/dotfiles/ca-bundle.crt

if [[ "$OSTYPE" == "darwin"* ]]; then
  LS=gls
  alias dircolors=gdircolors
  alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
  alias brew='TERM=xterm-256color brew'
  alias vagrant='TERM=xterm-256color vagrant'
else
  LS=ls
fi

eval `dircolors $H/git/dotfiles/submodules/dircolors-solarized/dircolors.ansi-dark`
alias be='bundle exec'
alias ce='carton exec --'
alias dv="dtach -A /tmp/dvtm-session -r winch dvtm.sh"
alias dvim="dtach -A /tmp/vim-session -e \^\^ vim"
alias dvtm="SHELL=/bin/zsh dvtm -m ^z"
alias g=git
alias gh=ghq
alias l.="$LS --color -d .*"
alias ll="$LS --color -l"
alias ls="$LS --color"
alias lv='lv -c'
alias stripcolors='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?[mGK]//g"'
alias tm="tmux_cmd='tmux -u2 -f $H/git/dotfiles/.tmux.conf' tmux.sh"
alias vp=vimpager
