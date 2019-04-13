function peco-open-pullrequest() {
  echo
  echo "searching..."
  local selected_pr=${(@f)$(gh pr \
    | perl -ne 'if (/^(#\d+)\s+(.*)\s+(@[-\w]+)\s+(\(.*\))/) { print qq{$1 $base $2 $3 $4\n} } elsif (/^(\w+)/) { $base = $1 }' \
    | fzf \
    )}
  if [ -n "$selected_pr" ]; then
    if (( $+commands[lycia] )); then
      echo "opening $selected_pr"
      lycia p $(echo $selected_pr | perl -pe 's/#(\d+).*/$1/s')
      echo
    else
      echo $selected_pr
    fi
  fi
}
zle -N peco-open-pullrequest
bindkey '^x^p' peco-open-pullrequest
