if has('mac')
    nmap <A-y> :Pbyank<CR>:echo 'yanked!'<CR>
    vmap <A-y> ;Pbyank<CR>:echo 'yanked!'<CR>
    nmap <A-S-y> :Pbpaste<CR>:echo 'pasted!'<CR>
endif
