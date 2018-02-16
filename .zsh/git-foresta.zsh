if (( $+commands[git-foresta] )); then
  if type gf | grep alias > /dev/null; then
    unalias gf
  fi
  if type gfa | grep alias > /dev/null; then
    unalias gfa
  fi

  function gf() { git-foresta $@ | less }
  function gfa() { git-foresta --all $@ | less }
  compdef _git gf=git-log
  compdef _git gfa=git-log
fi
