"-----------------------------------------------------------------------------
" Perl 関連
let perl_include_pod=1
if is_office
	autocmd BufNewFile,BufRead *.conf set filetype=perl
	autocmd BufNewFile,BufRead _inc_html.txt set filetype=html
endif

" zencoding-vim
let g:user_zen_settings = {
\   'indentation' : '    ',
\   'lang' : 'ja',
\   'perl' : {
\       'aliases' : {
\           'req' : 'require '
\       },
\       'snippets' : {
\           'use' : "#!/usr/bin/perl;\nuse utf8;\nuse strict\nuse warnings\nuse errors -with_using;\nuse feature qw! say !;\n\n",
\           'moose' : "#!/usr/bin/perl;\nuse utf8;\nuse Moose;\nuse errors -with_using;\nuse feature qw! say !;\n\n|\n\n__PACKAGE__->meta->make_immutable;",
\       }
\   }
\}
let g:user_zen_expandabbr_key = '<c-q>'
let g:user_zen_complete_tag = 1


