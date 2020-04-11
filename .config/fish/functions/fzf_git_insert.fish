function fzf_git_insert --description 'Insert the candidates by `git status`'
  set select (git -c color.status=always status -s -uall | \
    sort | \
    eval "fzf --ansi $FZF_DEFAULT_OPTS" | \
    cut -b4-
  )

  test -n "$select"; and commandline -i "$select"
  commandline -f repaint
end
