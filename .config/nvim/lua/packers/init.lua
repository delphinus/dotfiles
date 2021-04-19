local install_path = vim.fn.stdpath'data'..'/site/pack/packer/opt/packer.nvim'
local st = vim.loop.fs_stat(install_path)
if not st or st.type ~= 'directory' then
  os.execute('git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

function _G.run_packer(method)
  vim.cmd[[packadd packer.nvim]]
  require'packers.load'[method]()
end

vim.cmd[[command! PackerInstall lua run_packer'install']]
vim.cmd[[command! PackerUpdate  lua run_packer'update']]
vim.cmd[[command! PackerSync    lua run_packer'sync']]
vim.cmd[[command! PackerClean   lua run_packer'clean']]
vim.cmd[[command! PackerCompile lua run_packer'compile']]

local ok, m = pcall(require, 'mappy')
if ok then
  m.nnoremap('<Leader>pi', function() run_packer'install' end)
  m.nnoremap('<Leader>pu', function() run_packer'update' end)
  m.nnoremap('<Leader>ps', function() run_packer'sync' end)
  m.nnoremap('<Leader>pc', function() run_packer'clean' end)
  m.nnoremap('<Leader>po', function() run_packer'compile' end)
end
