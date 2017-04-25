function peco-bundler () {
  local selected_dir=$(bundler show --paths | peco --query "$LBUFFER")
  if [[ -n $selected_dir ]]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-bundler
bindkey '^g' peco-bundler

function peco-bundler-dir () {
  local current_buffer=$BUFFER
  local selected_dir=$(bundler show --paths | peco --query)
  if [[ -n $selected_dir ]]; then
    BUFFER="${current_buffer}${selected_dir}"
    CURSOR=$#BUFFER
  fi
}
zle -N peco-bundler-dir
bindkey '^x^g' peco-bundler-dir
