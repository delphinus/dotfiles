" <C-t> mapping will conflict with dwm.vim
" so remove it
nnoremap <buffer> <silent> gd :GoDef<cr>
nnoremap <buffer> <silent> <C-]> :GoDef<cr>
nnoremap <buffer> <silent> <C-w><C-]> :<C-u>call go#def#Jump("split")<CR>
nnoremap <buffer> <silent> <C-w>] :<C-u>call go#def#Jump("split")<CR>
set completeopt-=preview

call delphinus#colorscheme#setGoSameId()
