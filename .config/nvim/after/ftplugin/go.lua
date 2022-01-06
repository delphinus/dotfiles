vim.opt.foldmethod = "syntax"
if vim.opt.background:get() == "light" then
  vim.cmd [[hi! goSameId term=bold cterm=bold ctermbg=225 guibg=#eeeaec]]
else
  vim.cmd [[hi! goSameId gui=bold term=bold ctermbg=23 ctermfg=7 guifg=#eee8d5 gui=bold]]
end
