if has('mac')
    nmap <C-y> :Pbyank<CR>:echo 'yanked!'<CR>
    vmap <C-y> ;Pbyank<CR>:echo 'yanked!'<CR>
    nmap <C-S-y> :Pbpaste<CR>:echo 'pasted!'<CR>
endif
