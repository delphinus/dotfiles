if type gf | grep alias > /dev/null; then
  unalias gf
fi
if type gfa | grep alias > /dev/null; then
  unalias gfa
fi

function gf() { git-foresta --graph-symbol-merge='⍟' --style=1 $@ | less }
function gfa() { git-foresta --all --graph-symbol-merge='⍟' --style=1 $@ | less }
compdef _git gf=git-log
compdef _git gfa=git-log
