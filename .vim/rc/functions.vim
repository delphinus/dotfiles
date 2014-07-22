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
" Objective-C 設定
autocmd BufNewFile,BufRead *.m setf objc
autocmd BufNewFile,BufRead *.h setf objc

"-----------------------------------------------------------------------------
" カーソル下のシンタックスハイライト情報を得る
" http://cohama.hateblo.jp/entry/2013/08/11/020849
function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
        \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()


"-----------------------------------------------------------------------------
" Javascript のたたみ込み
autocmd FileType javascript call JavaScriptFold()

"-----------------------------------------------------------------------------
" matchit プラグイン
source $VIMRUNTIME/macros/matchit.vim
augroup matchit
  autocmd!
  autocmd FileType ruby let b:match_words = '\<\(module\|class\|def\|begin\|do\|if\|unless\|case\)\>:\<\(elsif\|when\|rescue\)\>:\<\(else\|ensure\)\>:\<end\>'
augroup END
