" ingowindow.vim: Custom window functions.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
" REVISION	DATE		REMARKS
"	018	12-Jul-2012	Add optional a:folddirection to
"				ingowindow#RelativeWindowLine().
"	017	11-Jul-2012	Add ingowindow#RelativeWindowLine().
"	016	30-May-2012	ENH: Allow custom preview window placement for
"				ingowindow#OpenPreview() via
"				g:previewwindowsplitmode.
"	015	08-Feb-2012	Add ingowindow#DisplayedLines().
"	014	11-Jan-2012	Corrected naming of
"				ingowindow#IsQuickfixWindowVisible() to
"				ingowindow#IsPreviewWindowVisible(); what was I
"				thinking?
"				Overloaded ingowindow#IsQuickfixList() to also
"				determine the type.
"	013	04-Sep-2011	Extract ingowindow#GetNumberWidth() for use in
"				ingodiff#DiffPrint().
"	012	30-Apr-2011	Add ingowindow#IsQuickfixWindowVisible().
"	011	29-Apr-2011	Move ingowindow#SplitToPreview() and
"				ingowindow#GotoPreview() from
"				plugin/ingowindowmappings.vim.
"	010	15-Apr-2011	Renamed ingowindow#IsQuickfixWindow() to
"				ingowindow#IsQuickfixList(), because it also
"				detects location lists.
"	009	10-Dec-2010	Simplified ingowindow#IsQuickfixList().
"	008	08-Dec-2010	Moved s:GotoPreviousWindow() from
"				ingowindowmappings.vim here for reuse.
"				Added ingowindow#IsQuickfixList() and
"				ingowindow#ParseFileFromQuickfixList().
"	007	10-Sep-2010	ingowindow#NetWindowWidth() now considers
"				'relativenumber' setting introduced in Vim 7.3.
"	006	02-Dec-2009	Added ingowindow#WindowDecorationColumns() and
"				ingowindow#NetWindowWidth(), taken from
"				LimitWindowWidth.vim.
"				ENH: Implemented support for adjusted
"				numberwidth and sign column to
"				ingowindow#WindowDecorationColumns().
"	005	27-Jun-2009	Added augroup.
"	004	04-Aug-2008	ingowindow#FoldedLines() also returns number of
"				folds in range.
"	003	03-Aug-2008	Added ingowindow#FoldedLines() and
"				ingowindow#NetVisibleLines().
"	002	31-Jul-2008	Added ingowindow#UndefineMappingForCmdwin().
"	001	31-Jul-2008	Moved common window movement mappings from
"				ingowindowmappings.vim
"				file creation

" Special windows are preview, quickfix (and location lists, which is also of
" type 'quickfix').
function! ingowindow#IsSpecialWindow(...)
    let l:winnr = (a:0 > 0 ? a:1 : winnr())
    return getwinvar(l:winnr, '&previewwindow') || getwinvar(l:winnr, '&buftype') ==# 'quickfix'
endfunction
function! ingowindow#SaveSpecialWindowSize()
    let s:specialWindowSizes = {}
    for w in range(1, winnr('$'))
	if ingowindow#IsSpecialWindow(w)
	    let s:specialWindowSizes[w] = [winwidth(w), winheight(w)]
	endif
    endfor
endfunction
function! ingowindow#RestoreSpecialWindowSize()
    for w in keys(s:specialWindowSizes)
	execute 'vert' w.'resize' s:specialWindowSizes[w][0]
	execute        w.'resize' s:specialWindowSizes[w][1]
    endfor
endfunction

function! ingowindow#GotoPreviousWindow()
"*******************************************************************************
"* PURPOSE:
"   Goto the previous window (CTRL-W_p). If there is no previous window, but
"   only one other window, go there.
"
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   Changes the current window, or:
"   Prints error message.
"* INPUTS:
"   None.
"* RETURN VALUES:
"   1 on success, 0 if there is no previous window.
"*******************************************************************************
    let l:problem = ''
    let l:window = 'p'

    if winnr('$') == 1
	let l:problem = 'Only one window'
    elseif winnr('#') == 0 || winnr('#') == winnr()
	if winnr('$') == 2
	    " There is only one more window, we take that one.
	    let l:window = 'w'
	else
	    let l:problem = 'No previous window'
	endif
    endif
    if ! empty(l:problem)
	echohl WarningMsg
	let v:warningmsg = l:problem
	echomsg v:warningmsg
	echohl None
	return 0
    endif

    execute 'noautocmd' 'wincmd' l:window
    return 1
endfunction


function! ingowindow#OpenPreview( ... )
    " Note: We do not use :pedit to open the current file in the preview window,
    " because that command reloads the current buffer, which would fail (nobang)
    " / forcibly write (bang) it, and reset the current folds.
    "execute 'pedit! +' . escape( 'call setpos(".", ' . string(getpos('.')) . ')', ' ') . ' %'
    try
	" If the preview window is open, just go there.
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441/
	" Else, temporarily open a dummy file. (There's no :popen command.)
	execute 'silent' (a:0 ? a:1 : '') (exists('g:previewwindowsplitmode') ? g:previewwindowsplitmode : '') 'pedit +setlocal\ buftype=nofile\ bufhidden=wipe\ nobuflisted\ noswapfile [No\ Name]'
	wincmd P
    endtry
endfunction
function! ingowindow#SplitToPreview( ... )
    if &l:previewwindow
	wincmd p
	if &l:previewwindow | return 0 | endif
    endif

    let l:cursor = getpos('.')
    let l:bufnum = bufnr('')

    call ingowindow#OpenPreview()

    " Load the current buffer in the preview window, if it's not already there.
    if bufnr('') != l:bufnum
	silent execute l:bufnum . 'buffer'
    endif

    " Clone current cursor position to preview window (which now shows the same
    " file) or passed position.
    call setpos('.', (a:0 ? a:1 : l:cursor))
    return 1
endfunction
function! ingowindow#GotoPreview()
    if &l:previewwindow | return | endif
    try
	wincmd P
    catch /^Vim\%((\a\+)\)\=:E441/
	call ingowindow#SplitToPreview()
    endtry
endfunction


function! ingowindow#IsPreviewWindowVisible()
    for l:winnr in range(1, winnr('$'))
	if getwinvar(l:winnr, '&previewwindow')
	    " There's still a preview window.
	    return l:winnr
	endif
    endfor

    return 0
endfunction

function! ingowindow#IsQuickfixList( ... )
"******************************************************************************
"* PURPOSE:
"   Check whether the current window is the quickfix window or a location list.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   determineType   Flag whether it should also be attempted to determine the
"		    type (global quickfix / local location list).
"* RETURN VALUES:
"   Boolean when no a:determineType is given. Else:
"   1 if the current window is the quickfix window.
"   2 if the current window is a location list window.
"   0 for any other window.
"******************************************************************************
    if &buftype !=# 'quickfix'
	return 0
    elseif a:0
	" Try to determine the type; this heuristic only fails when the location
	" list exists but is empty.
	return (empty(getloclist(0)) ? 1 : 2)
    else
	return 1
    endif
endfunction
function! ingowindow#ParseFileFromQuickfixList()
    return (ingowindow#IsQuickfixList() ? matchstr(getline('.'), '^.\{-}\ze|') : '')
endfunction


" The command-line window is implemented as a window, so normal mode mappings
" apply here as well. However, certain actions cannot be performed in this
" special window. The 'CmdwinEnter' event can be used to redefine problematic
" normal mode mappings.
let s:CmdwinMappings = {}
function! ingowindow#UndefineMappingForCmdwin( mappings, ... )
"*******************************************************************************
"* PURPOSE:
"   Register mappings that should be undefined in the command-line window.
"   Previously registered mappings equal to a:mappings will be overwritten.
"* ASSUMPTIONS / PRECONDITIONS:
"   none
"* EFFECTS / POSTCONDITIONS:
"   :nnoremap <buffer> the a:mapping
"* INPUTS:
"   a:mapping	    Mapping (or list of mappings) to be undefined.
"   a:alternative   Optional mapping to be used instead. If omitted, the
"		    a:mapping is undefined (i.e. mapped to itself). If empty,
"		    a:mapping is mapped to <Nop>.
"* RETURN VALUES:
"   1 if accepted; 0 if autocmds not available
"*******************************************************************************
    let l:alternative = (a:0 > 0 ? (empty(a:1) ? '<Nop>' : a:1) : '')

    if type(a:mappings) == type([])
	let l:mappings = a:mappings
    elseif type(a:mappings) == type('')
	let l:mappings = [ a:mappings ]
    else
	throw 'passed invalid type ' . type(a:mappings)
    endif
    for l:mapping in l:mappings
	let s:CmdwinMappings[ l:mapping ] = l:alternative
    endfor
    return has('autocmd')
endfunction
function! s:UndefineMappings()
    for l:mapping in keys(s:CmdwinMappings)
	let l:alternative = s:CmdwinMappings[ l:mapping ]
	execute 'nnoremap <buffer> ' . l:mapping . ' ' . (empty(l:alternative) ? l:mapping : l:alternative)
    endfor
endfunction
if has('autocmd')
    augroup ingowindow
	autocmd!
	autocmd CmdwinEnter * call <SID>UndefineMappings()
    augroup END
endif



function! s:FoldBorder( lnum, direction )
    let l:foldBorder = (a:direction < 0 ? foldclosed(a:lnum) : foldclosedend(a:lnum))
    return (l:foldBorder == -1 ? a:lnum : l:foldBorder)
endfunction
function! ingowindow#RelativeWindowLine( lnum, count, direction, ... )
"******************************************************************************
"* PURPOSE:
"   Determine the line number a:count visible (i.e. not folded) lines away from
"   a:lnum, including all lines in closed folds.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:lnum  Line number to base the calculation on.
"   a:count     Number of visible lines away from a:lnum.
"   a:direction -1 for upward, 1 for downward relative movement of a:count lines
"   a:folddirection for a fold at the target, return the fold start lnum when
"		    -1, or the fold end lnum when 1. Defaults to a:direction,
"		    which amounts to the maximum covered lines, i.e. for upward
"		    movement, the fold start, for downward movement, the fold
"		    end
"* RETURN VALUES:
"   line number, or -1 if the relative line is out of the range of the lines in
"   the buffer.
"******************************************************************************
    let l:lnum = a:lnum
    let l:count = a:count

    while l:count > 0
	let l:lnum = s:FoldBorder(l:lnum, a:direction) + a:direction
	if a:direction < 0 && l:lnum < 1 || a:direction > 0 && l:lnum > line('$')
	    return -1
	endif

	let l:count -= 1
    endwhile

    return s:FoldBorder(l:lnum, (a:0 ? a:1 : a:direction))
endfunction


" Determine the number of lines in the passed range that lie hidden in a closed
" fold; that is, everything but the first line of a closed fold.
" Returns [ number of folds in range, number of folded away (i.e. invisible)
" lines ]. Sum both values to get the total number of lines in a fold in the
" passed range.
function! ingowindow#FoldedLines( startLine, endLine )
    let l:foldCnt = 0
    let l:foldedAwayLines = 0
    let l:line = a:startLine

    while l:line < a:endLine
	if foldclosed(l:line) == l:line
	    let l:foldCnt += 1
	    let l:foldend = foldclosedend(l:line)
	    let l:foldedAwayLines += (l:foldend > a:endLine ? a:endLine : l:foldend) - l:line
	    let l:line = l:foldend
	endif
	let l:line += 1
    endwhile

    return [ l:foldCnt, l:foldedAwayLines ]
endfunction

" Determine the number of lines in the passed range that aren't folded away;
" folded ranges count only as one line. Visible doesn't mean "currently
" displayed in the window"; for that, you could create the difference of the
" start and end winline(), or use ingowindow#DisplayedLines().
function! ingowindow#NetVisibleLines( startLine, endLine )
    return a:endLine - a:startLine + 1 - ingowindow#FoldedLines(a:startLine, a:endLine)[1]
endfunction

" Determine the range of lines that are currently displayed in the window.
function! ingowindow#DisplayedLines()
    let l:startLine = winsaveview().topline
    let l:endLine = l:startLine
    let l:screenLineCnt = 0
    while l:screenLineCnt < winheight(0)
	let l:lastFoldedLine = foldclosedend(l:endLine)
	if l:lastFoldedLine == -1
	    let l:endLine += 1
	else
	    let l:endLine = l:lastFoldedLine + 1
	endif

	let l:screenLineCnt += 1
    endwhile

    return [l:startLine, l:endLine - 1]
endfunction



function! ingowindow#GetNumberWidth( isGetAbsoluteNumberWidth )
"******************************************************************************
"* PURPOSE:
"   Get the width of the number column for the current window.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:isGetAbsoluteNumberWidth	If true, assumes absolute number are requested.
"				Otherwise, determines whether 'number' or
"				'relativenumber' are actually set and calculates
"				based on the actual window settings.
"* RETURN VALUES:
"   Width for displaying numbers. To use the result for printf()-style
"   formatting of numbers, subtract 1:
"   printf('%' . (ingowindow#GetNumberWidth(1) - 1) . 'd', l:lnum)
"******************************************************************************
    let l:maxNumber = 0
    " Note: 'numberwidth' is only the minimal width, can be more if...
    if &l:number || a:isGetAbsoluteNumberWidth
	" ...the buffer has many lines.
	let l:maxNumber = line('$')
    elseif exists('+relativenumber') && &l:relativenumber
	" ...the window width has more digits.
	let l:maxNumber = winheight(0)
    endif
    if l:maxNumber > 0
	let l:actualNumberWidth = strlen(string(l:maxNumber)) + 1
	return (l:actualNumberWidth > &l:numberwidth ? l:actualNumberWidth : &l:numberwidth)
    else
	return 0
    endif
endfunction

" Determine the number of virtual columns of the current window that are not
" used for displaying buffer contents, but contain window decoration like line
" numbers, fold column and signs.
function! ingowindow#WindowDecorationColumns()
    let l:decorationColumns = 0
    let l:decorationColumns += ingowindow#GetNumberWidth(0)

    if has('folding')
	let l:decorationColumns += &l:foldcolumn
    endif

    if has('signs')
	redir => l:signsOutput
	silent execute 'sign place buffer=' . bufnr('')
	redir END

	" The ':sign place' output contains two header lines.
	" The sign column is fixed at two columns.
	if len(split(l:signsOutput, "\n")) > 2
	    let l:decorationColumns += 2
	endif
    endif

    return l:decorationColumns
endfunction

" Determine the number of virtual columns of the current window that are
" available for displaying buffer contents.
function! ingowindow#NetWindowWidth()
    return winwidth(0) - ingowindow#WindowDecorationColumns()
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
