function peco-src () {
  local selected_dir=$(ghq list --full-path | fzf --query "$LBUFFER")
  if [[ -n $selected_dir ]]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-src
bindkey '^]' peco-src

function peco-src-dir () {
  local current_buffer=$BUFFER
  local selected_dir=$(ghq list --full-path | fzf)
  if [[ -n $selected_dir ]]; then
    BUFFER="${current_buffer}${selected_dir}"
    CURSOR=$#BUFFER
  fi
}
zle -N peco-src-dir
bindkey '^x^]' peco-src-dir
