vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.cursorcolumn = false
vim.opt.foldmethod = "syntax"
local f = require "f_meta"
local json_fold_text = f.json_fold_text
  or f {
    "json_fold_text",
    function()
      local line = fn.getline(vim.v.foldstart)
      local sub = fn.substitute(line, [[\v^\s+([^"]*")?]], "", "")
      sub = fn.substitute(sub, [[\v("[^"]*)?\s*$]], "", "")
      local level = #vim.v.folddashes
      if level <= 12 then
        level = fn.nr2char(0x2170 + level - 1) .. " "
      end
      return ("%s %3d 行: %s "):format(level, vim.v.foldend - vim.v.foldstart + 1, sub)
    end,
  }
vim.cmd.setlocal("foldtext=" .. json_fold_text:vim() .. "()")
