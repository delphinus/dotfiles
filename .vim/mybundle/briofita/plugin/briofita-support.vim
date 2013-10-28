"----------------------------------------------------------------------------
"                               Plugin Heading:
"   Name:        briofita-support
"   Scriptname:  briofita-support.vim                                                     {{{1
"   Author:      Sergio Nobre <sergio.o.nobre@gmail.com>
"   Copyright:   Copyright (C) 2013 Sergio O. Nobre
"   License:     The Vim license
"   Website:     http://www.vim.org/scripts/script.php?script_id=4136
"   Last Change: October 27, 2013
"   Version:     3.0.6
"   Purpose:     This plugin allows the user to manage Briofita colorscheme options and
"                serves as an example of driving Briofita's colorscheme behavior,
"                focusing specially on options cycling.
"   Notes:       For explanations, usage help and release history please
"                check the companion help file. To know about new versions
"                visit the above URL. The website has a button you can use
"                for rating this script.
" ----------------------------------------------------------------------------

" Startup                                                                         {{{1

" check whether this script is already loaded
if exists("s:briofita_support_version") || exists("g:briofita_support_version")
    finish
endif

let s:briofita_support_version = ["3.0.6"]
let g:briofita_support_version = copy(s:briofita_support_version)

function! s:SetMenuLocation()            " {{{1
    " NOTE: for this version this function is to be called only once, from the plugin
    "       startup code (so to avoid the risk of the menu not being uniquely located).
    " CONSEQUENCE: if the user re-assigns the global variable g:briofita_root_menu
    "              it will be effective only at the next time the plugin starts
    " TODO: a future version might implement menu destruction/reconstruction,
    "       allowing the user to dinamically change the menu location
    let s:briofita_upper_menu = 'Plugin.'
    let s:briofita_root_menu = s:briofita_upper_menu
    let menubranchname = 'Briofita\ Colorscheme\ Support.'
    " check if there is a user defined menu location
    if exists("g:briofita_root_menu")
        if strpart(g:briofita_root_menu,len(g:briofita_root_menu)-1) == '.'
            let s:briofita_root_menu = g:briofita_root_menu
        "else
        "    echomsg "Briofita support: error: ill-specified g:briofita_root_menu ignored"
        endif
    endif
    let s:briofita_root_menu .= menubranchname
endfunction

call s:SetMenuLocation()

" The Options: 0 - does not show messages; 1,2 - show via gui dialog; 3 - show via CLI msg
" NOTE1: error messages will always be shown
" NOTE2: options 1 (and 2) will cascade to option 3, if tlib (GUI dialog) not installed
" NOTE3: option 2 is equal to 1, except that option 1 will SKIP state transition messages,
"        (option 2 will always show state transition messages)
let s:briofita_tabdo_warn_startlevel = 8  " warns about :tabdo begin at 8 tabpages open
let s:briofita_show_msgs = 1   " default
if exists("g:briofita_show_msgs")
    let s:briofita_show_msgs = g:briofita_show_msgs
endif
if (s:briofita_show_msgs < 0) || (s:briofita_show_msgs > 3)
    let s:briofita_show_msgs = 0 " correct it: no message will be displayed
    echomsg "briofita-support: warn: g:briofita_show_msgs has invalid value; using zero instead"
endif

if exists(":Tcolorscheme")
    let s:briofita_colorcommand = 'Tcolorscheme'
else
    let s:briofita_colorcommand  = 'colorscheme'
endif
if exists("g:briofita_colorcommand")
    if s:IsString(g:briofita_colorcommand)
        " NOTE: the g: command is to be specified by the user without the preceding ':'
        let g:briofita_colorcommand = substitute(g:briofita_colorcommand," ","","g")
        if exists(':' . g:briofita_colorcommand)
            let s:briofita_colorcommand = g:briofita_colorcommand
        endif
    endif
endif

let s:dictProxies = { "statusline":         "StatusLine",
                    \ "cursorline":         "CursorLine",
                    \ "colorcolumn":        "ColorColumn",
                    \ "search":             "Search",
                    \ "diff":               "DiffText",
                    \ "normal":             "Normal",
                    \ "cursorlinenr":       "CursorLineNr",
                    \ "foldcolumn":         "FoldColumn",
                    \ "folded":             "Folded",
                    \ "conceal":            "Conceal",
                    \ "special":            "Special",
                    \ "mix01":              "vimFuncBody",
                    \ "matchparen":         "MatchParen"  }

function! s:SourceBriofita()                                                            " {{{1
    " a way of (re-)sourcing Briofita in which the user provides the command in a string
    " BEWARE: this is risky! the user may put a dangerous command in the g: string variable!
    let l:cmd = s:briofita_colorcommand . ' briofita '
    try
        execute l:cmd
    catch /^Vim\%((\a\+)\)\=:E/
        let l:msg = "briofita-support: SourceBriofita: ':" .
             \  l:cmd .
             \  "' ERROR: " .
             \  v:exception
        call s:DisplayMessage(l:msg)
    endtry
endfunction

function! s:LoadBriofita(simplyload)                                                            " {{{1
    " source or resource the colorscheme based on one of two hardcoded commands
    " pass 1 to use :color command, 0 to use tabpagecolorscheme
    if a:simplyload
        let l:cmd = 'color briofita '
    else
        let l:cmd = 'Tcolorscheme briofita '
    endif
    try
        execute l:cmd
    catch /^Vim\%((\a\+)\)\=:E/
        let l:msg = "briofita-support: LoadBriofita: ':" .
             \  l:cmd .
             \  "' ERROR: " .
             \  v:exception
        call s:DisplayMessage(l:msg)
    endtry
endfunction

function! s:SetDemonstrationTW()     " {{{1
     set tw=10
endfunction

function! s:ShowCurrentTW()     " {{{1
    " TODO add option to show dialog, in addition to echo
    if !exists("&tw")
        echomsg "Vim option textwidth has not been set."
    else
        echomsg "Current value of Vim option textwidth: " . &tw
    endif
endfunction

function! s:ShowInitialTW()     " {{{1
    " TODO add option to show dialog, in addition to echo
    if !exists("s:initialtw")
        echomsg "There is no saved initial &textwidth to show."
    elseif (s:initialtw == (-1))
        echomsg "Saved &textwidth was cleared."
    else
        echomsg "Initial &textwidth saved: " . s:initialtw
    endif
