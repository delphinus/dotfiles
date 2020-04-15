function fzf_git_status --description 'List / open files shown by `git status`'
  set -l options 'e/editor'
  argparse $options -- $argv

  git -c color.status=always status -s -uall | \
    sort | \
    eval (__fzfcmd)" --ansi $FZF_DEFAULT_OPTS" | \
    cut -b4- | \
    read -l select

  set -l st 0
  if test -n "$select"
    if set -q _flag_editor
      commandline $EDITOR" $select" ;and commandline -f execute
      set st $sattus
    else
      commandline -i "$select"
    end
  end
  commandline -f repaint
  return $st
end
