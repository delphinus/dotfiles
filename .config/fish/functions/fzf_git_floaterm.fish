function fzf_git_floaterm --description 'Open files shown by `git status`'
  set select (git -c color.status=always status -s -uall | \
    sort | \
    eval "fzf --ansi $FZF_DEFAULT_OPTS" | \
    cut -b4-
  )

  set st 0
  if test -n "$select"
    if test -f "$select"
      set_color brgreen
      echo "opening $select..."
      set_color normal
      floaterm "$select" > /dev/null
    else
      set_color brred
      echo "$select is not a file" 1>&2
      set st 1
    end
  end
  commandline -f repaint
  return $st
end
