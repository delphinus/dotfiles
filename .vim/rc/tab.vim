"-----------------------------------------------------------------------------
" タブバー設定
"-----------------------------------------------------------------------------

" タブ移動
" 右のタブへ移動
nnoremap <S-Tab> gt
" 左のタブへ移動
nnoremap <Tab><Tab> gT
" 1 番目～ 9 番目のタブへ移動
for i in range(1, 9)
    execute 'nnoremap <Tab>' . i . ' ' . i . 'gt'
endfor
" 現在のタブを右へ移動
nnoremap <Tab>n :MyTabMoveRight<CR>
" 現在のタブを左へ移動
nnoremap <Tab>p :MyTabMoveLeft<CR>

command! -count=1 MyTabMoveRight call MyTabMove(<count>)
command! -count=1 MyTabMoveLeft  call MyTabMove(-<count>)

function! MyTabMove(c)
    let current = tabpagenr()
    let max = tabpagenr('$')
    let target = a:c > 1       ? current + a:c - line('.') :
                \ a:c == 1     ? current :
                \ a:c == -1    ? current - 2 :
                \ a:c < -1     ? current + a:c + line('.') - 2 : 0
    let target = target >= max ? target % max :
                \ target < 0   ? target + max :
                \ target
    execute ':tabmove ' . target
endfunction
