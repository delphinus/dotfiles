if vim.env.NVIM_PROFILE then
  require'plenary.profile'.start('/tmp/profile.log', {flame = true})
  vim.cmd[[au VimEnter * lua require'plenary.profile'.stop()]]
end

vim.env.PATH = vim.env.PATH or '/usr/local/bin:/usr/bin:/bin'

require'setup'
require'filetypes'
require'util'
require'packers'
require'set'
require'mapping'
require'term'
require'commands'

require'agrp'.set{
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

local local_vimrc = vim.loop.os_homedir()..'/.vimrc-local'
local st = vim.loop.fs_stat(local_vimrc)
if st and st.type == 'file' then
  vim.cmd('source '..local_vimrc)
end
