function peco-brew-directories () {
  local selected_dir=$(brew directories | fzf --query "$LBUFFER")
  if [[ -n $selected_dir ]]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-brew-directories
#bindkey '^k' peco-brew-directories

function peco-brew-directories-dir () {
  local current_buffer=$BUFFER
  local selected_dir=$(brew directories | fzf --query)
  if [[ -n $selected_dir ]]; then
    BUFFER="${current_buffer}${selected_dir}"
    CURSOR=$#BUFFER
  fi
}
zle -N peco-brew-directories-dir
bindkey '^x^k' peco-brew-directories-dir
