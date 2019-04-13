function peco-z() {
  # @f is a parameter cuts off the input lines into array.  This line below makes @f only cut
  # off by the newline character.
  local IFS=$'\n'
  local selected_dir=${(@f)$(z | sort -k1nr \
    | ruby -pe '$_.sub! /(?<=^.{11})#{ENV["HOME"]}/, "~"' \
    | ruby -pe '$_.sub!(/^([\d.]+)\s+(.*)$/) { "%5d  %s" % [$1.to_i, $2] }' \
    | fzf --no-sort --query "$LBUFFER" \
    | cut -b 8- \
    | ruby -pe '$_.sub! /^~/, ENV["HOME"]' \
    )}
  if [[ -n $selected_dir ]]; then
    BUFFER="cd $(printf %q "$selected_dir")"
    zle accept-line
  fi
}
zle -N peco-z
bindkey '^t' peco-z
