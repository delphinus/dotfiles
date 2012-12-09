"-----------------------------------------------------------------------------
" vim-powerline
let g:Powerline_symbols = 'fancy'
let g:Powerline_theme = 'custom'
let g:Powerline_colorscheme = 'solarized16'

if g:is_remora
    let g:Powerline_symbols = 'compatible'
endif

" sunset.vim との絡みで警告が毎回出て鬱陶しいので警告なしバージョンを再定義する
function! Pl#ClearCache() " {{{
    if filereadable(g:Powerline_cache_file)
        " Delete the cache file
        call delete(g:Powerline_cache_file)
    endif
endfunction " }}}

" sunset.vim 起動時に powerline がうまく描画されないのでもう一度読み込む
if has('gui')
    autocmd GUIEnter * :PowerlineReloadColorscheme
endif
