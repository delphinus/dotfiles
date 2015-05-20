function peco-z() {
  if ! which tac > /dev/null; then
    alias tac='tail -r'
    local aliased=1
  fi
  local selected_dir=${(@f)$(z | tac | cut -b 12- | peco --prompt "CD HISTORY>" --query "$LBUFFER")}
  if [ "$aliased" = 1 ]; then
    unalias tac
  fi
  if [ -n "$selected_dir" ]; then
    BUFFER="cd '${selected_dir}'"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-z
bindkey '^z' peco-z
bindkey '^t' peco-z
