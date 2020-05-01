function fzf_pe --description 'Extract paths from input and open / edit them'
  set -l options 'e/editor'
  argparse $options -- $argv

  path-extractor | \
    eval (__fzfcmd)" $FZF_DEFAULT_OPTS" | \
    read -l select

  set -l st 0
  if test -n "$select"
    if set -q _flag_editor
      commandline $EDITOR" $select" ;and commandline -f execute
      set st $status
    else
      commandline -i "$select"
    end
  end
  commandline -f repaint
  return $st
end
