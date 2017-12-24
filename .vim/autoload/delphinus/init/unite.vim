scriptencoding utf-8

function! delphinus#init#unite#hook_source() abort
  " 時刻表示形式 → (月) 01/02 午後 03:45
  let g:neomru#time_format='(%m/%d %k:%M) '
  " ファイル名形式
  let g:neomru#filename_format = ':~:.'
  " プロンプト
  let g:unite_prompt='❯ '
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
  if executable('rg')
    let g:unite_source_grep_command = 'rg'
    let g:unite_source_grep_default_opts = '--color never -n'
    let g:unite_source_grep_recursive_opt = ''
    let g:unite_source_file_async_command = 'rg --color never -l .'
  elseif executable('pt')
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
