if exists('g:loaded_pastefire')
    finish
endif
let g:loaded_pastefire = 1

let s:save_cpo = &cpo
set cpo&vim

function! g:Pastefire(...)
    echo 'sending...'
    let tempfilename = tempname()
    call writefile(split(@", '\n'), tempfilename, 'b')
    let params = [
    \ 'cat %s | PERL5LIB=%s/perl5/lib/perl5 %s/git/dotfiles/bin/pastefire.pl',
    \ tempfilename, g:home, g:home]
    let ret = system(call(function('printf'), params))
    echo 'paste to pastefire'
endfunction

nnoremap <unique> <Plug>(pastefire) :<C-u>call g:Pastefire()<CR>

if !hasmapto('<Plug>(pastefire)')
    map <unique> <Leader>pf <Plug>(pastefire)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
