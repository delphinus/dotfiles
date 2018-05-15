" for gometalinter
let s:lacked_packages = {
      \ 'dupl':        ['github.com/mibk/dupl'],
      \ 'gocyclo':     ['github.com/alecthomas/gocyclo'],
      \ 'gotype':      ['golang.org/x/tools/cmd/gotype'],
      \ 'ineffassign': ['github.com/gordonklaus/ineffassign'],
      \ 'gas':         ['github.com/GoASTScanner/gas'],
      \ 'lll':         ['github.com/walle/lll/cmd/lll'],
      \ 'goconst':     ['github.com/jgautheron/goconst/cmd/goconst'],
      \ 'misspell':    ['github.com/client9/misspell/cmd/misspell'],
      \ }

function! delphinus#go#install_tester_binaries(isUpdate) abort
  let opt = a:isUpdate ? '-u' : ''
  for [binary, pkg] in items(s:lacked_packages)
    if !a:isUpdate && executable(binary)
      echo binary . ' is already installed'
      continue
    endif
    for p in pkg
      echo binary . ': installing...'
      call go#util#System(printf('go get %s %s', opt, shellescape(p)))
    endfor
  endfor
endfunction
