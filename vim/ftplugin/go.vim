" <C-t> mapping will conflict with dwm.vim
" so remove it
nnoremap <buffer> <silent> gd :GoDef<cr>
nnoremap <buffer> <silent> <C-]> :GoDef<cr>
nnoremap <buffer> <silent> <C-w><C-]> :<C-u>call go#def#Jump("split")<CR>
nnoremap <buffer> <silent> <C-w>] :<C-u>call go#def#Jump("split")<CR>

" Set guibg color for 24bit colorscheme
if &background == 'light'
    hi def goSameId term=bold cterm=bold ctermbg=14 guibg=#eeeaec
else
    hi def goSameId term=bold ctermbg=23 ctermfg=7 guifg=#eee8d5 guibg=#00533f
endif
