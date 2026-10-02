# gh list-pr で選んだブランチが別の worktree にあれば、そこへ cd する。
# gh を関数で包み、gh list-pr のときだけ横取りする。
if status is-interactive; and test -d ~/.local/share/gh/extensions/gh-list-pr
    gh list-pr --init fish | source
end
