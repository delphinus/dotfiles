" LineJuggler.vim: Duplicate and move around lines.
"
" DEPENDENCIES:
"   - ingowindow.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.10.006	23-Jul-2012	Extract s:PutWrapper() to apply the "empty last
"				element" workaround consistently to all
"				instances of :put use (which as previously
"				missed for s:Replace()).
"				CHG: Split [f and {Visual}[f behaviors into two
"				families of mappings:
"				a) [f to fetch below current line and {Visual}[f
"				to fetch selected number of lines above/below
"				selection
"				b) [r to fetch and replace current line /
"				selection.
"				The renamed LineJuggler#VisualRepFetch() uses
"				s:RepFetch() instead of the (similar)
"				LineJuggler#Dup() function.
"				s:Replace() takes optional register argument to
"				store the deleted lines in; defaults to black
"				hole register.
"   1.00.005	20-Jul-2012	FIX: Implement clipping for ]D.
"   1.00.004	19-Jul-2012	FIX: Clipping for ]E must consider the amount of
"				lines of the source fold and subtract them from
"				the last available line number. Add optional
"				lastLineDefault argument to
"				LineJuggler#ClipAddress().
"				Use visible, not physical target lines when
"				swapping with [E / ]E (also in visual mode) and
"				the target starts on a non-folded line.
"				Change {Visual}[f / ]f to use visible, not
"				physical target lines, too.
"				FIX: Handle "E134: Move lines into themselves"
"				:move error.
"   1.00.003	18-Jul-2012	Factor out LineJuggler#ClipAddress().
"				Make [<Space> / ]<Space> keep the current line
"				also when inside a fold.
"   			    	Consolidate the separate LineJuggler#BlankUp() /
"				LineJuggler#BlankDown() functions.
"				Keep current line for {Visual}[<Space>.
"   1.00.002	17-Jul-2012	Add more LineJuggler#Visual...() functions to
"				handle the distance in a visual selection in a
"				uniform way.
"				Implement line swap.
"				FIX: Due to ingowindow#RelativeWindowLine(),
"				a:address is now -1 when addressing a line
"				outside the buffer; adapt the beep / move to
"				border logic, and make it handle current folded
"				line, too.
"				Extract s:Replace() from s:DoSwap() and properly
"				handle replacement at the end of the buffer,
"				when a:startLnum becomes invalid after the
"				temporary delete.
"	001	12-Jul-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

function! LineJuggler#FoldClosed( ... )
    let l:lnum = (a:0 ? a:1 : line('.'))
    return foldclosed(l:lnum) == -1 ? l:lnum : foldclosed(l:lnum)
endfunction
function! LineJuggler#FoldClosedEnd( ... )
    let l:lnum = (a:0 ? a:1 : line('.'))
    return foldclosedend(l:lnum) == -1 ? l:lnum : foldclosedend(l:lnum)
endfunction

function! LineJuggler#ClipAddress( address, direction, firstLineDefault, ... )
    " Beep when already on the first / last line, but allow an arbitrary large
    " count to move to the first / last line.
    if a:address < 0
	if a:direction == -1
	    if LineJuggler#FoldClosed() == 1
		execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
		return -1
	    else
		return a:firstLineDefault
	    endif
	else
	    if LineJuggler#FoldClosedEnd() == line('$')
		execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.
		return -1
	    else
		return a:0 ? a:1 : line('$')
	    endif
	endif
    endif
    return a:address
endfunction



function! LineJuggler#Blank( address, count, direction, mapSuffix )
    let l:original_lnum = line('.')
	execute a:address . 'put' . (a:direction == -1 ? '!' : '') '=repeat(nr2char(10), a:count)'
    execute (l:original_lnum + (a:direction == -1 ? a:count : 0))

    silent! call       repeat#set("\<Plug>(LineJugglerBlank" . a:mapSuffix . ')', a:count)
    silent! call visualrepeat#set("\<Plug>(LineJugglerBlank" . a:mapSuffix . ')', a:count)
endfunction
function! LineJuggler#VisualBlank( address, direction, mapSuffix )
    let l:count = v:count1
    " With :<C-u>, we're always in the first line of the selection. To get the
    " actual line of the cursor, we need to leave the visual selection. We
    " cannot do that initially before invoking this function, since then the
    " [count] would be lost. So do this now to get the current line.
    execute "normal! gv\<C-\>\<C-n>"

    call LineJuggler#Blank(a:address, l:count, a:direction, a:mapSuffix)
endfunction

function! LineJuggler#Move( range, address, count, direction, mapSuffix )
    let l:address = LineJuggler#ClipAddress(a:address, a:direction, 0)
    if l:address == -1 | return | endif

    try
	let l:save_mark = getpos("''")
	    call setpos("''", getpos('.'))
		execute a:range . 'move' l:address
	    execute line("'`")
    catch /^Vim\%((\a\+)\)\=:E/
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.

	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away.
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    finally
	call setpos("''", l:save_mark)

	silent! call       repeat#set("\<Plug>(LineJugglerMove" . a:mapSuffix . ')', a:count)
	silent! call visualrepeat#set("\<Plug>(LineJugglerMove" . a:mapSuffix . ')', a:count)
    endtry
