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
  _G.run_packer'compile'
  vim.notify'Compile complete!'
end)

require'agrp'.set{
  packer_on_compile_done = {
    {'User', 'PackerCompileDone', function()
      vim.notify = function(msg, _, opts)
        vim.api.nvim_echo(
          {{('[%s] %s'):format(opts.title, msg), 'WarningMsg'}},
          true,
          {}
        )
      end
    end},
  },
}
