function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    elif which gtac > /dev/null; then
        tac="gtac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | eval $tac | peco --query "$LBUFFER")
    CURSOR=$#BUFFER
}
zle -N peco-select-history
bindkey '^r' peco-select-history
