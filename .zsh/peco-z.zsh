function peco-z() {
  if ! which tac > /dev/null; then
    alias tac='tail -r'
    local aliased=1
  fi
  local selected_dir=${(@f)$(z | tac | \
    ruby -pe '$_.sub! /(?<=.{11})#{ENV["HOME"]}/, "~"' | \
    ruby -pe '$_.sub!(/^([\d.]+)\s+(.*)$/) { "%5d  %s" % [$1.to_i, $2] }' | \
    peco --prompt "CD HISTORY>" --query "$LBUFFER" | \
    cut -b 8- | \
    ruby -pe '$_.sub! /^~/, ENV["HOME"]' \
    )}
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
