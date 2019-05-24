# These are derived from fzf original scripts
# {{{
source /usr/local/opt/fzf/shell/completion.zsh

export FZF_DEFAULT_OPTS='--border --inline-info --prompt="❯❯❯ "'

__fzf_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

# Ensure precmds are run after cd
fzf-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf-redraw-prompt
# }}}

function fzf-ghq() {
  setopt localoptions pipefail 2> /dev/null
  local selected_dir=$(
    ghq list --full-path |
    perl -pe "s|^$HOME|~|" |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS $FZF_CTRL_SQUARE_BRACKET_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd) |
    perl -pe "s|^~|$HOME|"
    )
  if [[ -z $selected_dir ]]; then
    zle redisplay
    return 0
  fi
  cd $(printf %q "$selected_dir")
  local ret=$?
  zle fzf-redraw-prompt
  return $ret
}
zle -N fzf-ghq
bindkey '^]' fzf-ghq

function fzf-ghq-dir() {
  setopt localoptions pipefail 2> /dev/null
  local selected_dir=$(
    ghq list --full-path |
    perl -pe "s|^$HOME|~|" |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS $FZF_CTRL_SQUARE_BRACKET_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)
    )
  zle redisplay
  if [[ -n $selected_dir ]]; then
    BUFFER="$BUFFER$selected_dir"
    CURSOR=$#BUFFER
  fi
}
zle -N fzf-ghq-dir
bindkey '^x^]' fzf-ghq-dir

function fzf-z() {
  local selected_dir=$(
    z |
    perl -pe "s|(?<=^.{11})$HOME|~|" |
    perl -pe 's|^([\d.]+)\s+(.*)$|sprintf "%5d  %s", $1, $2|e' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS -n2..,.. --query=${(qqq)LBUFFER} --tac +m" $(__fzfcmd) |
    perl -pe "s|^~|$HOME|"
    )
  echo $selected_dir
  if [[ -z $selected_dir ]]; then
    zle redisplay
    return 0
  fi
  echo cd $(printf %q "$selected_dir")
  local ret=$?
  zle fzf-redraw-prompt
  return $ret
}
zle -N fzf-z
bindkey '^t' fzf-z

function fzf-history() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [[ -n $selected ]]; then
    num=$selected[1]
    if [[ -n $num ]]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N fzf-history
bindkey '^r' fzf-history
