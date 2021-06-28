vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.cursorcolumn = false
vim.opt.foldmethod = 'syntax'
function _G.json_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local sub = vim.fn.substitute(line, [[\v^\s+([^"]*")?]], '', '')
  sub = vim.fn.substitute(sub, [[\v("[^"]*)?\s*$]], '', '')
  local level = #vim.v.folddashes
  if level <= 12 then
    level = vim.fn.nr2char(0x2170 + level - 1)..' '
  end
  return ('%s %3d 行: %s '):format(level, vim.v.foldend - vim.v.foldstart + 1, sub)
end
vim.cmd[[let g:JsonFoldText = {-> v:lua.json_fold_text()}]]
vim.cmd[[setlocal foldtext=g:JsonFoldText()]]
