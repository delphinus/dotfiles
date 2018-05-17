scriptencoding utf-8

function! delphinus#init#denite#hook_source() abort
  " Use pt for searching files
  call denite#custom#var('grep', 'command', ['pt'])
  call denite#custom#var('grep', 'default_opts', ['--nogroup', '--nocolor', '--smart-case', '--ignore=.git'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'separator', ['--'])
  call denite#custom#var('grep', 'final_opts', [])
  call denite#custom#var('file_rec', 'command', ['pt', '--follow', '--nocolor', '--nogroup', '--vcs-ignore=', '--ignore=.git', '-g', ''])
  call denite#custom#var('my_file_rec', 'command', ['pt', '--follow', '--nocolor', '--nogroup', '--vcs-ignore=', '--ignore=.git', '-g', ''])

  call denite#custom#action('file', 'dwm_new', function('s:dwm_new'))
  call denite#custom#action('buffer', 'dwm_new', function('s:dwm_new'))
  call denite#custom#action('memo', 'dwm_new', function('s:dwm_new'))
  call denite#custom#action('directory', 'my_file_rec', {ctx -> s:start_action_for_path(ctx, 'file_rec')})
  call denite#custom#action('directory', 'grep', {ctx -> s:start_action_for_path(ctx, 'grep')})
  call denite#custom#action('file', 'grep', function('s:narrow_grep'))
  call denite#custom#map('insert', '<BS>', '<denite:move_up_path>')
  call denite#custom#map('insert', '<C-a>', '<denite:do_action:my_file_rec>')
  call denite#custom#map('insert', '<C-f>', 'Denite_toggle_sorter("sorter_abbr")', 'noremap expr nowait')
  call denite#custom#map('insert', '<C-g>', '<denite:do_action:grep>')
  call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>', 'noremap')
  call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>', 'noremap')
  call denite#custom#map('insert', '<C-n>', '<denite:do_action:dwm_new>')
  call denite#custom#map('insert', '<C-t>', '<denite:input_command_line>', 'noremap')
  call denite#custom#map('insert', '<Esc>', '<denite:enter_mode:normal>')
  call denite#custom#map('insert', '~', expand('~'), 'noremap')
  call denite#custom#source('_', 'matchers', ['matcher_substring'])
  call denite#custom#source('grep', 'args', ['', '', '!'])
  call denite#custom#source('grep', 'sorters', ['sorter_abbr'])
  call denite#custom#source('grep', 'converters', ['converter_abbr_word'])
  call denite#custom#source('my_file_rec', 'converters', ['devicons_denite_converter'])
  " ref. https://github.com/arcticicestudio/nord-vim/issues/79
  call denite#custom#option('default', {
        \ 'prompt': '❯❯❯',
        \ 'statusline': v:false,
        \ 'highlight_matched_char': 'Underlined',
        \ 'cursor_wrap': v:true,
        \ })
  call denite#custom#option('dein', 'default_action', 'narrow')
endfunction

function! s:dwm_new(context)
  call DWM_New()
  call denite#do_action(a:context, 'open', a:context['targets'])
endfunction

function! s:start_action_for_path(context, action, ...)
  let target = a:context['targets'][0]
  let path = get(target, 'action__path', '')
  if isdirectory(path)
    if a:action ==# 'grep'
      call denite#start([{'name': 'grep', 'args': [path, '', '!']}])
    else
      call denite#start([{'name': a:action, 'args': [path]}])
    endif
  else
    call denite#util#print_error(printf('unknown path for target: %s', target))
  endif
endfunction

function! s:narrow_grep(context, ...) abort
  let sources = get(a:context, 'sources', [])
  let filtered = filter(copy(sources), {i, v -> get(v, 'name', '') ==# 'grep'})
  if len(filtered) == 0
    call denite#util#print_error('current sources does not include `grep`.')
    return
  endif
  let args = get(filtered[0], 'args', [])
  let pattern = get(args, 2, '')
  if pattern !=# '!'
    call denite#util#print_error('current grep source is not interactive')
    return
  endif
  let input = get(a:context, 'input', '')
  let pattern = substitute(input, '\s\+', '.*', 'g')
  call denite#start([{'name': 'grep', 'args': [args[0], args[1], pattern]}])
endfunction

function! Denite_toggle_sorter(sorter) abort
  let sorters = split(b:denite_context.sorters, ',')
  let i = index(sorters, a:sorter)
  if i < 0
    call add(sorters, a:sorter)
  else
    call remove(sorters, i)
  endif
  let b:denite_new_context = {}
  let b:denite_new_context.sorters = join(sorters, ',')
  return '<denite:nop>'
endfunction