endfunction
function! LineJuggler#VisualMove( direction, mapSuffix )
    let l:count = v:count1
    " With :<C-u>, we're always in the first line of the selection. To get the
    " actual line of the cursor, we need to leave the visual selection. We
    " cannot do that initially before invoking this function, since then the
    " [count] would be lost. So do this now to get the current line.
    execute "normal! gv\<C-\>\<C-n>"

    let l:targetLnum = ingowindow#RelativeWindowLine(line('.'), l:count, a:direction) - (a:direction == -1 ? 1 : 0)
    call LineJuggler#Move(
    \   "'<,'>",
    \   l:targetLnum,
    \   l:count,
    \   a:direction,
    \   a:mapSuffix
    \)
endfunction

function! s:PutWrapper( lnum, putCommand, lines )
    if type(a:lines) == type([]) && len(a:lines) > 1 && empty(a:lines[-1])
	" XXX: Vim omits an empty last element when :put'ting a List of lines.
	" We can work around that by putting a newline character instead.
	let a:lines[-1] = "\n"
    endif

    silent execute a:lnum . a:putCommand '=a:lines'
endfunction
function! s:PutBefore( lnum, lines )
    if a:lnum == line('$') + 1
	call s:PutWrapper((a:lnum - 1), 'put',  a:lines)
    else
	call s:PutWrapper(a:lnum, 'put!',  a:lines)
    endif
endfunction
function! s:Replace( startLnum, endLnum, lines, ... )
    silent execute printf('%s,%sdelete %s', a:startLnum, a:endLnum, (a:0 ? a:1 : '_'))
    call s:PutBefore(a:startLnum, a:lines)
endfunction
function! s:DoSwap( sourceStartLnum, sourceEndLnum, targetStartLnum, targetEndLnum )
    if  a:sourceStartLnum <= a:targetStartLnum && a:sourceEndLnum >= a:targetStartLnum ||
    \   a:targetStartLnum <= a:sourceStartLnum && a:targetEndLnum >= a:sourceStartLnum
	throw 'LineJuggler: Overlap in the ranges to swap'
    endif

    let l:sourceLines = getline(a:sourceStartLnum, a:sourceEndLnum)
    let l:targetLines = getline(a:targetStartLnum, a:targetEndLnum)

    call s:Replace(a:sourceStartLnum, a:sourceEndLnum, l:targetLines)

    let l:offset = (a:sourceEndLnum <= a:targetStartLnum ? len(l:targetLines) - len(l:sourceLines) : 0)
    call s:Replace(a:targetStartLnum + l:offset, a:targetEndLnum + l:offset, l:sourceLines)
endfunction
function! LineJuggler#Swap( startLnum, endLnum, address, count, direction, mapSuffix )
    let l:address = LineJuggler#ClipAddress(a:address, a:direction, 1, line('$') + a:startLnum - a:endLnum)
    if l:address == -1 | return | endif

    let [l:targetStartLnum, l:targetEndLnum] = (foldclosed(l:address) == -1 ?
    \   [l:address, ingowindow#RelativeWindowLine(l:address, a:endLnum - a:startLnum, 1)] :
    \   [foldclosed(l:address), foldclosedend(l:address)]
    \)

    try
	call s:DoSwap(a:startLnum, a:endLnum, l:targetStartLnum, l:targetEndLnum)
    catch /^LineJuggler:/
	execute "normal! \<C-\>\<C-n>\<Esc>" | " Beep.

	let v:errmsg = substitute(v:exception, '^LineJuggler:\s*', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endtry

    silent! call       repeat#set("\<Plug>(LineJugglerSwap" . a:mapSuffix . ')', a:count)
    silent! call visualrepeat#set("\<Plug>(LineJugglerSwap" . a:mapSuffix . ')', a:count)
endfunction
function! LineJuggler#VisualSwap( direction, mapSuffix )
    let l:count = v:count1
    " With :<C-u>, we're always in the first line of the selection. To get the
    " actual line of the cursor, we need to leave the visual selection. We
    " cannot do that initially before invoking this function, since then the
    " [count] would be lost. So do this now to get the current line.
    execute "normal! gv\<C-\>\<C-n>"

    let l:targetLnum = ingowindow#RelativeWindowLine(line('.'), l:count, a:direction)
    call LineJuggler#Swap(
    \   line("'<"), line("'>"),
    \   l:targetLnum,
    \   l:count,
    \   a:direction,
    \   a:mapSuffix
    \)
endfunction

function! LineJuggler#Dup( insLnum, lines, isUp, offset, count, mapSuffix )
    if a:isUp
	let l:lnum = max([0, a:insLnum - a:offset + 1])
	call s:PutWrapper(l:lnum, 'put!', a:lines)
    else
	let l:lnum = min([line('$'), a:insLnum + a:offset - 1])
	call s:PutWrapper(l:lnum, 'put', a:lines)
    endif

    silent! call       repeat#set("\<Plug>(LineJugglerDup" . a:mapSuffix . ')', a:count)
    silent! call visualrepeat#set("\<Plug>(LineJugglerDup" . a:mapSuffix . ')', a:count)
endfunction

function! LineJuggler#DupRange( count, direction, mapSuffix )
    let l:address = LineJuggler#FoldClosed()
    let l:endAddress = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count - 1, 1), a:direction, 1)
    if l:endAddress == -1 | return | endif

    if a:direction == -1
	let l:insLnum = l:address
	let l:isUp = 1
    else
	let l:insLnum = l:endAddress
	let l:isUp = 0
    endif

    call LineJuggler#Dup(
    \   l:insLnum,
    \   getline(l:address, l:endAddress),
    \   l:isUp, 1, a:count,
    \   a:mapSuffix
    \)
endfunction

function! LineJuggler#DupFetch( count, direction, mapSuffix )
    if a:direction == -1
	let l:address = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, -1), a:direction, 1)
	if l:address == -1 | return | endif
	let l:endAddress = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, -1, 1), a:direction, 1)
	let l:count = a:count
    else
	let l:address = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, 1, -1), a:direction, 1)
	if l:address == -1 | return | endif
	let l:endAddress = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, 1), a:direction, 1)
	" Note: To repeat with the following line, we need to increase v:count by one.
	let l:count = a:count + 1
    endif
    call LineJuggler#Dup(
    \   LineJuggler#FoldClosedEnd(),
    \   getline(l:address, l:endAddress),
    \   0, 1, l:count,
    \   a:mapSuffix
    \)
endfunction
function! LineJuggler#VisualDupFetch( direction, mapSuffix )
    let l:count = v:count1
    " With :<C-u>, we're always in the first line of the selection. To get the
    " actual line of the cursor, we need to leave the visual selection. We
    " cannot do that initially before invoking this function, since then the
    " [count] would be lost. So do this now to get the current line.
    execute "normal! gv\<C-\>\<C-n>"

    let l:targetStartLnum = ingowindow#RelativeWindowLine(line('.'), l:count, a:direction, -1)
    let l:lines = getline(l:targetStartLnum, ingowindow#RelativeWindowLine(l:targetStartLnum, line("'>") - line("'<"), 1))

    if a:direction == -1
	let l:insLnum = line("'>")
	let l:isUp = 0
    else
	let l:insLnum = line("'<")
	let l:isUp = 1
    endif

    call LineJuggler#Dup(
    \   l:insLnum,
    \   l:lines,
    \   l:isUp, 1,
    \   l:count,
    \   a:mapSuffix
    \)
endfunction

function! s:RepFetch( startLnum, endLnum, lines, count, mapSuffix )
    call s:Replace(a:startLnum, a:endLnum, a:lines, v:register)

    silent! call       repeat#set("\<Plug>(LineJugglerRepFetch" . a:mapSuffix . ')', a:count)
    silent! call visualrepeat#set("\<Plug>(LineJugglerRepFetch" . a:mapSuffix . ')', a:count)
endfunction
function! LineJuggler#RepFetch( count, direction, mapSuffix )
    if a:direction == -1
	let l:address = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, -1), a:direction, 1)
	if l:address == -1 | return | endif
	let l:endAddress = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, -1, 1), a:direction, 1)
    else
	let l:address = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, 1, -1), a:direction, 1)
	if l:address == -1 | return | endif
	let l:endAddress = LineJuggler#ClipAddress(ingowindow#RelativeWindowLine(line('.'), a:count, 1), a:direction, 1)
    endif
    let l:sourceLines = getline(l:address, l:endAddress)

    call s:RepFetch(LineJuggler#FoldClosed(), LineJuggler#FoldClosedEnd(), l:sourceLines, a:count, a:mapSuffix)
endfunction
function! LineJuggler#VisualRepFetch( direction, mapSuffix )
    let l:count = v:count1
    " With :<C-u>, we're always in the first line of the selection. To get the
    " actual line of the cursor, we need to leave the visual selection. We
    " cannot do that initially before invoking this function, since then the
    " [count] would be lost. So do this now to get the current line.
    execute "normal! gv\<C-\>\<C-n>"

    let l:targetStartLnum = ingowindow#RelativeWindowLine(line('.'), l:count, a:direction, -1)
    let l:lines = getline(l:targetStartLnum, ingowindow#RelativeWindowLine(l:targetStartLnum, line("'>") - line("'<"), 1))

    call s:RepFetch(line("'<"), line("'>"), l:lines, l:count, a:mapSuffix)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
