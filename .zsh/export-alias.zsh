if [ "$H" != "$HOME" ]; then
  alias vim="/usr/local/bin/vim -u $H/.vim/vimrc"
  alias view="/usr/local/bin/view -u $H/.vim/vimrc"
  alias gh="HOME=$H gh"
  alias ghq="HOME=$H ghq"
  alias ghg="HOME=$H ghg"
  alias tig="HOME=$H tig"
  export VISUAL=view.sh
  export EDITOR=vim.sh
  if which hub > /dev/null; then
    alias git="HOME=$H hub"
  else
    alias git="HOME=$H git"
  fi
else
  export VISUAL=view
  export EDITOR=vim
fi

export PAGER=less
export EDITRC=$H/.editrc
export INPUTRC=$H/.inputrc
export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"
export CURL_CA_BUNDLE=~/git/dotfiles/ca-bundle.crt

if [[ $OSTYPE == darwin* ]]; then
  alias psl='ps -arcwwwxo "pid command %cpu %mem" | grep -v grep | head -13'
  alias brew='TERM=xterm-256color brew'
  alias vagrant='TERM=xterm-256color vagrant'
fi

# needed for prezto `git` module
if (( $+commands[gls] )); then
  unalias gls
  alias ls='gls --group-directories-first --color=auto'
  alias dircolors=gdircolors
fi
eval `dircolors --sh $H/.dir_colors`
alias be='bundle exec'
alias ce='carton exec --'
alias dv="dtach -A /tmp/dvtm-session -r winch dvtm.sh"
alias dvim="dtach -A /tmp/vim-session -e \^\^ vim"
alias dvtm="SHELL=/bin/zsh dvtm -m ^z"
alias g=git
alias l.="ls -d .*"
alias le='less -L'
alias lv='lv -c'
alias nr='npm run'
alias ns='npm start'
alias pp=prettyping
alias stripcolors='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?[mGK]//g"'
alias tm="tmux_cmd='tmux -u2 -f $H/git/dotfiles/.tmux.conf' tmux.sh"
alias vp=vimpager
alias minvim='vim -N -u NONE -u NONE -i NONE --noplugin'
alias ra=ranger

code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}
