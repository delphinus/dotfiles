"-----------------------------------------------------------------------------
" 時刻表示形式 → (月) 01/02 午後 03:45
let g:unite_source_file_mru_time_format='(%a) %m/%d %p %I:%M '
" プロンプト
let g:unite_prompt=' '
" 挿入モードで開a
let g:unite_enable_start_insert=1
" ステータスラインを書き換えない
let g:unite_force_overwrite_statusline=0

" unite-qfixhowm 対応
" 更新日時でソート
call unite#custom_source('qfixhowm', 'sorters', ['sorter_qfixhowm_updatetime', 'sorter_reverse'])
" デフォルトアクション
let g:unite_qfixhowm_new_memo_cmd='dwm_new'

" データファイル
if is_office
    let g:unite_data_directory = expand('$H/.unite')
endif
noremap zp :Unite buffer_tab file_mru<CR>
noremap zn :UniteWithBufferDir -buffer-name=files file file/new<CR>
noremap zr :Unite file_rec/async<CR>
noremap zd :Unite dwm<CR>
noremap zf :Unite qfixhowm/new qfixhowm<CR>
noremap zF :Unite qfixhowm/new qfixhowm:nocache<CR>
noremap <Leader>uu :Unite bookmark<CR>
noremap <Leader>uc :Unite colorscheme<CR>
noremap <Leader>ul :Unite locate<CR>
noremap <Leader>uv :Unite buffer -input=vimshell<CR>
noremap <Leader>vu :Unite buffer -input=vimshell<CR>
autocmd FileType unite call s:unite_my_settings()
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '\$\w\+',
            \ 'subst': '\=eval(submatch(0))',
            \ 'priority': 200,
            \ })
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '^@@',
            \ 'subst': '\=fnamemodify(expand("#"), ":p:h")."/"',
            \ 'priority': 2,
            \ })
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '^@',
            \ 'subst': '\=getcwd()."/*"',
            \ 'priority': 1,
            \ })
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '^;r',
            \ 'subst': '\=$VIMRUNTIME."/"',
            \ 'priority': 1,
            \ })
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '^\~',
            \ 'subst': escape($HOME, '\'),
            \ 'priority': -2,
            \ })
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '\\\@<! ',
            \ 'subst': '\\ ',
            \ 'priority': -20,
            \ })
call unite#custom#profile('files', 'substitute_patterns', {
            \ 'pattern': '\\ \@!',
            \ 'subst': '/',
            \ 'priority': -30,
            \ })
if is_office
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;h',
                \ 'subst': '\=$H."/"',
                \ 'priority': 1,
                \ })
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;v',
                \ 'subst': '\=$H."/.vim/"',
                \ 'priority': 1,
                \ })
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;g',
                \ 'subst': '\=$H."/git/"',
                \ 'priority': 1,
                \ })
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;d',
                \ 'subst': '\=$H."/git/dotfiles/"',
                \ 'priority': 1,
                \ })
else
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;v',
                \ 'subst': '~/.vim/',
                \ 'priority': 1,
                \ })
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;g',
                \ 'subst': escape($HOME, '\') . '/git/',
                \ 'priority': 1,
                \ })
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;d',
                \ 'subst': escape($HOME, '\') . '/git/dotfiles/',
                \ 'priority': 1,
                \ })
endif
if has('win32') || has('win64')
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;p',
                \ 'subst': 'C:/Program Files/',
                \ 'priority': 1,
                \ })
    call unite#custom#profile('files', 'substitute_patterns', {
                \ 'pattern': '^;u',
                \ 'subst': escape($USERPROFILE, '\') . '/',
                \ 'priority': 1,
                \ })
endif

" vcscommand.vim の diff buffer を消す
call unite#custom_filters('buffer,buffer_tab',
            \ ['matcher_default', 'sorter_default', 'converter_erase_diff_buffer'])

" 大文字小文字を区別しない
call unite#set_profile('files', 'ignorecase', 1)
call unite#set_profile('file_mru', 'ignorecase', 1)

function! s:unite_my_settings()
    " 上下に分割して開く
    nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
    inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
    " 左右に分割して開く
    nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
    inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
    " タブで開く
    nnoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
    inoremap <silent> <buffer> <expr> <C-T> unite#do_action('tabopen')
    " vimfiler で開く
    nnoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
    inoremap <silent> <buffer> <expr> <C-O> unite#do_action('vimfiler')
    " dwm.vim で開く
    nnoremap <silent> <buffer> <expr> <C-N> unite#do_action('dwm_new')
    inoremap <silent> <buffer> <expr> <C-N> unite#do_action('dwm_new')
    " 終了
    nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
    inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>

    imap <buffer> <C-w>     <Plug>(unite_delete_backward_path)
endfunction
