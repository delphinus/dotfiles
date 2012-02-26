setl fdm=marker
if is_office
    setl noet
else
    setl et
endif
let b:current_compiler='perl'
execute 'setl mp=' . g:vim_home . '/vimparse.pl\ -c\ %\ $*'

if !exists('g:perl_flyquickfixmake')
    let g:perl_flyquickfixmake = 1
    au BufWritePost *.pm,*.pl,*.t silent make
endif
