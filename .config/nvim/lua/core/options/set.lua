local fn, uv, api = require("core.utils").globals()

-- Encodings {{{
if fn.has "gui_macvim" == 0 then
  vim.opt.fileencodings = {
    "ucs-bom",
    "utf-8",
    "eucjp",
    "cp932",
    "ucs-2le",
    "latin1",
    "iso-2022-jp",
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
vim.opt.inccommand = "split"
-- }}}

-- Display {{{
-- NOTE: #vim.api.nvim_list_uis() is 0 when invoked with --headless
vim.opt.cmdheight = (vim.env.LIGHT or #vim.api.nvim_list_uis() == 0) and 2 or 0
vim.opt.colorcolumn = { "80", "120" }
vim.opt.list = true
vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.relativenumber = true
vim.opt.showmatch = true
vim.opt.completeopt:remove "preview"
vim.opt.pumblend = vim.env.NVIM and 0 or 30
vim.opt.pumheight = 20
vim.opt.pumwidth = 40 -- Use the same value as converter_truncate.maxAbbrWidth
vim.opt.shada = [['50,/100,:100,<5,@100,f0,h,s10]]
vim.opt.cursorlineopt = { "number", "screenline" }
-- }}}

-- Indents and arranging formats {{{
vim.opt.breakindent = true
vim.opt.breakindentopt = "list:2"
-- TODO: cannot set formatoptions?
--vim.opt.formatoptions:append{'n', 'm', 'M', 'j'}
vim.o.formatoptions = vim.o.formatoptions .. "nmMj"
vim.opt.formatlistpat = [[^\s*\%(\d\+\|[-a-z]\)\%(\ -\|[]:.)}\t]\)\?\s\+]]
vim.opt.fixendofline = false
-- NOTE: commented out for wrapwidth
-- vim.opt.showbreak = [[→]]
vim.opt.smartindent = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""

api.create_autocmd({ "BufWinEnter" }, {
  group = api.create_augroup("open-folds-initially", {}),
  command = "normal zx zR",
  desc = "Unfold all foldings in opening files",
})
-- }}}

-- ColorScheme {{{
vim.opt.termguicolors = true

local is_light = vim.env.COLORFGBG == "11;15"
if is_light then
  vim.g.background = "light"
end
local scheme = "sweetie"
api.create_autocmd("VimEnter", {
  desc = "Run ColorScheme autocmds in VimEnter",
  group = api.create_augroup("set_colorscheme", {}),
  callback = function()
    api.exec_autocmds("ColorScheme", { pattern = scheme })
  end,
})
pcall(vim.cmd.colorscheme, scheme)
-- }}}

-- Title {{{
if vim.env.TMUX then
  -- TODO: vim.opt has no options below?
  vim.cmd [[
    let &t_ts = 'k'
    let &t_fs = '\\'
    " undercurl
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"

  ]]
end

-- TODO: noice.nvim causes flashing the window title bar
-- https://github.com/folke/noice.nvim/issues/197
--vim.opt.title = true
vim.opt.title = false
local home_re = uv.os_homedir():gsub("%.", "%.")
local package_root_re = (fn.stdpath "data" .. "/site/pack/packer/"):gsub("%.", "%.")
local my_tabline_path = require "f_meta" {
  "my_tabline_path",
  function()
    if vim.bo.filetype == "help" then
      return "ヘルプ"
      -- TODO: vim.opt has no 'previewwindow'?
    elseif vim.wo.previewwindow then
      return "プレビュー"
    elseif vim.bo.buftype == "terminal" then
      return "TERM"
    end
    local filename = api.buf_get_name(0)
    if package_root_re then
      filename = filename:gsub(package_root_re, "", 1)
    end
    if vim.env.GITHUB_ENTERPRISE_HOST then
      filename = vim.iter(vim.split(vim.env.GITHUB_ENTERPRISE_HOST, ",")):fold(filename, function(a, b)
        return a:gsub("^" .. home_re .. "/git/" .. vim.pesc(b) .. "/", "", 1)
      end)
    end
    local result =
      filename:gsub("^" .. home_re .. "/git/github%.com/", "", 1):gsub("^" .. home_re, "~", 1):gsub("/[^/]+$", "", 1)
    return #result <= 40 and result or "……" .. result:sub(-38, -1)
  end,
}
vim.opt.titlestring = ("%%{%s()}"):format(my_tabline_path:vim())
-- }}}

-- grep {{{
vim.opt.grepprg = "pt --nogroup --nocolor --"
api.create_autocmd("QuickFixCmdPost", {
  desc = "Open the quickfix window after running :vimgrep",
  group = api.create_augroup("open_quickfix_window", {}),
  pattern = "*grep*",
  command = [[cwindow]],
})
-- }}}

-- Others {{{
vim.opt.diffopt:append { "vertical", "iwhite", "algorithm:patience" }
vim.opt.fileformats = { "unix", "dos" }
vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}
vim.opt.helplang = "ja"
vim.opt.matchpairs:append { "（:）", "「:」", "【:】", "［:］", "｛:｝", "＜:＞" }
vim.opt.scroll = 3
vim.opt.scrolloff = 3
vim.opt.virtualedit = "block"
vim.opt.wildmode = "full"
vim.opt.dictionary = "/usr/share/dict/words"
vim.opt.exrc = true
vim.opt.smoothscroll = true
vim.opt.mousemoveevent = true
-- Show all messages in noice, such as from vim.print()
vim.opt.shortmess:remove "T"
-- }}}

