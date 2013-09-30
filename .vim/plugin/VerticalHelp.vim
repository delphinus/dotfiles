if exists('loaded_vertical_help') && !exists('testing_vertical_help')
    finish
endif
let loaded_vertical_help=1

" Optional argument is the help topic
com! -nargs=? -complete=help H  call <SID>VerticalHelp(<q-args>)
function! <SID>VerticalHelp(...)

    "To toggle back and forth between Help and working file, 
    "  without having to <ctrl-W> p
    "
    "If the current window IS the help window 
    "AND no topic was specified
    "AND the window is sized correctly
    "...let's just move to the previous window 
    if &buftype == 'help' 
                \ && a:1 == "" 
                \ && winwidth(winnr()) == 80 
                \ && &wfw 
        wincmd p
        return
    endif

    " first find the help window if one is open 
    let l:current_window = winnr()
    let l:help_window = 0
    let l:cmd =  "if &buftype == 'help' | let l:help_window = winnr() | endif"
    windo execute l:cmd
    exe l:current_window . "wincmd w"

    " If a help window already exists and no topic was specified, then 
    " just move to the help window.  Otherwise, open the help topic.
    if l:help_window > 0 && a:1 == ""
        exe l:help_window."wincmd w"
    else
        try
            exe "help " . a:1
        catch /^Vim(help):E149:/
            echohl ErrorMsg  
            echo substitute(v:exception,"Vim(help):", "", "")
            echohl None
            return
        endtry
    endif 

    "We're in the help window now. 
    "If the window is not sized correctly, then 
    "move and size it and lock the width down.
    if winwidth(winnr()) != 80 || &wfw == 0 
        if exists("g:vertical_help_left") 
            wincmd H
        else
            wincmd L
        endif
        vertical resize 80 
        set wfw
    endif
    "Re-position the view in case a jump scolled it too far left
    normal! ze

endfunction