endfunction

function! s:SaveInitialTW()     " {{{1
    " save textwidth
    let s:initialtw = &tw
endfunction

function! s:RestoreInitialTW()     " {{{1
    execute 'let &tw=' . s:initialtw
endfunction

function! s:ClearInitiallySavedTW()     " {{{1
    let s:initialtw = (-1)
endfunction

function! s:ShowInitialCC()     " {{{1
    " TODO add option to show dialog, in addition to echo
    if !exists("s:initialcc")
        echomsg "There is no saved initial &colorcolumn to show."
    elseif (s:initialcc == (-1))
        echomsg "Saved &colorcolumn was cleared."
    else
        echomsg "Initial &colorcolumn saved: " . s:initialcc
    endif
endfunction

function! s:SetDemonstrationCC()
    " colorcolumn setting
    let &cc="+1,+2,+3,+6,+7"
endfunction

function! s:SaveInitialCC()     " {{{1
    " save colorcolumn
    let s:initialcc = &cc
endfunction

function! s:RestoreInitialCC()     " {{{1
    execute 'let &cc="' . s:initialcc . '"'
endfunction


function! s:ToggleTWandCC()     " {{{1
  if (&colorcolumn == "")
     if exists("s:last_colorcolumn")
         execute "set colorcolumn=" . s:last_colorcolumn
     endif
     if exists("s:last_textwidth")
         execute "set textwidth=" . s:last_textwidth
     endif
  else
     let s:last_colorcolumn=&colorcolumn

     let s:last_textwidth=&textwidth
     set colorcolumn=""
     set textwidth=0
  endif
endfunction

function! g:BriofitaToggleStatusline()
    if ! g:BriofitaCycleOneKey('statusline')
        return
    endif
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'statusline'=" . g:briofita_parms.statusline
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! s:ShowCurrentCC()     " {{{1
    " TODO add option to show it in a dialog
    if !exists("&cc")
        echomsg "ColorColumn Vim option has not been set."
    else
        if (len(&cc)==0)
            echomsg "ColorColumn Vim option has Vim default value (nullstring)."
        else
            echomsg "Current value of Vim option colorcolumn: " . &cc
        endif
    endif
endfunction

function! s:ShowTVar()     " {{{1
    " show contents of briofita parameter t:variable
    let curtab = 'Tabpage(' . tabpagenr() . '): '
    let varname = "t:briofita_choice_for_cursorline"
    if !exists(varname)
        try
            echohl IncSearch
        catch
            echohl LineNr
        endtry
        echomsg curtab . "Non-existing variable: " . varname
        echohl None
        return
    endif
    try
        echohl WildMenu
    catch
        echohl LineNr
    endtry
    try
        execute 'echomsg "' . curtab . 'Variable ' .
           \ varname . ' = " .  string(' .
           \ varname . ')'
        echohl None
    catch
        echohl None
    endtry
endfunction

function! s:ToggleCursorLine()     " {{{1
  if &cursorline
     set nocursorline
  else
     set cursorline
  endif
endfunction

function! s:ToggleCursorColumn()     " {{{1
  if &cursorcolumn
     set nocursorcolumn
  else
     set cursorcolumn
  endif
endfunction

function! s:ToggleHlSearch()     " {{{1
  if &hlsearch
     set nohlsearch
  else
     set hlsearch
  endif
endfunction

function! s:ToggleNumber()     " {{{1
  if &number
     set nonumber
  else
     set number
  endif
endfunction

function! s:IsNumber(var1)                                      "                         {{{1
    if type(a:var1) == type(0)
        return 1
    endif
    return 0
endfunction

function! s:IsString(var1)                                      "                         {{{1
    if type(a:var1) == type("")
        return 1
    endif
    return 0
endfunction

function! s:ToString(var1)                                      "                         {{{1
    if  ! s:IsString (a:var1)
        return string(a:var1)
    endif
    return var1
endfunction

function! s:DialogMessage(themsg)                                                    "   {{{1
    try
        call tlib#input#Dialog(a:themsg,[],'')
    catch
    endtry
endfunction

function! s:DisplayMessage(themsg)                                                    "   {{{1
    if (s:briofita_show_msgs == 1) || (s:briofita_show_msgs == 2)
        call s:DialogMessage(a:themsg)
        try
            call tlib#input#Dialog(a:themsg,[],'')
        catch
            echomsg a:themsg
        endtry
    elseif (s:briofita_show_msgs == 3)
        echomsg a:themsg
    endif
endfunction

