local home = vim.loop.os_homedir()

vim.env.PATH = vim.env.PATH or '/usr/local/bin:/usr/bin:/bin'
vim.o.runtimepath = vim.o.runtimepath..','..home..'/git/dotfiles/.vim,'..home..'/git/dotfiles/.vim/after'
require'util'
require'packers'
require'set'
require'map'
require'term'
require'commands'

require'augroups'.set{
  hello_world = {
    {'VimEnter', '*', function() print'Hello, World!' end},
  },
}

vim.g.loaded_getscriptPlugin = true
vim.g.loaded_logiPat = true
vim.g.loaded_rrhelper = true
vim.g.loaded_vimballPlugin = true
if vim.fn.has('gui_running') ~= 1 then
  vim.g.plugin_scrnmode_disable = true
end

local local_vimrc = home..'/.vimrc-local'
if vim.fn.filereadable(local_vimrc) then
  vim.cmd('source '..local_vimrc)
end
