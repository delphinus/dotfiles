local fn, uv, api = require("core.utils").globals()

-- setup packer.nvim {{{
local data_dir = fn.stdpath "data"

for _, p in ipairs {
  { "wbthomason/packer.nvim", opt = true },
} do
  local dir = p.opt and "opt" or "start"
  local package = p[1]
  local name = package:match "[^/]+$"
  local path = ("%s/site/pack/packer/%s/%s"):format(data_dir, dir, name)
  local st = uv.fs_stat(path)
  if not st or st.type ~= "directory" then
    os.execute(("git clone https://github.com/%s %s"):format(package, path))
  end
end
-- }}}

-- commands {{{
local function run_packer(method, opts)
  return function(opts)
    require("core.pack.load")[method](opts)
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
  run_packer "loader" (unpack(opts))
end, {
  bang = true,
  complete = function(lead)
    return run_packer "loader_complete" (lead)
  end,
  desc = "[Packer] Load plugins",
  nargs = "+",
})

vim.keymap.set("n", "<Leader>ps", [[<Cmd>PackerSync<CR>]])
vim.keymap.set("n", "<Leader>po", [[<Cmd>PackerCompile<CR>]])
--}}}
