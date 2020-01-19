function fzf_ghq --description 'Move with FZF + ghq'
  set select (ghq list --full-path | \
    perl -pe 's,$ENV{HOME},~,' | \
    eval "fzf $FZF_DEFAULT_OPTS" | \
    perl -pe 's/^~(\w*)/(getpwnam($1 || $ENV{USER}))[7]/e')
  test -n "$select"; and cd "$select"
  commandline -f repaint
end
