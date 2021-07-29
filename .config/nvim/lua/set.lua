-- Encodings {{{
vim.opt.fileencoding = 'utf-8'
if vim.fn.has'gui_macvim' == 0 then
  vim.opt.fileencodings = {
    'ucs-bom',
    'utf-8',
    'eucjp',
    'cp932',
    'ucs-2le',
    'latin1',
    'iso-2022-jp',
  }
end
-- }}}

--Tabs {{{
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
-- }}}

-- Undo {{{
vim.opt.undofile = true
-- }}}

-- Searching {{{
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split'
-- }}}

-- Display {{{
vim.opt.cmdheight = 2
vim.opt.colorcolumn = {'80', '140'}
vim.opt.list = true
vim.opt.listchars = {
  tab = '▓░',
  trail = '↔',
  eol = '⏎',
  extends = '→',
  precedes = '←',
  nbsp = '␣',
}
vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.relativenumber = true
vim.opt.showmatch = true
vim.opt.showtabline = 2

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
vim.opt.breakindent = true
-- TODO: cannot set formatoptions?
--vim.opt.formatoptions:append{'n', 'm', 'M', 'j'}
vim.o.formatoptions = vim.o.formatoptions..'nmMj'
vim.opt.formatlistpat = [[^\s*\%(\d\+\|[-a-z]\)\%(\ -\|[]:.)}\t]\)\?\s\+]]
vim.opt.fixendofline = false
vim.opt.showbreak = [[→]]
vim.opt.smartindent = true
-- }}}

-- Mouse
vim.opt.mouse = 'a'

-- ColorScheme {{{
vim.opt.termguicolors = true
vim.cmd'syntax enable'

function _G.toggle_colorscheme()
  local scheme
  if vim.opt.background:get() == 'light' then
    vim.opt.background = 'dark'
    scheme = 'nord'
  else
    vim.opt.background = 'light'
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
require'agrp'.set{
  set_colorscheme = {
    {'VimEnter', '*', 'doautocmd ColorScheme '..scheme},
  },
}
vim.cmd('colorscheme '..scheme)
-- }}}

-- Title {{{
if vim.env.TMUX then
  -- TODO: vim.opt has no options below?
  vim.api.nvim_exec([[
    let &t_ts = 'k'
    let &t_fs = '\\'
  ]], false)
end
vim.opt.title = true
local home_re = vim.loop.os_homedir():gsub('%.', '%.')
local package_root_re = (vim.fn.stdpath'data'..'/site/pack/packer/'):gsub('%.', '%.')
function _G.my_tabline_path()
  if vim.opt.filetype:get() == 'help' then
    return 'ヘルプ'
  -- TODO: vim.opt has no 'previewwindow'?
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
vim.opt.titlestring = [[%t%( %M%)%( (%{v:lua.my_tabline_path()})%)%( %a%)]]
-- }}}

-- grep {{{
vim.opt.grepprg = 'pt --nogroup --nocolor --'
require'agrp'.set{
  open_quickfix_window = {
    {'QuickFixCmdPost', '*grep*', 'cwindow'},
  },
}
-- }}}

-- Others {{{
vim.opt.diffopt:append{'vertical', 'iwhite', 'algorithm:patience'}
vim.opt.fileformat = 'unix'
vim.opt.fileformats = {'unix', 'dos'}
vim.opt.guicursor = {
  'n-v-c:block',
  'i-ci-ve:ver25',
  'r-cr:hor20',
  'o:hor50',
  'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor',
  'sm:block-blinkwait175-blinkoff150-blinkon175',
}
vim.opt.helplang = 'ja'
vim.opt.lazyredraw = true
vim.opt.matchpairs:append{'（:）', '「:」', '【:】', '［:］', '｛:｝', '＜:＞'}
vim.opt.scroll = 3
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 5
vim.opt.virtualedit = 'block'
vim.opt.wildmode = 'full'
vim.opt.dictionary = '/usr/share/dict/words'
-- }}}

-- OS specific {{{
if vim.fn.has'osx' then
  -- Use Japanese for menus on macOS.
  -- This is needed to be set before showing menus.
  vim.opt.langmenu = 'ja_ja.utf-8.macvim'

  -- Set iskeyword to manage CP932 texts on macOS
  vim.opt.iskeyword = {'@', '48-57', '_', '128-167', '224-235'}

  -- For printing
  -- TODO: printmbfont does not have a list
  vim.opt.printmbfont = 'r:HiraMinProN-W3,b:HiraMinProN-W6'
  vim.opt.printencoding = 'utf-8'
  vim.opt.printmbcharset = 'UniJIS'
end

-- Set guioptions in case menu.vim does not exist.
if vim.fn.has'gui_running' == 1
  and vim.fn.filereadable(vim.env.VIMRUNTIME..'/menu.vim') == 0 then
  vim.opt.guioptions:append{'M'}
end

-- Exclude some $TERM not to communicate with X servers.
if vim.fn.has'gui_running' == 0 and vim.fn.has'xterm_clipboard' == 1 then
  -- TODO: This is a valud value?
  vim.o.clipboard = [[exclude:cons\|linux\|cygwin\|rxvt\|screen]]
end

-- Set $VIM into $PATH to search vim.exe itself.
if vim.fn.has'win32' == 1 then
  local re = vim.regex([[\(^\|;\)]]..vim.fn.escape(vim.env.VIM, [[\]])..[[\(;\|$\)]])
  if re:match_str(vim.env.PATH) then
    vim.env.PATH = vim.env.VIM..';'..vim.env.PATH
  end
end
-- }}}

-- for VV {{{
if vim.g.vv then
  vim.opt.shell = '/usr/local/bin/fish'
  vim.api.nvim_exec([[
    VVset fontfamily=SF\ Mono\ Square
    VVset fontsize=16
    VVset lineheight=1.0
    VVset width=1280
    VVset height=1280
  ]], false)
end
-- }}}

-- for Goneovim {{{
if vim.g.goneovim then
  vim.opt.shell = '/usr/local/bin/fish'
  vim.env.LANG = 'ja_JP.UTF-8'
end
-- }}}

-- vim:se fdm=marker:
