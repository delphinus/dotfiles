# use neovim-remote in :terminal
if [[ -n $NVIM_LISTEN_ADDRESS ]]; then
  export VISUAL='nvr -c "se ro" -cc split --remote'
  export EDITOR='nvr -cc split --remote-wait'
  export GIT_EDITOR='nvr -cc split --remote-wait'
elif (( $+commands[nvim] )); then
  export VISUAL='nvim -R'
  export EDITOR=nvim
  export GIT_EDITOR=nvim
else
  export VISUAL=view
  export EDITOR=vim
  export GIT_EDITOR=vim
fi

export PAGER=less
export EDITRC=$HOME/.editrc
export INPUTRC=$HOME/.inputrc
export LANG=ja_JP.UTF-8
export GREP_OPTIONS="--color=auto"

if [[ $OSTYPE == darwin* ]]; then
  alias psl='ps -arcwwwxo "pid command %cpu %mem" | perl -pe "s/%(?=(?:cpu|mem))/ /ig" | grep -v grep | head -13'
  alias brew='TERM=xterm-256color brew'
  alias vagrant='TERM=xterm-256color vagrant'
fi

# needed for prezto `git` module
if (( $+commands[gls] )); then
  unalias gls
  alias ls='gls --group-directories-first --color=auto'
  alias dircolors=gdircolors
fi
eval `dircolors --sh $HOME/.dir_colors`
alias be='bundle exec'
alias ce='carton exec --'
alias dv="dtach -A /tmp/dvtm-session -r winch dvtm.sh"
alias dvim="dtach -A /tmp/vim-session -e \^\^ vim"
alias dvtm="SHELL=/bin/zsh dvtm -m ^z"
alias g=git
alias l.="l -d .*"
alias le='less -L'
alias lv='lv -c'
alias nr='npm run'
alias ns='npm start'
alias pp=prettyping
alias stripcolors='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?[mGK]//g"'
alias tm=tmux.sh
alias vp=vimpager
alias minvim='vim -N -u NONE -u NONE -i NONE --noplugin'
alias ra=ranger
alias pipes='pipes.sh -p 2 -t "c┃╭ ╮╯━╮  ╰┃╯╰ ╭━"'
alias m=memo
alias mn='memo n'
alias ml='memo l'
alias me='memo e'
alias mg='memo g'
alias mycli='LESS= mycli'
alias nvrs='nvr -cc split'

if (( $+commands[exa] )); then
  unalias l
  # use bin/l the executable
fi

code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# for NeoVim terminal
export VIM=
export VIMRUNTIME=
