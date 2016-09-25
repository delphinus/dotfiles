scriptencoding utf-8
command! SyntaxInfo call delphinus#syntax_info#get_info()

augroup QuickFixWindowHeight
  autocmd!
  autocmd FileType qf call delphinus#quickfix#set_height(3, 10)
  autocmd FileType qf setlocal colorcolumn=
  autocmd FileType qf highlight! link Search IncSearch
  autocmd WinEnter * if &filetype ==# 'qf' | call delphinus#quickfix#set_height(3, 10) | endif
augroup END
