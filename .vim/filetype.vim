let s:cpo_save = &cpo
set cpo&vim

augroup filetypedetect

" Apache config file
au BufNewFile,BufRead .htaccess,*/etc/httpd/*.conf		setf apache

" Applescript
au BufNewFile,BufRead *.scpt			setf applescript

" Awk
au BufNewFile,BufRead *.awk			setf awk

" C
au BufNewFile,BufRead *.c			setf c

" C++
au BufNewFile,BufRead *.cxx,*.c++,*.hh,*.hxx,*.hpp,*.ipp,*.moc,*.tcc,*.inl setf cpp

" .h files can be C, Ch C++, ObjC or ObjC++.
au BufNewFile,BufRead *.h			setf c

" Cascading Style Sheets
au BufNewFile,BufRead *.css			setf css

" Configure scripts
au BufNewFile,BufRead configure.in,configure.ac setf config

" CUDA  Cumpute Unified Device Architecture
au BufNewFile,BufRead *.cu			setf cuda

" Diff files
au BufNewFile,BufRead *.diff,*.rej		setf diff
au BufNewFile,BufRead *.patch
	\ if getline(1) =~ '^From [0-9a-f]\{40\} Mon Sep 17 00:00:00 2001$' |
	\   setf gitsendemail |
	\ else |
	\   setf diff |
	\ endif

" Dockerfile
au BufNewFile,BufRead Dockerfile,*.Dockerfile	setf dockerfile

" Git
au BufNewFile,BufRead COMMIT_EDITMSG		setf gitcommit
au BufNewFile,BufRead MERGE_MSG			setf gitcommit
au BufNewFile,BufRead *.git/config,.gitconfig,.gitmodules setf gitconfig
au BufNewFile,BufRead *.git/modules/*/config	setf gitconfig
au BufNewFile,BufRead */.config/git/config	setf gitconfig
if !empty($XDG_CONFIG_HOME)
  au BufNewFile,BufRead $XDG_CONFIG_HOME/git/config	setf gitconfig
endif
au BufNewFile,BufRead git-rebase-todo		setf gitrebase
au BufNewFile,BufRead .msg.[0-9]*
      \ if getline(1) =~ '^From.*# This line is ignored.$' |
      \   setf gitsendemail |
      \ endif
au BufNewFile,BufRead *.git/*
      \ if getline(1) =~ '^\x\{40\}\>\|^ref: ' |
      \   setf git |
      \ endif

" Go (Google)
au BufNewFile,BufRead *.go			setf go

" Haskell
au BufNewFile,BufRead *.hs,*.hs-boot		setf haskell
au BufNewFile,BufRead *.lhs			setf lhaskell
au BufNewFile,BufRead *.chs			setf chaskell

" HTML (.shtml and .stm for server side)
au BufNewFile,BufRead *.html,*.htm,*.shtml,*.stm  setf html

" HTML with Ruby - eRuby
au BufNewFile,BufRead *.erb,*.rhtml		setf eruby

" .INI file for MSDOS
au BufNewFile,BufRead *.ini			setf dosini

" Java
au BufNewFile,BufRead *.java,*.jav		setf java

" JavaScript, ECMAScript
au BufNewFile,BufRead *.js,*.javascript,*.es,*.jsx   setf javascript

" JSON
au BufNewFile,BufRead *.json,*.jsonp		setf json

" Less
au BufNewFile,BufRead *.less			setf less

" Lua
au BufNewFile,BufRead *.lua			setf lua

" Makefile
au BufNewFile,BufRead *[mM]akefile,*.mk,*.mak,*.dsp setf make

" Manpage
au BufNewFile,BufRead *.man			setf man

" Man config
au BufNewFile,BufRead */etc/man.conf,man.config	setf manconf

" Markdown
au BufNewFile,BufRead *.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md  setf markdown

" Matlab or Objective C
au BufNewFile,BufRead *.m			setf objc

" Mysql
au BufNewFile,BufRead *.mysql			setf mysql

