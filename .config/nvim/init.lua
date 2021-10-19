vim.env.PATH = vim.env.PATH or '/usr/local/bin:/usr/bin:/bin'
-- TODO: impatient.nvim
if not pcall(require, 'impatient') then
	local dir = vim.fn.stdpath'data'..'/site/pack/packer/start/impatient.nvim'
	os.execute('git clone https://github.com/lewis6991/impatient.nvim '..dir)
	vim.opt.runtimepath:append(dir)
	require'impatient'
end
if vim.env.IMPATIENT_PROFILE then
  require'impatient'.enable_profile()
end

if vim.env.NVIM_PROFILE then
  require'plenary.profile'.start('/tmp/profile.log', {flame = true})
  vim.cmd[[au VimEnter * lua require'plenary.profile'.stop()]]
end

pcall(require, 'packer_compiled') -- TODO: impatient.nvim

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
    {'VimEnter', '*', function()
      local v = vim.version()
      local name = ('Neovim v%d.%d.%d'):format(v.major, v.minor, v.patch)
      vim.notify('Hello, World!', nil, {title = name})
    end},
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
