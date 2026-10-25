# gh list-pr で選んだブランチが別の worktree にあれば、そこへ cd する。
# gh を関数で包み、gh list-pr のときだけ横取りする。
set -l ext ~/.local/share/gh/extensions/gh-list-pr/gh-list-pr
if status is-interactive; and test -x $ext
    __source_cached gh-list-pr $ext -- gh list-pr --init fish
end