-- OS specific {{{
if fn.has "osx" then
  -- Use Japanese for menus on macOS.
  -- This is needed to be set before showing menus.
  vim.opt.langmenu = "ja_ja.utf-8.macvim"

  -- Set iskeyword to manage CP932 texts on macOS
  vim.opt.iskeyword = { "@", "48-57", "_", "128-167", "224-235" }
end

-- Set guioptions in case menu.vim does not exist.
if fn.has "gui_running" == 1 and fn.filereadable(vim.env.VIMRUNTIME .. "/menu.vim") == 0 then
  vim.opt.guioptions:append { "M" }
end

-- Exclude some $TERM not to communicate with X servers.
if fn.has "gui_running" == 0 and fn.has "xterm_clipboard" == 1 then
  -- TODO: This is a valud value?
  vim.o.clipboard = [[exclude:cons\|linux\|cygwin\|rxvt\|screen]]
end

-- Set $VIM into $PATH to search vim.exe itself.
if fn.has "win32" == 1 then
  local re = vim.regex([[\(^\|;\)]] .. fn.escape(vim.env.VIM, [[\]]) .. [[\(;\|$\)]])
  if re and re:match_str(vim.env.PATH) then
    vim.env.PATH = vim.env.VIM .. ";" .. vim.env.PATH
  end
end
-- }}}

-- for VV {{{
if vim.g.vv then
  vim.opt.shell = "/usr/local/bin/fish"
  vim.cmd [[
    VVset fontfamily=SF\ Mono\ Square
    VVset fontsize=16
    VVset lineheight=1.0
    VVset width=1280
    VVset height=1280
  ]]
end
-- }}}

-- for Goneovim {{{
if vim.g.goneovim then
  vim.opt.shell = "/usr/local/bin/fish"
  vim.env.LANG = "ja_JP.UTF-8"
end
-- }}}

-- TODO: for nvim-treesitter
-- https://github.com/nvim-treesitter/nvim-treesitter/issues/1515
--vim.env.CC = "gcc-11"

-- NOTE: for man.lua (:Man)
vim.g.man_hardwrap = 0

-- vim-lastplace alternative
-- https://github.com/neovim/neovim/issues/16339#issuecomment-1457394370
vim.api.nvim_create_autocmd("BufRead", {
  callback = function(opts)
    vim.api.nvim_create_autocmd("BufWinEnter", {
      once = true,
      buffer = opts.buf,
      callback = function()
        local ft = vim.bo[opts.buf].filetype
        local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
        if
          not ft:match "commit"
          and not ft:match "rebase"
          and last_known_line > 1
          and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
        then
          vim.api.nvim_feedkeys([[g`"]], "nx", false)
        end
      end,
    })
  end,
})

vim.ui.open = (function(original)
  ---@param path string
  ---@return string
  local function make_absolute(path)
    local p = path:gsub("^file://", "")
    if p:match "^%w+://" or p:sub(1, 1) == "/" then
      return p
    end
    local file = vim.api.nvim_buf_get_name(0)
    if not vim.uv.fs_stat(file) then
      return p
    end
    local joined = vim.fs.joinpath(vim.fs.dirname(file), p)
    local abs, err = vim.uv.fs_realpath(joined)
    assert(not err, err)
    return assert(abs)
  end
  return function(path, opt)
    return original(make_absolute(path), opt)
  end
end)(vim.ui.open)

vim.diagnostic.config {
  float = false,
  signs = function(_, b)
    ---@diagnostic disable-next-line: return-type-mismatch
    return vim.bo[b].filetype ~= "markdown"
        and {
          text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "○",
            [vim.diagnostic.severity.INFO] = "■",
            [vim.diagnostic.severity.HINT] = "□",
          },
        }
      or false
  end,
  virtual_text = false,
  virtual_lines = {
    severity = "INFO",
    format = function(diagnostic)
      return ("%s [%s]"):format(diagnostic.message, diagnostic.source)
    end,
  },
}

-- vim:se fdm=marker:
