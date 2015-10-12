" dwm.vim mapping
nnoremap <C-J> <C-W>w
nnoremap <C-K> <C-W>W
nmap <C-T> <Plug>DWMRotateClockwise
nmap <C-Q> <Plug>DWMRotateCounterclockwise
nmap <C-N> <Plug>DWMNew
nmap <C-C> <Plug>DWMClose
nmap <C-@> <Plug>DWMFocus
nmap <C-Space> <Plug>DWMFocus
nmap <C-L> <Plug>DWMGrowMaster
nmap <C-H> <Plug>DWMShrinkMaster
nmap <BS>  <Plug>DWMShrinkMaster

nnoremap <silent> <Plug>DWMSetMasterPaneWidth :call delphinus#dwm#set_master_pane_width()<CR>
nmap <D-@> <Plug>DWMSetMasterPaneWidth
