scriptencoding utf-8

function! delphinus#init#unite#hook_add() abort
  noremap za :Unite file_rec/async<CR>
  noremap zd :Unite dwm<CR>
  noremap zf :Unite qfixhowm/new qfixhowm<CR>
  noremap zF :Unite qfixhowm/new qfixhowm:nocache<CR>
  noremap zg :Unite file_rec/git<CR>
  noremap zG :Unite grep:.:--hidden:
  "noremap <c-]> :UniteWithCursorWord -immediately tag/include<CR>
  noremap zi :Unite tig<CR>
  noremap zI :Unite gista<CR>
  noremap zl :Unite outline<CR>
  noremap zn :UniteWithBufferDir -buffer-name=files file file/new<CR>
  noremap zu :Unite bundler<CR>
  noremap zT :Unite tab<CR>
  noremap zN :Unite -buffer-name=files file file/new<CR>
  noremap zp :Unite dwm buffer_tab file_mru:long<CR>
  noremap zP :Unite yankround<CR>
  noremap zh :Unite ghq<CR>
  noremap ZB :Unite rails/bundle<CR>
  noremap ZC :Unite rails/controller<CR>
  noremap ZD :Unite rails/db<CR>
  noremap ZG :Unite rails/bundled_gem<CR>
  noremap ZH :Unite rails/helper<CR>
  noremap ZJ :Unite rails/javascript<CR>
  noremap ZL :Unite rails/lib<CR>
  noremap ZM :Unite rails/model<CR>
  noremap ZO :Unite rails/command<CR>
  noremap ZR :Unite rails/route<CR>
  noremap ZS :Unite rails/spec<CR>
  noremap ZT :Unite tsproject<CR>
  noremap ZV :Unite rails/view<CR>
  noremap Zc :Unite rails/config<CR>
  noremap Zj :Unite rails/json_schema<CR>
  noremap Zl :Unite rails/log<CR>
  noremap Zm :Unite rails/mailer<CR>
  noremap Zr :Unite rails/root<CR>
  noremap Zs :Unite rails/stylesheet<CR>
endfunction

function! delphinus#init#unite#hook_source() abort
  " 時刻表示形式 → (月) 01/02 午後 03:45
  let g:neomru#time_format='(%m/%d %k:%M) '
  " ファイル名形式
  let g:neomru#filename_format = ':~:.'
  " プロンプト
  let g:unite_prompt=' '
  " ステータスラインを書き換えない
  let g:unite_force_overwrite_statusline=0
  " ロングリストにたくさんファイルを保存
  let g:neomru#file_mru_limit=100000
  " 非同期検索の候補アイテム上限値
  let g:unite_source_file_rec_max_cache_files=100000
  " 画面を縦に分割して開かない
  let g:unite_enable_split_vertically=0

  " unite-qfixhowm 対応
  " 更新日時でソート
  call unite#custom#source('qfixhowm', 'sorters', ['sorter_qfixhowm_updatetime', 'sorter_reverse'])
  " デフォルトアクション
  let g:unite_qfixhowm_new_memo_cmd='dwm_new'

  " カスタムマッピング
  augroup UniteMySettings
    autocmd!
    autocmd FileType unite call delphinus#unite#my_setting()
  augroup END

  " インサートモードで開始
  call unite#custom#profile('default', 'context', {'start_insert': 1})

  " agとUnite.vimで快適高速grep環境を手に入れる - Thinking-megane
  " http://blog.monochromegane.com/blog/2013/09/18/ag-and-unite/
  " 大文字小文字を区別しない
  let g:unite_enable_ignore_case = 1
  let g:unite_enable_smart_case = 1

  " unite grep に ag(The Silver Searcher) を使う
  if executable('pt')
      let g:unite_source_grep_command = 'pt'
      let g:unite_source_grep_default_opts = '--nogroup --nocolor'
      let g:unite_source_grep_recursive_opt = ''
      let g:unite_source_file_async_command = 'pt --nocolor --nogroup -g .'
  elseif executable('ag')
      let g:unite_source_grep_command = 'ag'
      let g:unite_source_grep_default_opts = '-a --nogroup --nocolor --column'
      let g:unite_source_grep_recursive_opt = ''
      let g:unite_source_file_async_command = 'ag --follow --nocolor --nogroup --hidden -g ""'
  endif

  " devicons 設定
  call unite#custom#default_action('source/bundler/directory', 'file')

  let s:source_names_to_apply_filter = [
        \ 'file',
        \ 'file_rec/git',
        \ 'file_rec/async',
        \ 'ghq',
        \ 'rails/bundle',
        \ 'rails/controller',
        \ 'rails/db',
        \ 'rails/bundled_gem',
        \ 'rails/helper',
        \ 'rails/javascript',
        \ 'rails/lib',
        \ 'rails/model',
        \ 'rails/command',
        \ 'rails/route',
        \ 'rails/spec',
        \ 'rails/view',
        \ 'rails/config',
        \ 'rails/json_schema',
        \ 'rails/log',
        \ 'rails/mailer',
        \ 'rails/root',
        \ 'rails/stylesheet',
        \ 'z',
        \ ]

  let s:converter = delphinus#devicons#converter()
  call unite#define_filter(s:converter)
  call unite#custom#source(join(s:source_names_to_apply_filter, ','), 'converters', [s:converter.name])
  unlet s:converter

  let s:mru = delphinus#devicons#mru()
  call unite#define_filter(s:mru)
  call unite#custom#source('file_mru', 'converters', [s:mru.name])
  unlet s:mru

  " gista 設定
  call unite#custom#action('gista', 'yank_url_to_system_clipboard', delphinus#gista#yank_url_to_system_clipboard())
  call unite#custom#action('gista', 'open_browser', delphinus#gista#open_browser())
endfunction
