function fzf_z --description 'Move with FZF + z'
  set select (z --list | perl -pe 's,$ENV{HOME},~,' | eval "fzf $FZF_DEFAULT_OPTS" | cut -c12-)
  test -n "$select" ;and cd "$select"
  commandline -f repaint
end
