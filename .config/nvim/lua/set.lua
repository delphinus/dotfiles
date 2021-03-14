-- Encodings {{{
vim.o.fileencoding = 'utf-8'
vim.bo.fileencoding = 'utf-8'
if vim.fn.has'gui_macvim' == 0 then
  vim.o.fileencodings = 'ucs-bom,utf-8,eucjp,cp932,ucs-2le,latin1,iso-2022-jp'
end
-- }}}

--Tabs {{{
vim.o.expandtab = true
vim.bo.expandtab = true
vim.o.shiftwidth = 2
vim.bo.shiftwidth = 2
vim.o.softtabstop = 2
vim.bo.softtabstop = 2
vim.o.tabstop = 2
vim.bo.tabstop = 2
-- }}}

-- Undo {{{
vim.o.undofile = true
vim.bo.undofile = true
-- }}}

-- Searching {{{
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'
-- }}}

-- Display {{{
vim.o.cmdheight = 2
vim.o.colorcolumn = '80,140'
vim.wo.colorcolumn = '80,140'
vim.o.list = true
vim.wo.list = true
vim.o.listchars = 'tab:▓░,trail:↔,eol:⏎,extends:→,precedes:←,nbsp:␣'
vim.o.ruler = false
vim.o.showmode = false
vim.o.number = true
vim.wo.number = true
vim.o.numberwidth = 3
vim.wo.numberwidth = 3
vim.o.relativenumber = true
vim.wo.relativenumber = true
vim.o.showmatch = true
vim.o.showtabline = 2

if vim.fn.exists'*setcellwidths' == 1 then
  vim.fn.setcellwidths({
    --{0x2329, 0x2329, 1}, -- 〈
    --{0x232a, 0x232a, 1}, -- 〈
    {0x23be, 0x23cc, 2}, -- ⎾  .. ⏌
    {0x2469, 0x24e9, 2}, -- ⑩ .. ⓩ
    {0x24eb, 0x24fe, 2}, -- ⓫ .. ⓾
    {0x2600, 0x266f, 2}, -- ☀ .. ♯

    -- {0x23cf, 0x23cf, 2}, -- ⏏
    -- {0x23fb, 0x23fe, 2}, -- ⏻  .. ⏾ -- power-symbols-1
    {0x2b58, 0x2b58, 2}, -- ⭘ -- power-symbols-2
    {0xe000, 0xe00a, 2}, --  ..  -- pomicons
    -- {0xe0a0, 0xe0a2, 1}, --  ..  -- powerline-1
    -- {0xe0b0, 0xe0b3, 1}, --  ..  -- powerline-2
    -- {0xe0a3, 0xe0a3, 1}, --  -- powerline-extra-1
    -- {0xe0b4, 0xe0b7, 1}, --  ..  -- powerline-extra-2
    {0xe0b8, 0xefff, 2}, --  ..  -- material-1
    {0xf500, 0xf546, 2}, --  ..  -- material-2
  })
end
-- }}}

-- Indents and arranging formats {{{
vim.o.breakindent = true
vim.wo.breakindent = true
vim.o.formatoptions = add_option_string(vim.o.formatoptions,'nmMj')
vim.bo.formatoptions = vim.o.formatoptions
vim.o.formatlistpat = [[^\s*\%(\d\+\|[-a-z]\)\%(\ -\|[]:.)}\t]\)\?\s\+]]
vim.bo.formatlistpat = vim.o.formatlistpat
vim.o.fixendofline = false
vim.bo.fixendofline = false
vim.o.showbreak = [[→  ]]
vim.o.smartindent = true
vim.bo.smartindent = true
-- }}}

-- Mouse
vim.o.mouse = 'a'

-- ColorScheme {{{
vim.o.termguicolors = true
vim.cmd'syntax enable'

function _G.toggle_colorscheme()
  local scheme
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
    scheme = 'nord'
  else
    vim.o.background = 'light'
    scheme = 'solarized8'
  end
  vim.cmd('colorscheme '..scheme)
end

vim.cmd'command! ToggleColorscheme lua toggle_colorscheme()'

-- Use Solarized Light when iTerm2 reports 11;15 for $COLORFGBG
local is_light = vim.env.COLORFGBG == '11;15'
if is_light then
  vim.g.background = 'light'
end
local scheme
if is_light or vim.env.SOLARIZED then
  scheme = 'solarized8'
else
  scheme = 'nord'
end
require'augroups'.set{
  set_colorscheme = {
    {'VimEnter', '*', 'doautocmd ColorScheme '..scheme},
  },
}
vim.cmd('colorscheme '..scheme)
-- }}}

