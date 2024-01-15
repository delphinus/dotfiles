# https://github.com/PatrickF1/fzf.fish/wiki/Cookbook#how-can-i-open-fzf-in-a-new-tmux-pane
function fzf --wraps=fzf --description="Use fzf-tmux if in tmux session"
    if set --query TMUX
        fzf-tmux $argv
    else
        command fzf $argv
    end
end
