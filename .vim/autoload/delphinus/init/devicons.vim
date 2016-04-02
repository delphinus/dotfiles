scriptencoding utf-8

function! delphinus#init#devicons#hook_add() abort
  let g:webdevicons_enable_unite = 0
  let g:webdevicons_enable_nerdtree = 0
  let g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = ''
  let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
        \ 'fcgi':     '',
        \ 'perl':     '',
        \ 'sqlite':   '',
        \ 'tt':       '',
        \ 'txt':      '',
        \ }
endfunction