-- Title {{{
if vim.env.TMUX then
  vim.o.t_ts = [[k]]
  vim.o.t_fs = [[\]]
end
vim.o.title = true
local home_re = vim.loop.os_homedir():gsub('%.', '%.')
local package_root_re = (vim.fn.stdpath'data'..'/site/pack/packer/'):gsub('%.', '%.')
function _G.my_tabline_path()
  if vim.bo.filetype == 'help' then
    return 'ヘルプ'
  elseif vim.wo.previewwindow == 1 then
    return 'プレビュー'
  end
  local filename = vim.api.nvim_buf_get_name(0)
  if package_root_re then
    filename = filename:gsub(package_root_re, '', 1)
  end
  if vim.g.gh_e_host then
    filename = filename:gsub('^'..home_re..'/git/'..vim.g.gh_e_host..'/', '', 1)
  end
  return filename:gsub(
    '^'..home_re..'/git/github%.com/', '', 1
  ):gsub(
    '^'..home_re, '~', 1
  ):gsub('/[^/]+$', '', 1)
end
vim.o.titlestring = [[%t%( %M%)%( (%{v:lua.my_tabline_path()})%)%( %a%)]]
-- }}}

-- Others {{{
vim.o.diffopt = vim.o.diffopt..',vertical,iwhite,algorithm:patience'
vim.o.fileformat = 'unix'
vim.bo.fileformat = 'unix'
vim.o.fileformats = 'unix,dos'
vim.o.grepprg = 'pt --nogroup --nocolor'
vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'..
      ',a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor'..
      ',sm:block-blinkwait175-blinkoff150-blinkon175'
vim.o.helplang = 'ja'
vim.o.lazyredraw = true
vim.bo.matchpairs = vim.bo.matchpairs..',（:）,「:」,【:】,［:］,｛:｝,＜:＞'
vim.o.scrolloff = 3
vim.o.sidescrolloff = 5
vim.bo.synmaxcol = 0
vim.o.virtualedit = 'block'
vim.o.wildmode = 'full'
vim.o.dictionary = '/usr/share/dict/words'
-- }}}

-- OS specific {{{
if vim.fn.has'osx' then
  -- Use Japanese for menus on macOS.
  -- This is needed to be set before showing menus.
  vim.o.langmenu = 'ja_ja.utf-8.macvim'

  -- Set iskeyword to manage CP932 texts on macOS
  vim.bo.iskeyword = '@,48-57,_,128-167,224-235'

  -- For printing
  vim.o.printmbfont = 'r:HiraMinProN-W3,b:HiraMinProN-W6'
  vim.o.printencoding = 'utf-8'
  vim.o.printmbcharset = 'UniJIS'
end

-- Set guioptions in case menu.vim does not exist.
if vim.fn.has'gui_running'
  and vim.fn.filereadable(vim.env.VIMRUNTIME..'/menu.vim') == 0 then
  vim.o.guioptions = add_option_string(vim.o.guioptions, 'M')
end

-- Exclude some $TERM not to communicate with X servers.
if vim.fn.has'gui_running' == 0 and vim.fn.has'xterm_clipboard' == 1 then
  vim.o.clipboard = [[exclude:cons\|linux\|cygwin\|rxvt\|screen]]
end

-- Set $VIM into $PATH to search vim.exe itself.
if vim.fn.has'win32' then
  local re = vim.regex([[\(^\|;\)]]..vim.fn.escape(vim.env.VIM, [[\]])..[[\(;\|$\)]])
  if re:match_str(vim.env.PATH) then
    vim.env.PATH = vim.env.VIM..';'..vim.env.PATH
  end
end
-- }}}

-- for VV {{{
if vim.g.vv then
  vim.o.shell = '/usr/local/bin/fish'
  vim.api.nvim_exec([[
    VVset fontfamily=SF\ Mono\ Square
    VVset fontsize=16
    VVset lineheight=1.0
    VVset width=1280
    VVset height=1280
  ]], false)
end
-- }}}

-- vim:se fdm=marker:
