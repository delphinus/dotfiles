vim.g.did_load_filetypes = 1

local function _set_filetype_sh(name)
  -- get lines from 1 to 20
  local lines = api.buf_get_lines(0, 0, 19, false)
  -- skip empty and comment lines
  local l
  for i = 1, math.min(#lines - 1, 19) do
    if  vim.regex[[^\s*\(#\|$\)]]:match_str(lines[i]) then
      l = i + 1
    end
  end
  if l and l <= #lines and vim.regex[[\s*exec\s]]:match_str(lines[l])
    and vim.regex[[^\s*#.*\\$]]:match_str(lines[l - 1]) then
    -- found an 'exec' line after a comment with continuation
    local s, e = vim.regex[[\s*exec\s\+\([^ ]*/\)\=]]:match_str(lines[l])
    if s then
      local n = lines[l]:sub(s, e)
      if vim.regex[[\<tclsh\|\<wish]]:match_str(n) then
        vim.cmd[[setf tcl]]
        return
      end
    end
  end
  vim.cmd('setf '..name)
end

local function set_filetype_sh(...)
  local args = {...}
  local name
  if #args > 0 then
    name = args[1]
  else
    local lines = api.buf_get_lines(0, 0, 1, false)
    name = #lines > 0 and lines[1] or ''
  end
  return function()
    if vim.regex[[\<csh\>]]:match_str(name) then
      return _set_filetype_sh'csh'
    elseif vim.regex[[\<tcsh\>]]:match_str(name) then
      return _set_filetype_sh'tcsh'
    elseif vim.regex[[\<zsh\>]]:match_str(name) then
      return _set_filetype_sh'zsh'
    elseif vim.regex[[\<ksh\>]]:match_str(name) then
      vim.b.is_kornshell = 1
      vim.b.is_bash = nil
      vim.b.is_sh = nil
    elseif vim.g.bash_is_sh or vim.regex[[\<bash\>]]:match_str(name)
      or vim.regex[[\<bash2\>]]:match_str(name) then
      vim.b.is_bash = 1
      vim.b.is_kornshell = nil
      vim.b.is_sh = nil
    elseif vim.regex[[\<sh\>]]:match_str(name) then
      vim.b.is_bash = 1
      vim.b.is_kornshell = nil
      vim.b.is_bash = nil
    end
    return _set_filetype_sh'sh'
  end
end

local function csh()
  if vim.g.filetype_csh then
    return _set_filetype_sh(vim.g.filetype_csh)
  elseif vim.opt.shell:get():match'tcsh' then
    return _set_filetype_sh'tcsh'
  end
  return _set_filetype_sh'csh'
end

local groups = {
  -- Apache config file
  {'.htaccess,*/etc/httpd/*.conf', 'setf apache'},
  -- Applescript
  {'*.scpt', 'setf applescript'},
  -- Awk
  {'*.awk', 'setf awk'},
  -- C
  {'*.c', 'setf c'},
  -- C++
  {'*.cxx,*.c++,*.hh,*.hxx,*.hpp,*.ipp,*.moc,*.tcc,*.inl', 'setf cpp'},
  -- .h files can be C, Ch C++, ObjC or ObjC++.
  {'*.h', 'setf c'},
  -- Cascading Style Sheets
  {'*.css', 'setf css'},
  -- Configure scripts
  {'configure.in,configure.ac', 'setf config'},
  -- CUDA  Cumpute Unified Device Architecture
  {'*.cu', 'setf cuda'},
  -- Diff files
  {'*.diff,*.rej', 'setf diff'},
  {'*.patch', function()
    local re = vim.regex[[^From [0-9a-f]\{40\} Mon Sep 17 00:00:00 2001$]]
    if re:match_line(0, 0) then
      vim.cmd[[setf gitsendemail]]
    end
      vim.cmd[[setf diff]]
  end},
  -- Dockerfile
  {'Dockerfile,*.Dockerfile','setf dockerfile'},
  -- Git
  {'COMMIT_EDITMSG', 'setf gitcommit'},
  {'MERGE_MSG', 'setf gitcommit'},
  {'*.git/config,.gitconfig,.gitmodules', 'setf gitconfig'},
  {'*.git/modules/*/config', 'setf gitconfig'},
  {'*/.config/git/config', 'setf gitconfig'},
  {'git-rebase-todo', 'setf gitrebase'},
  {'.msg.[0-9]*', function()
    if vim.regex[[^From.*# This line is ignored.$]]:match_line(0, 0) then
      vim.cmd[[setf gitsendemail]]
    end
  end},
  {'*.git/*', function()
    if vim.regex[[^\x\{40\}\>\|^ref: ]]:match_line(0, 0) then
      vim.cmd[[setf git]]
    end
  end},
  -- Go (Google)
  {'*.go', 'setf go'},
  -- Haskell
  {'*.hs,*.hs-boot', 'setf haskell'},
  {'*.lhs', 'setf lhaskell'},
  {'*.chs', 'setf chaskell'},
  -- HTML (.shtml and .stm for server side)
  {'*.html,*.htm,*.shtml,*.stm', 'setf html'},
  -- HTML with Ruby - eRuby
  {'*.erb,*.rhtml', 'setf eruby'},
  -- .INI file for MSDOS
  {'*.ini', 'setf dosini'},
  -- Java
  {'*.java,*.jav', 'setf java'},
  -- JavaScript, ECMAScript
  {'*.js,*.javascript,*.es,*.jsx', 'setf javascript'},
  -- TypeScript
  {'*.ts,*.tsx', 'setf typescript'},
  -- JSON
  {'*.json,*.jsonp', 'setf json'},
  -- Less
  {'*.less', 'setf less'},
  -- Lua
  {'*.lua,*.rockspec', 'setf lua'},
  -- Makefile
  {'*[mM]akefile,*.mk,*.mak,*.dsp', 'setf make'},
  -- Manpage
  {'*.man', 'setf man'},
  -- Man config
  {'*/etc/man.conf,man.config', 'setf manconf'},
  -- Markdown
  {'*.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md', 'setf markdown'},
  -- Matlab or Objective C
  {'*.m', 'setf objc'},
  -- Mysql
  {'*.mysql', 'setf mysql'},
  -- Password file
  {'*/etc/passwd,*/etc/passwd-,*/etc/passwd.edit,*/etc/shadow,*/etc/shadow-,'
    ..'*/etc/shadow.edit,*/var/backups/passwd.bak,*/var/backups/shadow.bak',
    'setf passwd'},
  -- Perl
  {'*.pl,*.PL,*.pm,*.fcgi', 'setf perl'},
  {'*.plx,*.al', 'setf perl'},
  {'*.p6,*.pm6,*.pl6', 'setf perl6'},
  -- Perl POD
  {'*.pod', 'setf pod'},
  {'*.pod6', 'setf pod6'},
  -- Php, php3, php4, etc.
  -- Also Phtml (was used for PHP 2 in the past)
  -- Also .ctp for Cake template file
  {[[*.php,*.php\d,*.phtml,*.ctp]], 'setf php'},
  -- Python
  {'*.py,*.pyw', 'setf python'},
  -- Readline
  {'.inputrc,inputrc', 'setf readline'},
  -- Robots.txt
  {'robots.txt', 'setf robots'},
  -- reStructuredText Documentation Format
  {'*.rst', 'setf rst'},
  -- Interactive Ruby shell
  {'.irbrc,irbrc', 'setf ruby'},
  -- Ruby
  {'*.rb,*.rbw', 'setf ruby'},
  -- RubyGems
  {'*.gemspec', 'setf ruby'},
  -- Rackup
  {'*.ru', 'setf ruby'},
  -- Bundler
  {'Gemfile', 'setf ruby'},
  -- Ruby on Rails
  {'*.builder,*.rxml,*.rjs', 'setf ruby'},
  -- Rantfile and Rakefile is like Ruby
  {'[rR]antfile,*.rant,[rR]akefile,*.rake', 'setf ruby'},
  -- Samba config
  {'smb.conf', 'setf samba'},
  -- Sass
  {'*.sass', 'setf sass'},
  -- SCSS
  {'*.scss', 'setf scss'},
  -- sed
  {'*.sed', 'setf sed'},
  -- Services
  {'*/etc/services', 'setf services'},
  -- Shell scripts (sh, ksh, bash, bash2, csh); Allow .profile_foo etc.  Gentoo
  -- ebuilds are actually bash scripts
  {
    '.bashrc*,bashrc,bash.bashrc,.bash[_-]profile*,.bash[_-]logout*,'
    ..'.bash[_-]aliases*,*.bash,*/{,.}bash[_-]completion{,.d,.sh}{,/*},'
    ..'*.ebuild,*.eclass',
    set_filetype_sh'bash',
  },
  {'.kshrc*,*.ksh', set_filetype_sh'ksh'},
  {'*/etc/profile,.profile*,*.sh,*.env', set_filetype_sh()},
  -- tcsh scripts
  {'.tcshrc*,*.tcsh,tcsh.tcshrc,tcsh.login', set_filetype_sh'tcsh'},
  -- csh scripts, but might also be tcsh scripts (on some systems csh is tcsh)
  {'.login*,.cshrc*,csh.cshrc,csh.login,csh.logout,*.csh,.alias', csh},
  -- Z-Shell script
  {'.zprofile,*/etc/zprofile,.zfbfmarks', 'setf zsh'},
  {'.zsh*,.zlog*,.zcompdump*', function()
    -- Pattern used to match file names which should not be inspected.
    -- Currently finds compressed files.
    local pattern = vim.g.ft_ignore_pat or [[\.\(Z\|gz\|bz2\|zip\|tgz\)$]]
    -- Function used for patterns that end in a star: don't set the filetype if
    -- the file name matches ft_ignore_pat.
    if not vim.regex(pattern):match_str(fn.expand'<amatch>') then
      vim.cmd[[setf zsh]]
    end
  end},
  -- Squid
  {'squid.conf', 'setf squid'},
  -- SQL
  {'*.sql', 'setf mysql'},
  -- OpenSSH configuration
  {'ssh_config,*/.ssh/config', 'setf sshconfig'},
  -- OpenSSH server configuration
  {'sshd_config', 'setf sshdconfig'},
  -- Sysctl
  {'*/etc/sysctl.conf,*/etc/sysctl.d/*.conf', 'setf sysctl'},
  -- Sudoers
  {'*/etc/sudoers,sudoers.tmp', 'setf sudoers'},
  -- SVG (Scalable Vector Graphics)
  {'*.svg', 'setf svg'},
  -- Tads (or Nroff or Perl test file)
  {'*.t,*.xt', 'setf perl'},
  -- Tags
  {'tags', 'setf tags'},
  {'tags-??', 'setf tags'},
  -- TeX
  {'*.latex,*.sty,*.dtx,*.ltx,*.bbl', 'setf tex'},
  {'*.tex', 'setf tex'},
  -- Vim script
  {'*.vim,*.vba,.exrc,_exrc', 'setf vim'},
  -- Viminfo file
  {'.viminfo,_viminfo', 'setf viminfo'},
  -- Wget config
  {'.wgetrc,wgetrc', 'setf wget'},
  -- XHTML
  {'*.xhtml,*.xht', 'setf xhtml'},
  -- XS Perl extension interface language
  {'*.xs', 'setf xs'},
  -- X resources file
  {'.Xdefaults,.Xpdefaults,.Xresources,xdm-config,*.ad', 'setf xdefaults'},
  -- XML  specific variants: docbk and xbl
  {'*.xml', 'setf xml'},
  -- XMI (holding UML models) is also XML
  {'*.xmi', 'setf xml'},
  -- CSPROJ files are Visual Studio.NET's XML-based project config files
  {'*.csproj,*.csproj.user', 'setf xml'},
  -- TPM's are RDF-based descriptions of TeX packages (Nikolai Weibull)
  {'*.tpm', 'setf xml'},
  -- Xdg menus
  {'*/etc/xdg/menus/*.menu', 'setf xml'},
  -- ATI graphics driver configuration
  {'fglrxrc', 'setf xml'},
  -- XLIFF (XML Localisation Interchange File Format) is also XML
  {'*.xlf', 'setf xml'},

  {'*.xliff', 'setf xml'},
  -- XML User Interface Language
  {'*.xul', 'setf xml'},
  -- X11 xmodmap (also see below)
  {'*Xmodmap', 'setf xmodmap'},
  -- Xquery
  {'*.xq,*.xql,*.xqm,*.xquery,*.xqy', 'setf xquery'},
  -- XSD
  {'*.xsd', 'setf xsd'},
  -- Xslt
  {'*.xsl,*.xslt', 'setf xslt'},
  -- Yacc
  {'*.yy,*.yxx,*.y++', 'setf yacc'},
  -- Yacc or racc
  {'*.y', 'setf yacc'},
  -- Yaml
  {'*.yaml,*.yml', 'setf yaml'},
  -- yum conf (close enough to dosini)
  {'*/etc/yum.conf', 'setf dosini'},
  -- More Apache config files
  {'access.conf*,apache.conf*,apache2.conf*,httpd.conf*,srm.conf*', 'setf apache'},
  {'*/etc/apache2/*.conf*,*/etc/apache2/conf.*/*,*/etc/apache2/mods-*/*,'
    ..'*/etc/apache2/sites-*/*,*/etc/httpd/conf.d/*.conf*', 'setf apache'},
  -- Crontab
  {'crontab,crontab.*,*/etc/cron.d/*', 'setf crontab'},
  -- dnsmasq(8) configuration
  {'*/etc/dnsmasq.d/*', 'setf dnsmasq'},
  -- Printcap and Termcap
  {'*printcap*', 'setf print'},

  {'*termcap*', 'setf term'},
  -- Vim script
  {'*vimrc*', 'setf vim'},
  -- Xinetd conf
  {'*/etc/xinetd.d/*', 'setf xined'},
  -- yum conf (close enough to dosini)
  {'*/etc/yum.repos.d/*', 'setf dosini'},
  -- Z-Shell script
  {'zsh*,zlog*', 'setf zsh'},
  -- Plain text files, needs to be far down to not override others.  This
  -- avoids the "conf" type being used if there is a line starting with '#'.
  {'*.txt,*.text,README', 'setf text'},
}

if vim.env.XDG_CONFIG_HOME then
  table.insert(groups, {'$XDG_CONFIG_HOME/git/config', 'setf gitconfig'})
end

require'agrp'.set{filetypedetect = {['BufNewFile,BufRead'] = groups}}

-- Use the filetype detect plugins.  They may overrule any of the previously
-- detected filetypes.
vim.cmd[[
  runtime! ftdetect/*.vim
  runtime! ftdetect/*.lua
]]

-- TODO: is this needed?
--[[
-- If the GUI is already running, may still need to install the Syntax menu.
-- Don't do it when the 'M' flag is included in 'guioptions'.
if has("menu") && has("gui_running")
      \ && !exists("did_install_syntax_menu") && &guioptions !~# "M"
  source $VIMRUNTIME/menu.vim
endif
]]
