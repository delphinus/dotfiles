local install_path = vim.fn.stdpath'data'..'/site/pack/packer/opt/packer.nvim'
if vim.fn.isdirectory(install_path) == 0 then
  os.execute('git clone https://github.com/wbthomason/packer.nvim '..install_path)
  vim.cmd'packadd packer.nvim'
end

nvim_create_augroups{
  packer_compile = {
    {'BufWritePost', '*/packers/*.lua', 'PackerCompile'},
  },
}

function _G.run_packer(method)
  vim.cmd[[packadd packer.nvim]]
  require'packers.load'[method]()
end

vim.cmd[[command! PackerInstall lua run_packer'install']]
vim.cmd[[command! PackerUpdate  lua run_packer'update']]
vim.cmd[[command! PackerSync    lua run_packer'sync']]
vim.cmd[[command! PackerClean   lua run_packer'clean']]
vim.cmd[[command! PackerCompile lua run_packer'compile']]
