function _G.run_packer(method, opts)
  vim.cmd[[packadd packer.nvim]]
  require'packers.load'[method](opts)
end

vim.cmd[[command! PackerInstall lua run_packer'install']]
vim.cmd[[command! PackerUpdate  lua run_packer'update']]
vim.cmd[[command! PackerSync    lua run_packer'sync']]
vim.cmd[[command! PackerClean   lua run_packer'clean']]
vim.cmd[[command! -nargs=* PackerCompile lua run_packer('compile', <q-args>)]]
vim.cmd[[command! PackerProfile lua run_packer'profile_output']]

local m = require'mappy'
m.nnoremap('<Leader>ps', function()
  vim.notify'Sync started'
  _G.run_packer'sync'
end)
m.nnoremap('<Leader>po', function()
  vim.notify'Compile started'
  _G.run_packer'compile'
end)
