function fzf_ghq --description 'Move with FZF + ghq'
  set select (ghq list --full-path | \
    perl -pe 's,$ENV{HOME},~,' | \
    perl -MFile::Basename -pe '' | \
    eval "fzf $FZF_DEFAULT_OPTS")
  test -n "$select"
  and cd "$select"
  commandline -f repaint
end