" Password file
au BufNewFile,BufRead */etc/passwd,*/etc/passwd-,*/etc/passwd.edit,*/etc/shadow,*/etc/shadow-,*/etc/shadow.edit,*/var/backups/passwd.bak,*/var/backups/shadow.bak setf passwd

" Perl
au BufNewFile,BufRead *.pl,*.PL,*.pm,*.fcgi		setf perl
au BufNewFile,BufRead *.plx,*.al		setf perl
au BufNewFile,BufRead *.p6,*.pm6,*.pl6		setf perl6

" Perl POD
au BufNewFile,BufRead *.pod			setf pod
au BufNewFile,BufRead *.pod6			setf pod6

" Php, php3, php4, etc.
" Also Phtml (was used for PHP 2 in the past)
" Also .ctp for Cake template file
au BufNewFile,BufRead *.php,*.php\d,*.phtml,*.ctp	setf php

" Python
au BufNewFile,BufRead *.py,*.pyw		setf python

" Readline
au BufNewFile,BufRead .inputrc,inputrc		setf readline

" Robots.txt
au BufNewFile,BufRead robots.txt		setf robots

" reStructuredText Documentation Format
au BufNewFile,BufRead *.rst			setf rst

" Interactive Ruby shell
au BufNewFile,BufRead .irbrc,irbrc		setf ruby

" Ruby
au BufNewFile,BufRead *.rb,*.rbw		setf ruby

" RubyGems
au BufNewFile,BufRead *.gemspec			setf ruby

" Rackup
au BufNewFile,BufRead *.ru			setf ruby

" Bundler
au BufNewFile,BufRead Gemfile			setf ruby

" Ruby on Rails
au BufNewFile,BufRead *.builder,*.rxml,*.rjs	setf ruby

" Rantfile and Rakefile is like Ruby
au BufNewFile,BufRead [rR]antfile,*.rant,[rR]akefile,*.rake	setf ruby

" Samba config
au BufNewFile,BufRead smb.conf			setf samba

" Sass
au BufNewFile,BufRead *.sass			setf sass

" SCSS
au BufNewFile,BufRead *.scss			setf scss

" sed
au BufNewFile,BufRead *.sed			setf sed

" Services
au BufNewFile,BufRead */etc/services		setf services

