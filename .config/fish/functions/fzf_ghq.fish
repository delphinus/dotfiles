function fzf_ghq --description 'Move with FZF + ghq'
  set -l options 'i/insert'
  argparse $options -- $argv

  ghq list --full-path | \
    perl -pe 's,$ENV{HOME},~,' | \
    eval "fzf $FZF_DEFAULT_OPTS" | \
    perl -pe 's/^~(\w*)/(getpwnam($1 || $ENV{USER}))[7]/e' | \
    read -l select

  if test -n "$select"
    if set -q _flag_insert
      commandline -i "$select"
    else
      cd "$select"
      emit fish_prompt
    end
  end
  commandline -f repaint
end
