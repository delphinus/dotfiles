vim.o.runtimepath = vim.o.runtimepath..','..vim.env.HOME..'/git/dotfiles/.vim'
require'util'
require'packers'
require'set'

nvim_create_augroups{
  hello_world = {
    {'VimEnter', '*', [[lua print'Hello, World!']]},
  },
}

vim.g.loaded_getscriptPlugin = true
vim.g.loaded_logiPat = true
vim.g.loaded_rrhelper = true
vim.g.loaded_vimballPlugin = true
if vim.fn.has('gui_running') ~= 1 then
  vim.g.plugin_scrnmode_disable = true
end

local local_vimrc = vim.env.HOME..'/.vimrc-local'
if vim.fn.filereadable(local_vimrc) then
  vim.cmd('source '..local_vimrc)
end
