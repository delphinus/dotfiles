function fzf_z --description 'Move with FZF + z'
  set -l options 'i/insert'
  argparse $options -- $argv

  z --list | \
    perl -pe 's,$ENV{HOME},~,' | \
    eval "fzf $FZF_DEFAULT_OPTS" | \
    cut -c12- | \
    perl -pe 's/^~(\w*)/(getpwnam($1 || $ENV{USER}))[7]/e' | \
    read -l select

  if test -n "$select"
    if set -q _flag_insert
      commandline -i "$select"
    else
      cd "$select"
    end
  end
  commandline -f repaint
  emit fish_prompt
end
