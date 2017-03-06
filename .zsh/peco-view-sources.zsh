function peco-view-sources() {
    exec rg -n "$@" . | peco --exec 'awk -F : '"'"'{print "+" $2 " " $1}'"'"' 2>&1 | xargs -o view'
}
zle -N peco-view-sources
bindkey '^x^v' peco-view-sources
