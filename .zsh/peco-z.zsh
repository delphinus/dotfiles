function peco-z() {
  local selected_dir=$(z | cut -b 12- | peco --prompt "CD HISTORY>" --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-z
bindkey '^z' peco-z
bindkey '^t' peco-z
