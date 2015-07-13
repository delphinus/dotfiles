scriptencoding utf-8
let g:webdevicons_enable_nerdtree = 0
let g:webdevicons_enable_airline_statusline = 0
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
      \ 'fcgi':     '',
      \ 'markdown': '',
      \ 'perl':     '',
      \ 'rb':       '',
      \ 'sql':      '',
      \ 'sqlite':   '',
      \ 'tt':       '',
      \ 'txt':      '',
      \ }
call unite#custom#source('file_mru', 'converters', 'devicons_converter')
