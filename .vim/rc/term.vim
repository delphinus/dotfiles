"-----------------------------------------------------------------------------
" Vimからクリップボードインテグレーションシーケンス(PASTE64/OSC52)を利用する
" http://qiita.com/kefir_/items/515ed5264fce40dec522
function! s:MakeTmpFile(txt)
    let tmpfile = tempname()
    execute 'redir! > ' . tmpfile
    echo a:txt
    redir END
    return tmpfile
endfunction

function! s:Paste64Copy() range
    let l:tmp = @@
    silent normal gvy
    let l:selected = @@
    let l:i = 0
    let l:len = strlen(l:selected)
    let l:escaped = ''
    while l:i < l:len
        let l:c = strpart(l:selected, l:i, 1)
        let l:escaped .= printf("\\u%04x", char2nr(l:c))
        let l:i = l:i + 1
    endwhile
    if $TMUX != ""
        "tmuxのとき
        call system('printf "\x1bPtmux;\x1b\x1b]52;;%s\x1b\x1b\\\\\x1b\\" `echo -en "' . l:escaped . '" | base64` > /dev/tty')
    elseif $TERM == "screen"
        "GNU Screenのとき
        call system('printf "\x1bP\x1b]52;;%s\x07\x1b\\" `echo -en "' . l:escaped . '" | base64` > /dev/tty')
    elseif $TERM =~ "^dvtm" || $DVTM
        "dvtmのとき
        let tmpfile = s:MakeTmpFile(l:selected)
        let cmd = printf('printf "\\e]52;;%%s\\e\\\\" `base64 -w0 %s`', tmpfile)
        execute '!sh ' . s:MakeTmpFile(cmd)
    else
        let tmpfile = s:MakeTmpFile(l:selected)
        let cmd = printf('printf "\\e]52;;%%s\\e\\\\" `base64 -w0 %s`', tmpfile)
        execute '!sh ' . s:MakeTmpFile(cmd)
    endif
    redraw!
endfunction

command! -range Paste64Copy :call s:Paste64Copy()

" 対応ターミナル以外なら帰る
if &term !~ "screen" && &term !~ "xterm" && &term !~ "dvtm"
    finish
endif

" tmux & iTerm2 上の場合
if exists('$TMUX') && is_remora
    " iTerm2 の時のみカーソル形状を変える
    if exists('$TMUX') && is_remora
        let &t_SI = "\ePtmux;\e\e]50;CursorShape=1\x7\e\\"
        let &t_EI = "\ePtmux;\e\e]50;CursorShape=0\x7\e\\"
    elseif is_remora
        let &t_SI = "\eP\e]50;CursorShape=1\x7\e\\"
        let &t_EI = "\eP\e]50;CursorShape=0\x7\e\\"
    endif

    " 貼り付けるとき自動的に paste モードに変わる
    let &t_ti .= "\eP\e[?2004h\e\\"
    let &t_te .= "\eP\e[?2004l\e\\"

    map <expr> \e[200~ XTermPasteBegin("i")
    imap <expr> \e[200~ XTermPasteBegin("")
    cmap \e[200~ <nop>
    cmap \e[201~ <nop>

" GNU screen 上の場合
elseif &term =~ "screen"
    " 貼り付けるとき自動的に paste モードに変わる
    let &t_ti .= "\eP\e[?2004h\e\\"
    let &t_te .= "\eP\e[?2004l\e\\"

    map <expr> \e[200~ XTermPasteBegin("i")
    imap <expr> \e[200~ XTermPasteBegin("")
    cmap \e[200~ <nop>
    cmap \e[201~ <nop>

" xterm の場合
elseif &term =~ 'xterm\|dvtm'
    " iTerm2 の時のみカーソル形状を変える
    if is_remora
        let &t_SI = "\e]50;CursorShape=1\x7"
        let &t_EI = "\e]50;CursorShape=0\x7"
    endif

    " 貼り付けるとき自動的に paste モードに変わる
    let &t_ti .= "\e[?2004h"
    let &t_te .= "\e[?2004l"
    map <expr> \e[200~ XTermPasteBegin("i")
    imap <expr> \e[200~ XTermPasteBegin("")
    cmap \e[200~ <nop>
    cmap \e[201~ <nop>
endif

let &pastetoggle = "\e[201~"

function! XTermPasteBegin(ret)
    set paste
    return a:ret
endfunction

noremap <special> <expr> <Esc>[200~ XTermPasteBegin("0i")
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
cnoremap <special> <Esc>[200~ <nop>
cnoremap <special> <Esc>[201~ <nop>


if &term =~ '256color'
  " Disable Background Color Erase (BCE) so that color schemes
  " work properly when Vim is used inside tmux and GNU screen.
  " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif
