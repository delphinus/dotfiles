"-----------------------------------------------------------------------------
" TweetVim
" タイムライン選択用の Unite を起動する
nnoremap <silent> t :Unite tweetvim<CR>
" リスト表示用ショートカット
nnoremap <silent> T :TweetVimListStatuses list<CR>
" 発言用バッファを表示する
nnoremap <silent> <Leader>s :TweetVimSay<CR>
" mentions を表示する
nnoremap <silent> <Leader>re   :<C-u>TweetVimMentions<CR>
" 特定のリストのタイムラインを表示する
nnoremap <silent> <Leader>tl   :<C-u>TweetVimListStatuses list<CR>

let g:tweetvim_config_dir = g:home . '/.tweetvim'

" スクリーン名のキャッシュを利用して、neocomplcache で補完する
if !exists('g:neocomplcache_dictionary_filetype_lists')
  let g:neocomplcache_dictionary_filetype_lists = {}
endif
let neco_dic = g:neocomplcache_dictionary_filetype_lists
let neco_dic.tweetvim_say = g:tweetvim_config_dir . '/screen_name'

" 1 ページあたりのツイート取得件数
let g:tweetvim_tweet_per_page = 100


