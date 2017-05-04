function! delphinus#init#tsuquyomi#hook_source() abort
  let g:tsuquyomi_disable_default_mappings = 1
  let g:tsuquyomi_use_dev_node_module = 1
  let g:tsuquyomi_definition_split = 1
  let g:tsuquyomi_completion_detail = 1

  augroup TsuquyomiMappings
    autocmd!
    autocmd FileType typescript map <buffer> <C-]> <Plug>(TsuquyomiDefinition)
    autocmd FileType typescript map <buffer> <C-@> <Plug>(TsuquyomiReferences)
    autocmd FileType typescript nnoremap <buffer> <silent> K :<c-u>call <SID>openHint()<cr>
    autocmd CursorHold,CursorHoldI *.ts call <SID>echoHint()
  augroup END
endfunction

function! s:echoHint() abort
  let l:h = tsuquyomi#hint()
  if l:h !=# '[Tsuquyomi] There is no hint at the cursor.'
    echo split(l:h, '\n')[-1]
  endif
endfunction

function! s:openHint() abort
  call s:TsuHintView('new', 'split', tsuquyomi#hint())
endfunction

let s:buf_nr = -1

function! s:TsuHintView(newposition, position, content) abort
  " reuse existing buffer window if it exists otherwise create a new one
  if !bufexists(s:buf_nr)
    execute a:newposition
    silent file `="[Tsuquyomi]"`
    let s:buf_nr = bufnr('%')
  elseif bufwinnr(s:buf_nr) == -1
    execute a:position
    execute s:buf_nr . 'buffer'
  elseif bufwinnr(s:buf_nr) != bufwinnr('%')
    execute bufwinnr(s:buf_nr) . 'wincmd w'
  endif

  if a:position ==# 'split'
    " cap buffer height to 20, but resize it for smaller contents
    let l:max_height = 20
    let l:content_height = len(split(a:content, '\n'))
    if l:content_height > l:max_height
      execute 'resize ' . l:max_height
    else
      execute 'resize ' . l:content_height
    endif
  else
    " set a sane maximum width for vertical splits
    execute 'vertical resize 84'
  endif

  setlocal filetype=typescript
  setlocal bufhidden=delete
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nocursorline
  setlocal nocursorcolumn

  setlocal modifiable
  %delete _
  call append(0, split(a:content, '\n'))
  silent $delete _
  setlocal nomodifiable
  silent normal! gg

  " close easily with <esc> or enter
  noremap <buffer> <silent> <CR> :<C-U>close<CR>
  noremap <buffer> <silent> <Esc> :<C-U>close<CR>
endfunction