function! g:ShowBriofitaInfo()                                                  "   {{{1
    " show via echomsg the key-sorted contents of g:briofita_keys dict
    if exists("g:briofita_keys")
        let allkeys = sort(keys(g:briofita_keys))
        "echomsg "g:briofita_keys: {"
        echomsg "BRIOFITA DICTIONARY KEYS"
        echomsg "Note: numbers do not refer to cycling, instead they count highlights."
        echomsg "   "
        echomsg "g:briofita_keys: "
        for key in allkeys
            let quotedkey = string(key)
            let qlen      = len(quotedkey)
            let noquote   = strpart(quotedkey,1,qlen-2)
            let shownkey = "'" . key . "'"
            let cmd = "echomsg '    ' . shownkey . ': ' . string(g:briofita_keys." . noquote . ")"
            execute cmd
        endfor
    endif
endfunction

function! g:BriofitaVersion(...)                                                     "    {{{1
        " this function returns a string with Briofita version and other information.
        " optional parameter a:1 values:
        "      0 (default; same as not passing any parameter): a few (if any) space separators are used,
        "           and checks only the current tabpage
        "      1: messages receive more separating spaces and checks only the current tabpage
        "      2: same as 0, but will perform a :tabdo to search for tab-local cul/cuc settings
        "      3: same as 1, but will perform a :tabdo to search for tab-local cul/cuc settings
        "      any other number: falls back to the default (0).
        " Usage Examples: echo g:BriofitaVersion()
        "                 echo g:BriofitaVersion(1)
        " -------------------------------------------------------------------------------------------------
        let spaceit = 0   " default: few spaces used
        let checktabs = 0 " default: check tab-local parameter for the current tabpage, only
        if (a:0 > 0)
            if (a:1 < 0) || (a:1 > 3)
                let a:1 = 0
            endif
            if ((a:1 == 1) || (a:1 == 3))
                let spaceit = 1
            endif
            if ((a:1 == 2) || (a:1 == 3))
                let checktabs = 1
            endif
        endif
        let lstpr1 = "Briofita version" . string(g:briofitaversion)
        let locals = []
        let ctabnu = 1
        let cntlocals = 0
        if checktabs
            let lasttbp=tabpagenr("$")
            if lasttbp >= s:briofita_tabdo_warn_startlevel
                " TODO improve below code; maybe add a dialog
                let warnmsg = 'WARN: tabpage search may take time. (Press Enter to proceed.)'
                call input(warnmsg)
            endif
            let currtbp=tabpagenr()
            tabdo if exists("t:briofita_choice_for_cursorline")
               \ |let cntlocals += 1
               \ |call add(locals,ctabnu)
               \ |endif
               \ |let ctabnu += 1
            execute 'tabnext ' . currtbp
        else
            if exists("t:briofita_choice_for_cursorline")
                let cntlocals = 1
            endif
        endif
        if (!exists("g:briofita_parms") || empty(g:briofita_parms)) && (cntlocals==0)
            let lstpr2 = '*** No Briofita parameters were found.'
            let lstpr3 = ''
            if spaceit
                let l:msg = printf("%s\r%s\r%s",lstpr1,lstpr2,lstpr3)
            else
                "let l:msg = printf("%s:  %s%s",lstpr1,lstpr2,lstpr3)
                let l:msg = lstpr1 . ' ' . lstpr2 . ' ' . lstpr3
            endif
            return l:msg
        endif
        if exists("g:briofita_parms")
            let lstpr2 = "Briofita parameters: "
            let lstpr3 = string(g:briofita_parms)
        endif
        if spaceit
            " better for displaying in a dialog
            let l:msg = printf("%s\r%s\r%s",lstpr1,lstpr2,lstpr3)
        else
            " better for displaying in an echoed commandline message
            let l:msg = printf("%s:  %s%s",lstpr1,lstpr2,lstpr3)
        endif
        if (cntlocals > 0)
            if (a:0 > 0) && (((a:1 == 0) || (a:1 == 1)))
                let l:msg .= printf("\rt:briofita_choice_for_cursorline=%d",
                           \           t:briofita_choice_for_cursorline)
                return(l:msg)
            endif
            let l:msg .= printf("\rThere are %d tabpages with local cul/cuc settings",cntlocals)
            if ! empty(locals)
                let l:msg .= printf("  -- Tabs: %s",string(locals))
            endif
        endif
        return(l:msg)
endfunction

function! s:ShowBriofitaVersion(...)                                               "         {{{1
    if (a:0 == 0)
        if (s:briofita_show_msgs == 1) || (s:briofita_show_msgs == 2)
            call s:DisplayMessage(g:BriofitaVersion(1))
        else
            call s:DisplayMessage(g:BriofitaVersion(0))
        endif
    else
        call s:DisplayMessage(g:BriofitaVersion(a:1))
    endif
endfunction

function! s:ShowBriofitaOptionCC()                                                  "     {{{1
    if exists("g:briofita_parms") && has_key(g:briofita_parms,'colorcolumn')
        let msglk = g:briofita_parms.colorcolumn==1? ' is linked to ': ' is not linked to '
        let msgcc = "Current ColorColumn Briofita option '" .
                \     string(g:briofita_parms.colorcolumn)    .
                \     "' "                                    .
                \     msglk                                 .
                \     'cul/cuc settings.'                     .
                \     "'."
    else
        let msgcc = "There is no active ColorColumn Briofita option."
    endif
    if (s:briofita_show_msgs == 1) || (s:briofita_show_msgs == 2)
        call s:DisplayMessage(msgcc)
    else
        call s:DisplayMessage(msgcc)
    endif
endfunction

function! s:SetParameter(strKey, strValue, ...)    " {{{1
    " sets one briofita interface parameter (a key within the g:briofita_parms dictionary)
    " if the global dict does not exist, it creates it with one entry for given key and value
    " parm1: dict key: example: 'search'
    " parm2: numeric value to be assigned to the key: example: 2
    " parm3: significative only if key = 'cursorline':
    "        boolean: if 1, may create t:var;   if 0, only change t:var (do not create)
    if a:strKey == 'cursorline'
        call s:SetParameterCulCuc(a:strValue)
        return
    endif
    if ! exists("g:briofita_keys")
        echomsg "briofita-support: SetParameter(): error: interface variable g:briofita_keys not found"
        return
    endif
    let allowedkeys = sort(keys(g:briofita_keys))
    let ixk = index(allowedkeys, a:strKey)
    if ixk >= 0
        if !exists("g:briofita_parms")
            let l:cmd = "let g:briofita_parms = { '" .
                        \  a:strKey . "': " .
                        \  a:strValue . ' }'
        else
            if has_key(g:briofita_parms,a:strKey)
                let l:cmd = "let g:briofita_parms." .
                    \    a:strKey . " = " .
                    \    a:strValue
            else
                let l:cmd = "let g:briofita_parms['" .
                    \    a:strKey . "'] = " .
                    \    a:strValue
            endif
        endif
        execute l:cmd
    endif
    if has_key(g:briofita_parms,'localcursorline')
        " boolean-like parameter: its values should be only 0 or 1
        if (g:briofita_parms.localcursorline > 1) || (g:briofita_parms.localcursorline < 0)
            let g:briofita_parms.localcursorline = 0
        endif
        if (a:strKey == 'localcursorline')
            if (a:strValue == 0) && (g:briofita_parms.localcursorline == 0)
                " delete tab var
                unlet! t:briofita_choice_for_cursorline
            endif
        elseif (a:strKey == 'cursorline')
            " NOTE the user may detach g:dict(cul) from t:(cul); but here they are coupled
            if g:briofita_parms.localcursorline
                if exists("t:briofita_choice_for_cursorline")
                    " just change tab var value
                    let t:briofita_choice_for_cursorline = a:strValue
                else
                    " need to create (currently non-existing) tab var
                    let allowtabvarcreation = 0
                    if a:0 > 0
                        let allowtabvarcreation = a:1
                    endif
                    if allowtabvarcreation
                        let t:briofita_choice_for_cursorline = a:strValue
                    endif
                endif
            endif
        endif
    endif
endfunction

function! s:SetParameterCulCuc(strValue)    " {{{1
    if ! exists("g:briofita_keys")
        echomsg "briofita-support: SetParameterCulCuc(): error: interface variable g:briofita_keys not found"
        return
    endif
    let allowedkeys = sort(keys(g:briofita_keys))

    if index(allowedkeys, 'cursorline') < 0
        return
    endif
    if !exists("g:briofita_parms")
        let l:cmd = "let g:briofita_parms = { 'cursorline': " .  a:strValue . ' }'
        execute l:cmd
    endif
    if has_key(g:briofita_parms,'localcursorline')
        if (g:briofita_parms.localcursorline > 1) || (g:briofita_parms.localcursorline < 0)
            let g:briofita_parms.localcursorline = 0
        endif
    else
        let g:briofita_parms[localcursorline] = 0
    endif
    if (g:briofita_parms.localcursorline == 0)
        unlet! t:briofita_choice_for_cursorline
        if has_key(g:briofita_parms,'cursorline')
            let l:cmd = "let g:briofita_parms.cursorline = " .  a:strValue
        else
            let l:cmd = "let g:briofita_parms['cursorline'] = " .  a:strValue
        endif
        execute l:cmd
    else
        let t:briofita_choice_for_cursorline = a:strValue
    endif
endfunction

function! s:SetOptionCC(numval)
    " set numeric option for ColorColumn
    let newvalue = a:numval
    if ! s:IsNumber(newvalue)
        unlet newvalue
        let newvalue = 0   " correcting it
    endif
    let g:briofita_parms['colorcolumn'] = newvalue
    call  s:SourceBriofita()
endfunction

function! s:BriofitaGlobalCL(scope,...)    " {{{1
    " make cul/cuc global (not tabpage local)
    " parm1: scope:
    "        if 0, deletes only curr tabpage t:var;
    "        otherwise, all tabpages's vars are deleted
    " optional parm2: value for setting cursorline; if parm2 absent: curr.value prevails
    " -------------------------------------------------------------------------------------
    if s:MetConditionsForCycling('cursorline')
        " NOTE current tab cursorline value will become the global value, if parm2 not given
        let currtabpreviousvalue = g:briofita_parms.cursorline
        if exists("t:briofita_choice_for_cursorline")
            if g:briofita_parms.localcursorline
                let currtabpreviousvalue = t:briofita_choice_for_cursorline
            endif
            if (a:scope==0)
                " only the current briofita tabpage variable will be deleted
                " TODO check if, at this point, we should move the t:var value into the g:dict corresponding key
                unlet! t:briofita_choice_for_cursorline
            else
                " all the briofita tabpage variables will be deleted
                let lasttbp=tabpagenr("$")
                if lasttbp >= s:briofita_tabdo_warn_startlevel
                    " TODO improve below code; maybe add a dialog
                    let warnmsg = 'WARN: :tabdo-ing for deletion of local Briofita parameters: this may take time. (Press Enter to proceed.)'
                    call input(warnmsg)
                endif
                let currtbp=tabpagenr()
                tabdo if exists("t:briofita_choice_for_cursorline")
                   \ |unlet      t:briofita_choice_for_cursorline
                   \ |endif
                execute 'tabnext ' . currtbp
            endif
        endif
        " disable tablocal operation of cul/cuc
        call s:SetParameter('localcursorline', 0)
        if a:0 > 0
            let startpoint = a:1
        else
            let startpoint = currtabpreviousvalue
        endif
        call s:SetParameter('cursorline', startpoint, 0)
        call g:BriofitaCycleCL()
    endif
endfunction

function! g:BriofitaLocalCL(...)    " {{{1
    " make cul/cuc tabpage local (not global)
    " enable tablocal operation of cul/cuc
    call s:SetParameter('localcursorline', 1)
    if a:0 > 0
        let startpoint = a:1
    else
        let startpoint = 0
    endif
    " let t:briofita_choice_for_cursorline = startpoint
    call s:SetParameter('cursorline', startpoint, 1)
    call g:BriofitaCycleCL()
endfunction

function! s:IsLoadedBriofita()         "                                                {{{1
    let colorisloaded = 0
    if exists(':Tcolorscheme')
        if exists('t:colorscheme')
            let colorisloaded = (t:colorscheme=='briofita')
            if (!colorisloaded)
                return 0   " local tabpage color prevails
            endif
        endif
    endif
    if (!colorisloaded)
        if exists("g:colors_name")
            let colorisloaded = (g:colors_name=='briofita')
        endif
    endif
    if (!colorisloaded)
        " FIXME 'colors_name' vs.'g:colors_name'
        if exists("colors_name")
            let colorisloaded = (colors_name=='briofita')
        endif
    endif
    if (!colorisloaded)
        return 0
    endif
    return 1
endfunction

function! s:MetConditionsForCycling(keyname)    "                                        {{{1
    " returns 1, met; 0 unmet
    if ! s:IsLoadedBriofita()
        return 0
    endif
    if !exists('g:briofita_parms')
        " create dict with the only required dict entry
        let g:briofita_parms = { 'localcursorline': 0}
    endif
    if a:keyname == 'cursorline'
        if ! has_key(g:briofita_parms,"cursorline")
            let g:briofita_parms['cursorline'] = 0
        endif
        if ! has_key(g:briofita_parms,"localcursorline")
            " create the required dict entry with default value (global cul/cuc)
            let g:briofita_parms['localcursorline'] = 0
        endif
    else
        let fail = 0
        try
            execute 'let goahead = has_key(g:briofita_parms,"' . a:keyname . '")'
            if ! goahead
                let fail = 1
            endif
        catch
            let fail = 1
        endtry
        if fail
            let l:cmd = "let g:briofita_parms['" . a:keyname . "'] = 0"
            execute l:cmd
        endif
    endif
    return 1
endfunction

function! g:BriofitaCycleCL() " A {{{1
    " cycling cursorline / cursorcolumn options
    if !exists("+cul") || (&cul==0)
        echomsg "Vim option cursorline has not been set."
        echomsg "You may set it by using this Briofita Support Help menu: 'Selected Vim options menus (for newbies)'"
        return
    endif
    if ! s:MetConditionsForCycling('cursorline')
        return
    endif
    let globalnewvalue = -1
    if has_key(g:briofita_parms,'cursorline')
        let globalnewvalue = (g:briofita_parms.cursorline + 1)
    endif
    if has_key(g:briofita_parms,'localcursorline')
        if g:briofita_parms.localcursorline      " local cul/cuc
            if exists("t:briofita_choice_for_cursorline")
                let    t:briofita_choice_for_cursorline += 1
            else
                if (globalnewvalue >= 0) " there is no t:variable, so use dict's 'cursorline', increased
                    let t:briofita_choice_for_cursorline = globalnewvalue
                else
                    " TODO check: unlikely branch? wouldn't the colorscheme proper reset the value in this case?
                    " TODO check: or should we simply do nothing in this case?
                    " cannot cycle since current value is undetermined: go back to default...
                    let t:briofita_choice_for_cursorline = 0
                endif
            endif
            " TODO: re-check: propagation of value from t:var into g:dict corresponding key
            exe "let g:briofita_parms['cursorline'] = " . t:briofita_choice_for_cursorline
        else    " global cul/cuc
            if (globalnewvalue >= 0)    " increase 'cursorline' dict key
                let g:briofita_parms['cursorline'] = globalnewvalue
            else
                " TODO check if instead of going back to default, we should simply do nothing in this case...
                " cannot cycle since current value is undetermined: go back to default...
                let g:briofita_parms['cursorline'] = 0
            endif
        endif
    else    " TODO: check: 'localcursorline' being an absent REQUIRED key, should any cycling be performed?
        if (globalnewvalue >= 0)    " increase 'cursorline' dict key
            let g:briofita_parms['cursorline'] = globalnewvalue
        endif
    endif
    call  s:SourceBriofita()
    "call s:LoadBriofita(1)
endfunction

function! g:BriofitaCycleCUL(...) " B {{{1
    " example function #2 for cycling cursorline / cursorcolumn options
    if ! s:IsLoadedBriofita()
        return
    endif
    let isglobaloption = 1
    if exists("g:briofita_parms")
       if has_key(g:briofita_parms,'localcursorline')
            if  g:briofita_parms.localcursorline
                let isglobaloption = 0
            endif
        else
            return
        endif
    else
        return
    endif
    if a:0 > 0
        let initval = a:1
    else
        let initval = 0
    endif
    if ! isglobaloption
        if exists("t:briofita_choice_for_cursorline")
            return
        else
            let t:briofita_choice_for_cursorline = initval
        endif
    else " RESET global non-tabpage-local cursorline
        let g:briofita_parms.localcursorline = initval
    endif
endfunction

function! g:BriofitaSetOneKey(dictkey,newvalue)                                                  "    {{{1
    if s:MetConditionsForCycling(a:dictkey)
        let newvalue = a:newvalue
        if ! s:IsNumber(newvalue)
            unlet newvalue
            let newvalue = 0   " correcting it
        endif
        execute "let g:briofita_parms['" . a:dictkey . "'] = " . newvalue
        call  s:SourceBriofita()
    endif
endfunction

function! g:BriofitaCycleOneKey(dictkey)                                                  "    {{{1
    " cycle the 'dictkey' key passed as parameter 1, performed only if values >= 0
    " returns 0 cannot cycle (some erro was detected, or the initial value was less than zero)
    " returns 1 OK, done
    " NOTE1: if messages are enabled, this function uses reg.@b for a redir operation
    " NOTE2: if the dict key has a non numeric value on entry, it is corrected to 0, here
    " NOTE3: colorcolumn value 1 is skipped since it is linked to cursorline
    " -----------------------------------------------------------------------------------
    if ! s:MetConditionsForCycling(a:dictkey)
        let l:msg = "briofita-support: unable to cycle '" . a:dictkey . "'"
        call s:DisplayMessage(l:msg)
        return 0 " error
    endif
    execute 'let value = g:briofita_parms.' . a:dictkey
    execute 'let limit = g:briofita_parms.' . a:dictkey . '[1]'
    if s:IsNumber(value)
        if value < 0
            return 0 " error: cycling is performed only on values >= 0
        endif
        let value += 1
        if (a:dictkey == 'colorcolumn') && (value == 1) " skip special case (value 1)
            let value += 1
        endif
    else
        unlet value
        let value = 0   " correcting it
    endif
    execute "let g:briofita_parms['" . a:dictkey . "'] = " . value
    call  s:SourceBriofita() " the colorscheme may change back the value to zero, if over the limit
    if (s:briofita_show_msgs == 2)
        try
            execute 'let highproxy = s:dictProxies.' . a:dictkey
        catch
            let highproxy = ''
        endtry
        execute 'let newkey = g:briofita_parms.' . a:dictkey
        let l:msg  = "'" . 'Briofita: key('
        let l:msg .= a:dictkey
        let l:msg .= ')='
        let l:msg .= newkey
        if len(highproxy) > 0
            " NOTE: this branch uses register b
            let l:msg .= ' * '
            redir @b
            execute 'hi ' . highproxy
            redir END
            let l:msg .= strpart(printf('%s', eval('@b')),1)
        endif
        let l:msg .= "'"
        call s:DisplayMessage(l:msg)
    endif
    return 1
endfunction

function! g:BriofitaCycleMix01()    " {{{1
    " cycling for the 'mix01' key in the parameter dictionary
    " affects a selection of highlights
    if ! g:BriofitaCycleOneKey('mix01')
        return
    endif
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'mix01'=" . g:briofita_parms.mix01
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleMP()                                                           " {{{1
    " cycling for the 'MatchParen' key in the parameter dictionary
    call g:BriofitaCycleOneKey('matchparen')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'matchparen'=" . g:briofita_parms.matchparen
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleCC()                                                           " {{{1
    " cycling for the 'ColorColumn' key in the parameter dictionary
    if !exists("+cc") || (len(&cc)==0)
        echomsg "Vim option colorcolumn has not been set or has default value (nullstring)."
        echomsg "You may set it by using this Briofita Support Help menu: 'Selected Vim options menus (for newbies)'"
        return
    endif
    call g:BriofitaCycleOneKey('colorcolumn')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'colorcolumn'=" . g:briofita_parms.colorcolumn
        call s:DisplayMessage(l:msg)
    endif
endfunction


function! g:BriofitaCycleCLN()                                                          " {{{1
    " cycling for the 'CursorLineNr' key in the parameter dictionary
    " NOTE below conditional: commented out due to coupled highlights
    "if !exists("+nu") || (&nu==0)
    "    echomsg "Vim option number has not been set."
    "    echomsg "First set it by using one of the Briofita Support submenus of 'Selected Vim options menus (for newbies)'"
    "    return
    "endif
    call g:BriofitaCycleOneKey('cursorlinenr')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'cursorlinenr'=" . g:briofita_parms.cursorlinenr
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleConceal()                                                          " {{{1
    " cycling for the 'Conceal' key in the parameter dictionary
    " NOTE: &conceallevel=2 is preferred for showing the effects of this Briofita option
    " NOTE: the below check is commented out, due to coupled settings
    "if !exists("+conceallevel") || (&conceallevel!=2)
    "    echomsg "Required: efective Vim option conceallevel with value 2."
    "    return
    "endif
    call g:BriofitaCycleOneKey('conceal')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'conceal'=" . g:briofita_parms.conceal
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleNormal()                                                       " {{{1
    " cycling for the 'normal' key in the parameter dictionary
    call g:BriofitaCycleOneKey('normal')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'normal'=" . g:briofita_parms.normal
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleSearch()                                                       " {{{1
    " cycling for the 'search' key in the parameter dictionary
    if !exists("+hlsearch") || (&hlsearch==0)
        echomsg "Vim option hlsearch has not been set."
        echomsg "First set it by using one of the Briofita Support submenus of 'Selected Vim options menus (for newbies)'"
        return
    endif
    call g:BriofitaCycleOneKey('search')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'search'=" . g:briofita_parms.search
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleSpecial()                                                         " {{{1
    " cycling for the 'special' key in the parameter dictionary
    call g:BriofitaCycleOneKey('special')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'special'=" . g:briofita_parms.special
        call s:DisplayMessage(l:msg)
    endif
endfunction


function! g:BriofitaCycleDiff()                                                         " {{{1
    " cycling for the 'diff' key in the parameter dictionary
    call g:BriofitaCycleOneKey('diff')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'diff'=" . g:briofita_parms.diff
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleFolded()                                                         " {{{1
    " cycling for the 'folded' key in the parameter dictionary
    call g:BriofitaCycleOneKey('folded')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'folded'=" . g:briofita_parms.folded
        call s:DisplayMessage(l:msg)
    endif
endfunction

function! g:BriofitaCycleFoldColumn()                                                         " {{{1
    " cycling for the 'foldcolumn' key in the parameter dictionary
    if !exists("+fdc") || (&fdc==0)
        echomsg "Vim option foldcolumn has not been set."
        echomsg "First set it by using one of the Briofita Support submenus of 'Selected Vim options menus (for newbies)'"
        return
    endif
    call g:BriofitaCycleOneKey('foldcolumn')
    if (s:briofita_show_msgs == 2)
        let l:msg = "Briofita: 'foldcolumn'=" . g:briofita_parms.foldcolumn
        call s:DisplayMessage(l:msg)
    endif
endfunction


function! g:BriofitaHighlightsCommander(be_local,cycle_start_point)                "      {{{1
    " this is just an example of how the user may set various Briofita parameters
    " the parameters are related to cul/cuc settings
    if a:be_local
        call g:BriofitaSetOneParm('localcursorline', 1)
    else
        call g:BriofitaSetOneParm('localcursorline', 0)
    endif
    call s:SetParameter('search', 4)
    call s:SetParameter('mix01', 0)
    call s:SetParameter('diff', 3)
    call s:SetParameter('matchparen', 0)
    call s:SetParameter('conceal', 0)
    call s:SetParameter('foldcolumn', 0)
    call s:SetParameter('folded', 0)
    call s:SetParameter('nodistractionmode', 0)
    call s:SetParameter('statusline', 0)
    call s:SetParameter('colorcolumn', 0)
    call s:SetParameter('normal', 0)
    call s:SetParameter('special', 0)
    call s:SetParameter('cursorlinenr', 0)
    call s:SetParameter('cursorline', a:cycle_start_point,1)
    call g:BriofitaCycleCUL(a:cycle_start_point)
    return
endfunction

function! s:SetExampleVimOptions()
    " NOTE: This function is called via menu. It was devised as a way
    "       to help new Vim users to set a few options that make
    "       visible some Briofita features. It shall be understood as an
    "       EXAMPLE for demonstration purposes. But no harm will result
    "       if the user adds these commands to .vimrc/.gvimrc.
    set nocompatible
    set number
    set hlsearch
    set cursorline
    set colorcolumn=+1,+2
    set foldcolumn=6
    set foldmethod=marker
    syntax enable
    DoMatchParen
    " TODO show message with the above settings
    "echomsg 'set: nocompatible number hlsearch cursorline colorcolumn=+1,+2 foldcolumn=6 foldmethod=marker'
endfunction

function! s:SetTestOptions()
    " for an easier testing of some Briofita options
    " to be called from menus
    set nocompatible
    set number
    set hlsearch
    set cursorline
    set cursorcolumn
    set colorcolumn=+1,+2,+3,+6,+7
    set foldcolumn=6
    set foldmethod=marker
    set textwidth=10
    syntax enable
    DoMatchParen
    " TODO show message with the above settings
    "echomsg 'set: nocompatible number hlsearch cursorline colorcolumn=+1,+2 foldcolumn=6 foldmethod=marker'
endfunction

function! s:ViewExampleVimOptions()
    " related to func s:SetExampleVimOptions, see above
    echo 'Current state of selected Vim options: '
    echo 'compatible('   . string(&compatible)              . ') ' .
            \   'number('       . string(&number)           . ') ' .
            \   'hlsearch('     . string(&hlsearch)         . ') ' .
            \   'cursorline('   . string(&cursorline)       . ') ' .
            \   'colorcolumn('  . string(&colorcolumn)      . ') ' .
            \   'foldcolumn('   . string(&foldcolumn)       . ') ' .
            \   'foldmethod('   . string(&foldmethod)       . ') '
endfunction

function! s:MenuHeading()
    " a separator just on the top
    let menucmd = 'amenu  <silent> ' .
                \ s:briofita_root_menu .
                \ '-sepbriofitahdr01-    <nop>'
    execute menucmd
    let menucmd = 'amenu  <silent> ' .
        \ s:briofita_root_menu .
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ' .
        \ 'Briofita\ Color\ Scheme\ Support\ v' . escape(s:briofita_support_version[0], '.') . '     <nop>'
    execute menucmd
endfunction

function! g:BriofitaSupportMenuString()                                               "   {{{1
    " returns the menu entry string WITHOUT the ending dot (or a nullstring, if error)
    if exists('*g:BriofitaMenu')
        if exists("s:briofita_root_menu")
            try        " menu spec (excluding the '.' at the end of the g: variable)
                return strpart(s:briofita_root_menu,0,len(s:briofita_root_menu)-1)
            catch
            endtry
        endif
    endif
    return ""
endfunction

function! g:BriofitaSupportMenuMap(trigger)        "   {{{1
    " user callable mapping function for Briofita menu popup
    " parameter: trigger string --> map
    let menu = g:BriofitaSupportMenuString()
    if len(menu) > 0
        execute 'nmap ' . a:trigger . ' :popup ' . menu
    else
        echomsg 'briofita-support: error: could not map the menu'
    endif
endfunction

function! g:BriofitaMenu(...) " {{{1
    " TODO check this if
    if !exists("s:briofita_root_menu")
        return
    endif
    "let menucmd = 'amenu  <silent> ' . s:briofita_upper_menu . '-sep000-    <nop>'
    "execute menucmd
    let lstmenuops = [
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Main\ Menu    <nop>',
        \ '-sep001-	<nop>',
        \ '-sep002-	<nop>',
        \ 'Help,\ About,\ Basics,\ Version.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Help,\ About,\ Basics,\ Version\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep003-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep004-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Help\ \ \(formatted\ as\ Vim\ helpfile\)   :tab help briofita<cr>',
        \ 'Help,\ About,\ Basics,\ Version.-sep005-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep006-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.About  :echomsg "Briofita ' .
        \                                         'v' .
        \                                         escape(s:briofita_support_version[0], '.') . ' ' .
        \                                         'briofita.vim colorscheme, briofita-support.vim plugin: ' .
        \                                         'author Sergio Nobre: license: the Vim license"<cr>',
        \ 'Help,\ About,\ Basics,\ Version.-sep007-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep008-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Basic\ Actions     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.-sep009-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.-sep010-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep011-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Loading\ Briofita     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep012-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep013-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.Colorscheme\ activation\ methods\ referred\ to\ in\ menu\ entries\ \(1\)\ and\ \(2\)\ show\ commands\ you\ may\ use\.   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.The\ third\ method\ relies\ on\ a\ pre-set\ global\ variable\ \(check\ the\ helpfile\ for\ more\ details\)\.   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.Clicking\ on\ the\ menu\ entries\ below\ you\ RELOAD\ Briofita\ by\ the\ respective\ method\.   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep014-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep015-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep016-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \(1\)\ \ Basic\ method:\ issue\ this\ command\:\ \ \ \ \ \ \ \ \:color\ briofita  :call <SID>LoadBriofita(1)<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \(2\)\ \ Tabpage\ local\ method\:\ Via\ TabPageColorScheme\ plugin\:\ issue\ this\ command\:\ \ \ \ \ \ \ \ \:Tcolorscheme\ briofita  :call <SID>LoadBriofita(0)<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \(3\)\ \ Your\ choosen\ method\:\ per\ command\ in\ the\ global\ variable\ g\:briofita_colorcommand  :call <SID>SourceBriofita()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep017-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep018-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep019-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Loading\ Briofita.-sep020-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.-sep021-     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Selected\ Vim\ Options   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep022-      <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep023-      <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ options\:\ set\ predefined\ values\ to\ selected\ Vim\ options    :call <SID>SetExampleVimOptions()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ options\:\ set\ predefined\ values\ to\ selected\ Vim\ options    :call <SID>SetExampleVimOptions()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ options\:\ view\ the\ current\ state\ of\ the\ selected\ options  :call <SID>ViewExampleVimOptions()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ options\:\ set\ values\ to\ Vim\ options\ for\ testing            :call <SID>SetTestOptions()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep024-      <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep025-      <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep026-      <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep027-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ CursorLine\:\ toggle\ on\ and\ off    :call <SID>ToggleCursorLine()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep028-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ CursorColumn\:\ toggle\ on\ and\ off  :call <SID>ToggleCursorColumn()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep029-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ HlSearch\:\ toggle\ on\ and\ off  :call <SID>ToggleHlSearch()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep030-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ Number\:\ toggle\ on\ and\ off  :call <SID>ToggleNumber()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep031-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep032-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ TextWidth\:\ save\ initial\ width\ \(do\ this\ before\ below\ operations\)   :call <SID>SaveInitialTW()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ TextWidth\:\ show\ saved\ initial\ width                                     :call <SID>ShowInitialTW()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ TextWidth\:\ show\ current\ width                                            :call <SID>ShowCurrentTW()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ TextWidth\:\ set\ tw\=10\ \(for\ testing\ purpose\ only\)                    :call <SID>SetDemonstrationTW()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ TextWidth\:\ clear\ saved\ width\ \(for\ re\-toggling\)                      :call <SID>ClearInitiallySavedTW()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ TextWidth\:\ restore\ the\ initial\ width\ when\ your\ test\ ends            :call <SID>RestoreInitialTW()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep033-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ ColorColumn\:\ save\ initial\ setting\ \(do\ this\ before\ below\ operations\)                        :call <SID>SaveInitialCC()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ ColorColumn\:\ show\ saved\ initial\ colorcolumn\ setting                                             :call <SID>ShowInitialCC()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ ColorColumn\:\ show\ current\ setting                                                                 :call <SID>ShowCurrentCC()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ ColorColumn\:\ set\ this\ for\ testing\,\ before\ cycling\ tests                                                            :call <SID>SetDemonstrationCC()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ ColorColumn\:\ toggle\ on\ and\ off\ \(sets\ \&tw\ to\ zero\ when\ off\)                              :call <SID>ToggleTWandCC()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).Vim\ option\ ColorColumn\:\ restore\ the\ initial\ colorcolumn\ setting\ when\ your\ test\ ends                                            :call <SID>RestoreInitialCC()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep034-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep035-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Basic\ Actions.Menu\ for\ setting\/viewing\ selected\ Vim\ options\ \(for\ newbies\).-sep036-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep037-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep038-   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep039-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Briofita\ Version     <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep040-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep041-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep042-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep043-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.View\ Briofita\ version\ and\ parameters\ \(current\ tabpage\ only\)\ --\ via\ tlib\ dialog\ if\ available :call <SID>DialogMessage(g:BriofitaVersion(1))<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Version.View\ Briofita\ version\ and\ parameters\ \(current\ tabpage\ only\)\ --\ via\ echo\*\ command             :echo g:BriofitaVersion(0)<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep044-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.View\ Briofita\ informational\ variable\ g:briofita_keys\ --\ via\ echomsg\ command   :call g:ShowBriofitaInfo()<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep045-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep046-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.NOTE\:\ below\ menu\ actions\ may\ take\ more\ time\,\ it\ depends\ on\ how\ many\ open\ tabs\ you\ have   <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep047-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep048-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ View\ Briofita\ version\ and\ parameters\ \(all\ tabpages\)\ --\ via\ tlib\ dialog\ if\ available :call <SID>DialogMessage(g:BriofitaVersion(3))<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Version.\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ View\ Briofita\ version\ and\ parameters\ \(all\ tabpages\)\ --\ via\ echo\*\ command             :echo g:BriofitaVersion(2)<cr>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep049-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.Version.-sep050-    <nop>',
        \ 'Help,\ About,\ Basics,\ Version.-sep051-   <nop>',
        \ '-sep052-       <nop>',
        \ 'Briofita\ option\ "colorcolumn"\:\ may\ be\ linked\ with\ NonText\(\*\)\,\ CursorLine\(\)    <nop>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Set\ Briofita\ colorcolumn\ option\ to\ 1\ so\ that\ it\ becomes\ linked\ to\ CursorLine       :call <SID>SetOptionCC(1)<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Set\ Briofita\ colorcolumn\ option\ to\ 0\ \(the\ default\;\ use\ it\ to\ break\ the\ linkage\ with\ CursorLine\)  :call <SID>SetOptionCC(0)<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Show\ whether\ Briofita\ ColorColumn\ option\ is\ currently\ linked\ to\ CursorLine  :call <SID>ShowBriofitaOptionCC()<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ CYCLE\ "colorcolumn"\ \(\unlink\ from\ cursorline,\ if\ linked\)      :call g:BriofitaCycleCC()<cr>',
        \ 'Briofita\ option\ "cursorline"\:\ \may\ be\ linked\ with\ CursorColumn\(\*\),\ ColorColumn\(1\)  <nop>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Global\:\ switch\ to\ global\ style\ restarting\ the\ cycle\ --\ delete\ t\:briofita_choice_for_cursorline\ ONLY\ in\ the\ current\ tabpage   :call <SID>BriofitaGlobalCL(0)<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Global\:\ switch\ to\ global\ style\ restarting\ the\ cycle\ --\ deletes\ t\:briofita_choice_for_cursorline\ in\ ALL\ tabpages                 :call <SID>BriofitaGlobalCL(1)<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Local\:\ switch\ to\ tabpage\-local\ style\ RESTARTING\ the\ cycle  :call g:BriofitaLocalCL()<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Local\:\ set\ variable\ t\:briofita_choice_for_cursorline\ to\ DEFAULT\ 0\ \(testing\)  :let t:briofita_choice_for_cursorline = 0<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Local\:\ set\ variable\ t\:briofita_choice_for_cursorline\ to\ 4\ \(testing\)  :let t:briofita_choice_for_cursorline = 4<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Local\:\ just\ DELETE\ current\ page\ t\:briofita_choice_for_cursorline  :unlet! t:briofita_choice_for_cursorline<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ Local\:\ SHOW\ \(via\ echomsg\)\ current\ value\ of\ t\:briofita_choice_for_cursorline  :call <SID>ShowTVar()<cr>',
        \ '\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ CYCLE\ "cursorline"\ \(and\ other\ linked\ options\,\ if\ any\)      :call g:BriofitaCycleCL()<cr>',
        \ 'CYCLE\ "conceal"\ Briofita\ option   :call g:BriofitaCycleConceal()<cr>',
        \ 'CYCLE\ "cursorlinenr"\ Briofita\ option   :call g:BriofitaCycleCLN()<cr>',
        \ 'CYCLE\ "diff"\ Briofita\ option   :call g:BriofitaCycleDiff()<cr>',
        \ 'CYCLE\ "foldcolumn"\ Briofita\ option   :call g:BriofitaCycleFoldColumn()<cr>',
        \ 'CYCLE\ "folded"\ Briofita\ option   :call g:BriofitaCycleFolded()<cr>',
        \ 'CYCLE\ "matchparen"\ Briofita\ option    :call g:BriofitaCycleMP()<cr>',
        \ 'CYCLE\ "mix01"\ Briofita\ option    :call g:BriofitaCycleMix01()<cr>',
        \ 'CYCLE\ "normal"\ Briofita\ option   :call g:BriofitaCycleNormal()<cr>',
        \ 'CYCLE\ "search"\ Briofita\ option   :call g:BriofitaCycleSearch()<cr>',
        \ 'CYCLE\ "special"\ Briofita\ option  :call g:BriofitaCycleSpecial()<cr>',
        \ 'TOGGLE\ "statusline"\ Briofita\ option     :call g:BriofitaToggleStatusline()<cr>',
        \ '-sep053-       <nop>',
        \ '-sep054-       <nop>']

    call s:MenuHeading()
    for menuentry in lstmenuops
        let menucmd = 'amenu  <silent> ' .
            \ s:briofita_root_menu .
            \ menuentry
        execute menucmd
    endfor
    "if a:0
    "    " additional separator at the end
    "    let menucmd = 'amenu  <silent> ' .
    "        \ s:briofita_upper_menu .
    "        \ '-sep055-    <nop>'
    "    execute menucmd
    "endif
endfunction

"
"----------------------------------------------------------------------------
"
" modeline {{{1
"
" vim: et:ts=4:sw=4:fdm=marker:fdl=0:ft=vim:
