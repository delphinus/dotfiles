local fn, uv, api = require("core.utils").globals()

---@class core.pack.Pack
---@field compile_path string
---@field old_compile_path string
---@field compiled string
---@field initialized boolean
---@field _packer any The instance of packer
local Pack = {}

Pack.new = function()
  local top = fn.stdpath "config"
  local compile_path = top .. "/lua/_compiled.lua"
  local compiled = compile_path:match "([^/]+).lua$"
  local old_compile_path = top .. "/plugin/packer_compiled.lua"
  local self = setmetatable({
    compile_path = compile_path,
    old_compile_path = old_compile_path,
    compiled = compiled,
    initialized = false,
    _packer = nil,
  }, { __index = Pack })
  self:remove_old_compile_path()
  self:assume_plugins()
  self:setup()
  return self
end

---@return nil
function Pack:remove_old_compile_path()
  if self:exists(self.old_compile_path) then
    uv.fs_unlink(self.old_compile_path)
    vim.notify("Old compiled script exists. Deleted.", vim.log.levels.WARN)
  end
end

---@return nil
function Pack:load_script()
  if self:exists(self.compile_path) then
    require(self.compiled)
  else
    vim.notify "Running :PackerCompile"
    self:compile(vim.schedule_wrap(function()
      require(self.compiled)
    end)) {}
  end
end

function Pack:setup()
  api.create_user_command("PackerInstall", self:run_packer "install", { desc = "[Packer] Install plugins" })
  api.create_user_command("PackerUpdate", self:run_packer "update", { desc = "[Packer] Update plugins" })
  api.create_user_command("PackerClean", self:run_packer "clean", { desc = "[Packer] Clean plugins" })
  api.create_user_command("PackerStatus", self:run_packer "status", { desc = "[Packer] Output plugins status" })
  api.create_user_command("PackerCompile", self:compile(), { desc = "[Packer] Output plugins status", nargs = "*" })

  api.create_user_command(
    "PackerProfile",
    self:run_packer "profile_output",
    { desc = "[Packer] Output plugins profile" }
  )

  api.create_user_command("PackerSync", function()
    vim.notify "Sync started"
    self:run_packer "sync"()
  end, { desc = "[Packer] Output plugins status" })

  api.create_user_command("PackerLoad", function(opts)
    local args = vim.split(opts.args, " ")
    table.insert(args, opts.bang)
    self:run_packer "loader"(unpack(opts))
  end, { bang = true, complete = self:run_packer "loader_complete", desc = "[Packer] Load plugins", nargs = "+" })

  vim.keymap.set("n", "<Leader>ps", [[<Cmd>PackerSync<CR>]])
  vim.keymap.set("n", "<Leader>po", [[<Cmd>PackerCompile<CR>]])
end

---@param cb (fun(): nil)?
---@return fun(opts: table): nil
function Pack:compile(cb)
  ---@param opts table
  ---@return nil
  return function(opts)
    api.create_autocmd("User", {
      pattern = "PackerCompileDone",
      once = true,
      callback = function()
        vim.cmd("split ++enc=latin1 " .. self.compile_path)
        vim.cmd [[/^vim\.cmd \[\[augroup filetypedetect\]\]$]]
        vim.cmd [[.,/^vim\.cmd("augroup END")$/d]]
        vim.cmd.wq { bang = true }
        self:notify_later(("Successfully edited %s.lua"):format(self.compiled))
      end,
    })
    self:run_packer "compile"(opts and opts.args or "")
  end
end

---@return nil
function Pack:assume_plugins()
  local data_dir = fn.stdpath "data"
  for _, p in ipairs {
    { "nvim-lua/plenary.nvim", opt = true },
    --{ "wbthomason/packer.nvim", opt = true },
    { "delphinus/packer.nvim", opt = true, branch = "feature/denops" },
  } do
    local dir = p.opt and "opt" or "start"
    local pkg = p[1]
    local branch = p.branch or "master"
    local name = pkg:match "[^/]+$"
    local path = ("%s/site/pack/packer/%s/%s"):format(data_dir, dir, name)
    if not self:exists(path) then
      vim.cmd(("!git clone https://github.com/%s %s -b %s"):format(pkg, path, branch))
    end
  end
end

---@param method string
---@return fun(opts: any): nil
function Pack:run_packer(method)
  return function(opts)
    self:packer()[method](opts)
  end
end

---@return any
function Pack:packer()
  if not self._packer then
    vim.cmd.packadd [[packer.nvim]]
    local packer = require "packer"
    packer.init {
      compile_path = self.compile_path,
      compile_on_sync = true,
      profile = { enable = false, threshold = 1 },
      disable_commands = true,
      max_jobs = 50,
      display = { open_fn = self:open_fn() },
    }
    packer.reset()

    packer.use(require "modules.start")
    packer.use(require "modules.opt")
    packer.use(require "modules.cmp")
    packer.use(require "modules.lsp")
    packer.use(require "modules.telescope")

    self._packer = packer
  end
  return self._packer
end

-- open_fn = require'packer.util'.float,
-- https://github.com/tjdevries/config_manager/blob/0c89222a53baf997371de0ec1ca4056b834a4d62/xdg_config/nvim/lua/tj/plugins.lua#L331
---@return fun(name: string): nil
function Pack:open_fn() -- luacheck: ignore 212
  return function(name)
    local ok, win = pcall(function()
      vim.cmd.packadd "plenary.nvim"
      return require("plenary.window.float").percentage_range_window(0.8, 0.8)
    end)

    if not ok then
      vim.cmd "65vnew [packer]"
      return true, api.get_current_win(), api.get_current_buf()
    end

    api.buf_set_name(win.bufnr, name)
    api.win_set_option(win.win_id, "winblend", 10)
    return true, win.win_id, win.bufnr
  end
end

---@param path string
---@return boolean
function Pack:exists(path) -- luacheck: ignore 212
  local st = uv.fs_stat(path)
  return st and true or false
end

---@param ... any
---@return nil
function Pack:notify_later(...) -- luacheck: ignore 212
  local args = { ... }
  vim.schedule(function()
    vim.notify(unpack(args))
  end)
end

return Pack.new()
