local fn, _, api = require("core.utils").globals()
local Path = require "plenary.path"
local Job = require "plenary.job"

-- setup packer.nvim {{{
local data_dir = fn.stdpath "data"

local notify = vim.schedule_wrap(function(msg, level)
  vim.cmd.redraw()
  vim.cmd('echomsg "' .. msg .. '"')
  vim.notify(msg, level or vim.log.levels.INFO)
end) --[[@as fun(msg: string, level: integer?): nil]]

for _, p in ipairs {
  --{ "wbthomason/packer.nvim", opt = true },
  { "delphinus/packer.nvim", opt = true, branch = "feature/denops" },
} do
  local dir = p.opt and "opt" or "start"
  local package = p[1]
  local branch = p.branch or "master"
  local name = package:match "[^/]+$"
  local path = Path:new(data_dir, "site/pack/packer", dir, name)
  if not path:is_dir() then
    Job:new({
      command = "git",
      args = { "clone", "https://github.com/" .. package, tostring(path), "-b", branch },
      on_start = function()
        notify(("start to clone. %s on %s"):format(package, branch))
      end,
      on_exit = function(self, code)
        if code == 0 then
          notify(("successfully cloned. %s on %s"):format(package, branch))
        else
          notify(table.concat(self:stderr_result(), "\n"), vim.log.levels.WARN)
        end
      end,
    }):sync()
  end
end
-- }}}

-- commands {{{
local function run_packer(method)
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
  run_packer "sync"()
end, { desc = "[Packer] Sync plugins" })

api.create_user_command("PackerCompile", function(opts)
  api.create_autocmd("User", {
    pattern = "PackerCompileDone",
    once = true,
    callback = function()
      vim.notify "Compile done"
    end,
  })
  run_packer "compile"(opts.args)
end, { desc = "[Packer] Compile plugins", nargs = "*" })

api.create_user_command("PackerLoad", function(opts)
  local args = vim.split(opts.args, " ")
  table.insert(args, opts.bang)
  run_packer "loader"(unpack(opts))
end, {
  bang = true,
  complete = run_packer "loader_complete",
  desc = "[Packer] Load plugins",
  nargs = "+",
})

vim.keymap.set("n", "<Leader>ps", [[<Cmd>PackerSync<CR>]])
vim.keymap.set("n", "<Leader>po", [[<Cmd>PackerCompile<CR>]])
--}}}