" Shell scripts (sh, ksh, bash, bash2, csh); Allow .profile_foo etc.
" Gentoo ebuilds are actually bash scripts
au BufNewFile,BufRead .bashrc*,bashrc,bash.bashrc,.bash[_-]profile*,.bash[_-]logout*,.bash[_-]aliases*,*.bash,*/{,.}bash[_-]completion{,.d,.sh}{,/*},*.ebuild,*.eclass call SetFileTypeSH("bash")
au BufNewFile,BufRead .kshrc*,*.ksh call SetFileTypeSH("ksh")
au BufNewFile,BufRead */etc/profile,.profile*,*.sh,*.env call SetFileTypeSH(getline(1))

" Also called from scripts.vim.
func! SetFileTypeSH(name)
  if a:name =~ '\<csh\>'
    " Some .sh scripts contain #!/bin/csh.
    call SetFileTypeShell("csh")
    return
  elseif a:name =~ '\<tcsh\>'
    " Some .sh scripts contain #!/bin/tcsh.
    call SetFileTypeShell("tcsh")
    return
  elseif a:name =~ '\<zsh\>'
    " Some .sh scripts contain #!/bin/zsh.
    call SetFileTypeShell("zsh")
    return
  elseif a:name =~ '\<ksh\>'
    let b:is_kornshell = 1
    if exists("b:is_bash")
      unlet b:is_bash
    endif
    if exists("b:is_sh")
      unlet b:is_sh
    endif
  elseif exists("g:bash_is_sh") || a:name =~ '\<bash\>' || a:name =~ '\<bash2\>'
    let b:is_bash = 1
    if exists("b:is_kornshell")
      unlet b:is_kornshell
    endif
    if exists("b:is_sh")
      unlet b:is_sh
    endif
  elseif a:name =~ '\<sh\>'
    let b:is_sh = 1
    if exists("b:is_kornshell")
      unlet b:is_kornshell
    endif
    if exists("b:is_bash")
      unlet b:is_bash
    endif
  endif
  call SetFileTypeShell("sh")
endfunc

" For shell-like file types, check for an "exec" command hidden in a comment,
" as used for Tcl.
" Also called from scripts.vim, thus can't be local to this script.
func! SetFileTypeShell(name)
  let l = 2
  while l < 20 && l < line("$") && getline(l) =~ '^\s*\(#\|$\)'
    " Skip empty and comment lines.
    let l = l + 1
  endwhile
  if l < line("$") && getline(l) =~ '\s*exec\s' && getline(l - 1) =~ '^\s*#.*\\$'
    " Found an "exec" line after a comment with continuation
    let n = substitute(getline(l),'\s*exec\s\+\([^ ]*/\)\=', '', '')
    if n =~ '\<tclsh\|\<wish'
      setf tcl
      return
    endif
  endif
  exe "setf " . a:name
endfunc

" tcsh scripts
au BufNewFile,BufRead .tcshrc*,*.tcsh,tcsh.tcshrc,tcsh.login	call SetFileTypeShell("tcsh")

" csh scripts, but might also be tcsh scripts (on some systems csh is tcsh)
au BufNewFile,BufRead .login*,.cshrc*,csh.cshrc,csh.login,csh.logout,*.csh,.alias  call s:CSH()

func! s:CSH()
  if exists("g:filetype_csh")
    call SetFileTypeShell(g:filetype_csh)
  elseif &shell =~ "tcsh"
    call SetFileTypeShell("tcsh")
  else
    call SetFileTypeShell("csh")
  endif
endfunc

" Pattern used to match file names which should not be inspected.
" Currently finds compressed files.
if !exists("g:ft_ignore_pat")
  let g:ft_ignore_pat = '\.\(Z\|gz\|bz2\|zip\|tgz\)$'
endif

" Function used for patterns that end in a star: don't set the filetype if the
" file name matches ft_ignore_pat.
func! s:StarSetf(ft)
  if expand("<amatch>") !~ g:ft_ignore_pat
    exe 'setf ' . a:ft
  endif
endfunc

" Z-Shell script
au BufNewFile,BufRead .zprofile,*/etc/zprofile,.zfbfmarks  setf zsh
au BufNewFile,BufRead .zsh*,.zlog*,.zcompdump*  call s:StarSetf('zsh')
au BufNewFile,BufRead *.zsh			setf zsh

" Squid
au BufNewFile,BufRead squid.conf		setf squid

" SQL
au BufNewFile,BufRead *.sql			setf mysql

" OpenSSH configuration
au BufNewFile,BufRead ssh_config,*/.ssh/config	setf sshconfig

" OpenSSH server configuration
au BufNewFile,BufRead sshd_config		setf sshdconfig

" Sysctl
au BufNewFile,BufRead */etc/sysctl.conf,*/etc/sysctl.d/*.conf	setf sysctl

" Sudoers
au BufNewFile,BufRead */etc/sudoers,sudoers.tmp	setf sudoers

" SVG (Scalable Vector Graphics)
au BufNewFile,BufRead *.svg			setf svg

" Tads (or Nroff or Perl test file)
au BufNewFile,BufRead *.t,*.xt setf perl

" Tags
au BufNewFile,BufRead tags			setf tags
au BufNewFile,BufRead tags-?? setf tags

" TeX
au BufNewFile,BufRead *.latex,*.sty,*.dtx,*.ltx,*.bbl	setf tex
au BufNewFile,BufRead *.tex			setf tex

" Vim script
au BufNewFile,BufRead *.vim,*.vba,.exrc,_exrc	setf vim

" Viminfo file
au BufNewFile,BufRead .viminfo,_viminfo		setf viminfo

" Wget config
au BufNewFile,BufRead .wgetrc,wgetrc		setf wget

" XHTML
au BufNewFile,BufRead *.xhtml,*.xht		setf xhtml

" XS Perl extension interface language
au BufNewFile,BufRead *.xs			setf xs

" X resources file
au BufNewFile,BufRead .Xdefaults,.Xpdefaults,.Xresources,xdm-config,*.ad setf xdefaults

" XML  specific variants: docbk and xbl
au BufNewFile,BufRead *.xml			setf xml

" XMI (holding UML models) is also XML
au BufNewFile,BufRead *.xmi			setf xml

" CSPROJ files are Visual Studio.NET's XML-based project config files
au BufNewFile,BufRead *.csproj,*.csproj.user	setf xml

" TPM's are RDF-based descriptions of TeX packages (Nikolai Weibull)
au BufNewFile,BufRead *.tpm			setf xml

" Xdg menus
au BufNewFile,BufRead */etc/xdg/menus/*.menu	setf xml

" ATI graphics driver configuration
au BufNewFile,BufRead fglrxrc			setf xml

" XLIFF (XML Localisation Interchange File Format) is also XML
au BufNewFile,BufRead *.xlf			setf xml
au BufNewFile,BufRead *.xliff			setf xml

" XML User Interface Language
au BufNewFile,BufRead *.xul			setf xml

" X11 xmodmap (also see below)
au BufNewFile,BufRead *Xmodmap			setf xmodmap

" Xquery
au BufNewFile,BufRead *.xq,*.xql,*.xqm,*.xquery,*.xqy	setf xquery

" XSD
au BufNewFile,BufRead *.xsd			setf xsd

" Xslt
au BufNewFile,BufRead *.xsl,*.xslt		setf xslt

" Yacc
au BufNewFile,BufRead *.yy,*.yxx,*.y++		setf yacc

" Yacc or racc
au BufNewFile,BufRead *.y			setf yacc

" Yaml
au BufNewFile,BufRead *.yaml,*.yml		setf yaml

" yum conf (close enough to dosini)
au BufNewFile,BufRead */etc/yum.conf		setf dosini

" More Apache config files
au BufNewFile,BufRead access.conf*,apache.conf*,apache2.conf*,httpd.conf*,srm.conf*	setf apache
au BufNewFile,BufRead */etc/apache2/*.conf*,*/etc/apache2/conf.*/*,*/etc/apache2/mods-*/*,*/etc/apache2/sites-*/*,*/etc/httpd/conf.d/*.conf*		setf apache

" Crontab
au BufNewFile,BufRead crontab,crontab.*,*/etc/cron.d/*		setf crontab

" dnsmasq(8) configuration
au BufNewFile,BufRead */etc/dnsmasq.d/*		setf dnsmasq

" Printcap and Termcap
au BufNewFile,BufRead *printcap* setf print
au BufNewFile,BufRead *termcap* setf term

" Vim script
au BufNewFile,BufRead *vimrc*			setf vim

" Xinetd conf
au BufNewFile,BufRead */etc/xinetd.d/*		setf xined

" yum conf (close enough to dosini)
au BufNewFile,BufRead */etc/yum.repos.d/*	setf dosini

" Z-Shell script
au BufNewFile,BufRead zsh*,zlog*		setf zsh

" Plain text files, needs to be far down to not override others.  This avoids
" the "conf" type being used if there is a line starting with '#'.
au BufNewFile,BufRead *.txt,*.text,README	setf text

" Use the filetype detect plugins.  They may overrule any of the previously
" detected filetypes.
runtime! ftdetect/*.vim

" If the GUI is already running, may still need to install the Syntax menu.
" Don't do it when the 'M' flag is included in 'guioptions'.
if has("menu") && has("gui_running")
      \ && !exists("did_install_syntax_menu") && &guioptions !~# "M"
  source $VIMRUNTIME/menu.vim
endif

augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
