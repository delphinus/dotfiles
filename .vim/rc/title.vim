function! GetTitleString()
    " ³Æ¼ï¥Õ¥é¥°
    let modified = getbufvar('', '&mod') ? '+' : ''
    let readonly = getbufvar('', '&ro') ? '=' : ''
    let modifiable = getbufvar('', '&ma') ? '' : '-'
    let flag = modified . readonly . modifiable
    let flag = len(flag) ? ' ' . flag : ''
    " ¥Û¥¹¥ÈÌ¾
    let host = hostname() . ':'
    " ¥Õ¥¡¥¤¥ëÌ¾
    let filename = expand('%:t')
    " ¥Õ¥¡¥¤¥ëÌ¾¤¬¤Ê¤¤¾ì¹ç
    let filename = len(filename) ? filename : 'NEW FILE'
    " $H ¤¬ÀßÄê¤·¤Æ¤¢¤ë¾ì¹ç¤Ï¡¢¥Ñ¥¹Æâ¤òÃÖ´¹¤¹¤ë
    let sub_home = len($H) ? ':s!' . $H . '!$H!' : ''
    let dir = expand('%:p' . sub_home . ':~:.:h')
    " 'svn/game/' ¤ò¾Ã¤¹
    let dir = substitute(dir, 'svn/game/', '', '')
    " dir ¤ò³ç¸Ì¤Ç³ç¤ë
    let dir = len(dir) && dir != '.' ? ' (' . dir . ')' : ''
    " É½¼¨Ê¸»úÎó¤òºîÀ®
    let str = host . filename . flag . dir
    " win32 ¤Î»ş¡¢¥¿¥¤¥È¥ë¥Ğ¡¼¤Ë 2 ¥Ğ¥¤¥ÈÊ¸»ú¤¬¤¢¤Ã¤¿¤é²½¤±¤ë¤Î¤ÇÂĞ½è¤¹¤ë
    if !has('win32')
        let str2 = ''
        for char in split(str, '\zs')
            if char2nr(char) > 255
                let str2 = str2 . '_'
            else
                let str2 = str2 . char
            endif
        endfor
        let str = str2
    endif
    return str
endfunction

" ¥¿¥¤¥È¥ëÊ¸»úÎó»ØÄê
set titlestring=%{GetTitleString()}
if &term =~ '^screen'
    set t_ts=k
    set t_fs=\
endif
" ¥¦¥£¥ó¥É¥¦¥¿¥¤¥È¥ë¤ò¹¹¿·¤¹¤ë
if &term =~ '^screen' || &term =~ '^xterm'
    set title
endif

