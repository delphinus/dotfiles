-- Encodings {{{
vim.o.fileencoding = 'utf-8'
vim.bo.fileencoding = 'utf-8'
if vim.fn.has('gui_macvim') == 0 then
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
vim.o.showbreak = [[→\  ]]
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
nvim_create_augroups{
  set_colorscheme = {
    {'VimEnter', '*', 'colorscheme '..scheme},
  },
}
-- }}}

-- Title {{{
if vim.env.TMUX then
  vim.o.t_ts = [[k]]
  vim.o.t_fs = [[\]]
end
-- }}}

-- vim:se fdm=marker:
