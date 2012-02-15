" カーソル形状の変更
" http://yakinikunotare.boo.jp/orebase2/vim/change_cursor_shape_in_terminal_with_mode_change
if is_unix
	"let &t_SI .= "\<Esc>]50;CursorShape=1\x7"
	"let &t_EI .= "\<Esc>]50;CursorShape=0\x7"
	"let &t_SI .= "\e[3 q"
	"let &t_EI .= "\e[1 q"
	"let &t_SI .= "\e[?2004h"
	"let &t_EI .= "\e[?2004l"
	"let &pastetoggle = "\e[201~"

	"function XTermPasteBegin(ret)
		"set paste
		"return a:ret
	"endfunction

	"inoremap <special> <expr> <Esc>[200~ :XTermPasteBegin('')

	"let &t_SI = "\eP" . &t_SI
	"let &t_EI .= "\e\\"
	"inoremap <Esc> <Esc>gg`]
endif

"-----------------------------------------------------------------------------
" Ricty 使うようになったらいらなくなった
" 全角スペース・行末のスペース・タブの可視化
if has('syntax')
    "syntax on

    " PODバグ対策
    "syn sync fromstart

    "function! ActivateInvisibleIndicator()
        "syntax match InvisibleJISX0208Space "　" display containedin=ALL
        "highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        "syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        "highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=NONE gui=undercurl guisp=darkorange
        "syntax match InvisibleTab "\t" display containedin=ALL
        "highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    "endf
    "augroup invisible
        "autocmd! invisible
        "autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    "augroup END
endif

"-----------------------------------------------------------------------------
" str2time()
" Perl の HTTP::Date::str2time() を使って epoch 時を得る
function! Str2time(str)
	let s:curline=getline('.')
	let s:row=line('.')
	let s:cur=col('.')
	let s:left=strpart(s:curline, 0, s:cur - 1)
	let s:right=strpart(s:curline, s:cur - 1)

	if (0)
		perl <<EOP
		use HTTP::Date;
		$epoch = str2time(VIM::Eval('a:str'), '+0900');
		$curbuf->Set(VIM::Eval('s:row'), VIM::Eval('s:left') . $epoch . VIM::Eval('s:right'));
		$curwin->Cursor(VIM::Eval('s:row'), VIM::Eval('s:cur') + length $epoch);
EOP

	else
		if (match(a:str, '^\d\+$') == 0)
			let s:time=system('perl -MHTTP::Date -e"print HTTP::Date::time2iso('.a:str.')"')
		else
			let s:time=system('perl -MHTTP::Date -e"print str2time(q{'.a:str.'})"')
		endif
		call setline(line('.'), s:left.s:time.s:right)
		call cursor(line('.'), col('.') + len(s:time))
	endif
endfunction
command! -nargs=1 ST :call Str2time('<args>')

