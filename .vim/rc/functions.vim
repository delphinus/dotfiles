
"-----------------------------------------------------------------------------
" ヘルプ
function! s:VertHelp(word)
  execute 'vertical help ' . a:word
  execute 'vertical resize 80'
  execute 'set wfw'
endfunction
command! -nargs=? H call s:VertHelp(<f-args>)
autocmd FileType help nnoremap <buffer>q :q<CR>

"-----------------------------------------------------------------------------
" ファイルのあるディレクトリに移動
command! CD :cd %:h

"-----------------------------------------------------------------------------
" scp
command! -nargs=1 Scp :Clam scp % <args>:%:p

"-----------------------------------------------------------------------------
" http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
" toggles the quickfix window.
let g:jah_Quickfix_Win_Height=10
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
	if exists('g:qfix_win') && a:forced == 0
		cclose
	else
		execute 'copen ' . g:jah_Quickfix_Win_Height
	endif
endfunction

" used to track the quickfix window
augroup QFixToggle
	autocmd!
	autocmd BufWinEnter quickfix let g:qfix_win = bufnr('$')
	autocmd BufWinLeave * if exists('g:qfix_win') && expand('<abuf>') == g:qfix_win | unlet! g:qfix_win | endif
augroup END

"-----------------------------------------------------------------------------
" Apache 再起動
if is_office
	function! RestartApache()
		call system('sudo /usr/local/apache/bin/apachectl graceful')
		echo 'apache restarted'
	endfunction
	nnoremap <silent> <unique> <Leader>h :call RestartApache()<CR>
endif

"-----------------------------------------------------------------------------
" Templte::Toolkit 設定
autocmd BufNewFile,BufRead *.tt2 setf tt2html
autocmd BufNewFile,BufRead *.tt setf tt2html

"-----------------------------------------------------------------------------
" pentadactylrc 設定
au BufNewFile,BufRead .pentadactylrc setf pentadactyl

"-----------------------------------------------------------------------------
" yank to remote clipboard
if is_unix
	let s:tmpdir = &backupdir
	let s:home = is_office ? expand('$H') : expand('$HOME')
	let g:y2r_config = {
	\	'tmp_file': s:tmpdir . '/exchange-file',
	\	'key_file' : s:home . '/.exchange.key',
	\	'host' : 'localhost',
	\	'port' : 52224,
	\}

	function! Yank2Remote(...)
        if !a:0
            call writefile(split(@", '\n'), g:y2r_config.tmp_file, 'b')
        endif
		let s:params = ['cat %s %s | nc -w1 %s %s']
		for s:item in ['key_file', 'tmp_file', 'host', 'port']
		let s:params += [shellescape(g:y2r_config[s:item])]
		endfor
		let s:ret = system(call(function('printf'), s:params))
		echo 'paste to remote'
	endfunction
	nnoremap <silent> <unique> <Leader>y :call Yank2Remote()<CR>
endif

"-----------------------------------------------------------------------------
" Vimからクリップボードインテグレーションシーケンス(PASTE64/OSC52)を利用する
" http://qiita.com/items/515ed5264fce40dec522
function! Paste64Copy(...)
    if !a:0
        call writefile(split(@", '\n'), g:y2r_config.tmp_file, 'b')
    endif
    let l:cmd = '`cat ' . g:y2r_config.tmp_file . ' | base64 -w0` > /dev/tty'
    if $TMUX != ""
        "tmuxのとき
        call system('printf "\ePtmux;\e\e]52;;%s\e\e\\\\\e\\" ' . l:cmd)
    elseif $TERM =~ "screen"
        "GNU Screenのとき
        call system('printf "\eP\e]52;;%s\x7\e\\" ' . l:cmd)
    else
        call system('printf "\e]52;;%s\e\\" ' . l:cmd)
    endif
    "redraw!
endfunction

command! Paste64Copy :call Paste64Copy()

"-----------------------------------------------------------------------------
" diff
" diff 開始
command! -nargs=0 DT :diffthis
command! -nargs=0 DO :diffoff!

"-----------------------------------------------------------------------------
" Objective-C 設定
autocmd BufNewFile,BufRead *.m setf objc
autocmd BufNewFile,BufRead *.h setf objc
