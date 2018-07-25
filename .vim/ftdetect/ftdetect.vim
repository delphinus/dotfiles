autocmd BufNewFile,BufRead .amethyst set filetype=javascript
autocmd BufNewFile,BufRead *.jbuilder set filetype=ruby
autocmd BufNewFile,BufRead */nginx* set filetype=nginx
autocmd BufNewFile,BufRead *.m setf objc
autocmd BufNewFile,BufRead *.h setf objc
autocmd BufNewFile,BufRead *pentadactylrc*,*.penta set filetype=pentadactyl
autocmd BufNewFile,BufRead *.t call delphinus#perl#test_filetype()
autocmd BufNewFile,BufRead *.xt call delphinus#perl#test_filetype()
autocmd BufNewFile,BufRead * :if getline(1) =~ '^.*startuml.*$'|  setfiletype plantuml | endif
autocmd BufNewFile,BufRead *.psgi set filetype=perl
autocmd BufNewFile,BufRead *.pu,*.uml,*.plantuml setfiletype plantuml
autocmd BufNewFile,BufRead *.conf call delphinus#tmux#tmux_filetype()
autocmd BufNewFile,BufRead *.tt2 setf tt2html
autocmd BufNewFile,BufRead *.tt setf tt2html
autocmd BufNewFile,BufRead .zpreztorc setf zsh
autocmd BufNewFile,BufRead *.plist,*.ttx setf xml

function! s:detect_script_filetype()
  if len(&ft) == 0
    let s:matched = matchstr(getline(1), '^#!\%(.*/bin/\%(env\s\+\)\?\)\zs[a-zA-Z]\+')
    if len(s:matched) > 0
      if s:matched =~# 'sh$'
        setf sh
      else
        execute 'setf' s:matched
      endif
    endif
  endif
endfunction
autocmd BufNewFile,BufRead * call s:detect_script_filetype()
