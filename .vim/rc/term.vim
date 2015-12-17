scriptencoding utf-8

" 対応ターミナル以外なら帰る
if &term !~? 'screen' && &term !~? 'xterm' && &term !~? 'dvtm'
    finish
endif

" tmux & iTerm2 上の場合
if filereadable(g:home . '/.use-mac') || exists('$TMUX') && has('macunix')
    " iTerm2 の時のみカーソル形状を変える
    if filereadable(g:home . '/.use-mac') || exists('$TMUX')
        let &t_SI = "\ePtmux;\e\e]50;CursorShape=1\x7\e\\"
        let &t_EI = "\ePtmux;\e\e]50;CursorShape=0\x7\e\\"
    else
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
elseif &term =~? 'screen'
    " 貼り付けるとき自動的に paste モードに変わる
    let &t_ti .= "\eP\e[?2004h\e\\"
    let &t_te .= "\eP\e[?2004l\e\\"

    map <expr> \e[200~ XTermPasteBegin("i")
    imap <expr> \e[200~ XTermPasteBegin("")
    cmap \e[200~ <nop>
    cmap \e[201~ <nop>

" xterm の場合
elseif &term =~? 'xterm\|dvtm'
    " iTerm2 の時のみカーソル形状を変える
    if has('macunix')
        let &t_SI = "\e]50;CursorShape=1\x7"
        let &t_EI = "\e]50;CursorShape=0\x7"
    endif

    " 貼り付けるとき自動的に paste モードに変わる
    "let &t_ti .= "\e[?2004h"
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


if &term =~? '256color'
  " Disable Background Color Erase (BCE) so that color schemes
  " work properly when Vim is used inside tmux and GNU screen.
  " See also http://snk.tuxfamily.org/log/vim-256color-bce.html
  set t_ut=
endif
