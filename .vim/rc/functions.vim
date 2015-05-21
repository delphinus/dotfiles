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
" Templte::Toolkit 設定
autocmd BufNewFile,BufRead *.tt2 setf tt2html
autocmd BufNewFile,BufRead *.tt setf tt2html

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

"-----------------------------------------------------------------------------
" github の任意の行を開く
function s:open_github_link(branch, ...)
  let from = get(a:, 1)
  let to   = get(a:, 2)
  if from > 0 || to > 0
    let opt = ' --from ' . from . ' --to ' . to
  else
    let opt = ''
  endif
  let result = system('open-github-link' . opt . ' --branch ' . a:branch . ' ' . expand('%:p'))
  echomsg result
endfunction

function s:get_branch()
  let result = substitute(system('git rev-parse --abbrev-ref @'), '\n$', '', '')
  return result
endfunction

function <SID>open_github_link_in_master()
  call s:open_github_link('master')
endfunction

function <SID>open_github_link_in_master_with_line() range
  call s:open_github_link('master', a:firstline, a:lastline)
endfunction

function <SID>open_github_link_in_branch()
  let branch = s:get_branch()
  call s:open_github_link(branch)
endfunction

function <SID>open_github_link_in_branch_with_line() range
  let branch = s:get_branch()
  call s:open_github_link(branch, a:firstline, a:lastline)
endfunction

nmap go :call <SID>open_github_link_in_master()<cr>
vmap go :call <SID>open_github_link_in_master_with_line()<cr>
nmap gb :call <SID>open_github_link_in_branch()<cr>
vmap gb :call <SID>open_github_link_in_branch_with_line()<cr>
