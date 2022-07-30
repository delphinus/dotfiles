local function run_packer(method, opts)
  return function(opts)
    require("packers.load")[method](opts)
  end
end

api.create_user_command("PackerInstall", run_packer "install", {
  desc = "[Packer] Install plugins",
})
api.create_user_command("PackerUpdate", run_packer "update", {
  desc = "[Packer] Update plugins",
})
api.create_user_command("PackerClean", run_packer "clean", {
  desc = "[Packer] Clean plugins",
})
api.create_user_command("PackerProfile", run_packer "profile_output", {
  desc = "[Packer] Output plugins profile",
})
api.create_user_command("PackerStatus", run_packer "status", {
  desc = "[Packer] Output plugins status",
})
api.create_user_command("PackerSync", function()
  vim.notify "Sync started"
  run_packer "sync" ()
end, { desc = "[Packer] Sync plugins" })
api.create_user_command("PackerCompile", function()
  vim.notify "Compile started"
  run_packer "compile" ()
end, { desc = "[Packer] Compile plugins" })
api.create_user_command("PackerLoad", function(opts)
  local args = vim.split(opts.args, " ")
  table.insert(args, opts.bang)
  require("packers.load").loader(unpack(args))
end, {
  bang = true,
  complete = function(lead)
    return require("packers.load").loader_complete(lead)
  end,
  desc = "[Packer] Load plugins",
  nargs = "+",
})

vim.keymap.set("n", "<Leader>ps", [[<Cmd>PackerSync<CR>]])
vim.keymap.set("n", "<Leader>po", [[<Cmd>PackerCompile<CR>]])
