function peco-select-history() {
    local tac
    if (( $+commands[tac] )); then
        tac="tac"
      elif (( $+commands[gtac] )); then
        tac="gtac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | eval $tac | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
}
zle -N peco-select-history
bindkey '^r' peco-select-history
