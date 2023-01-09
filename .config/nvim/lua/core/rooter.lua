---@class core.rooter.Opts
---@field root_names string[] default: { ".git" }

---@class core.rooter.EventInfo
---@field buf integer

---@class core.rooter.Rooter
---@field default_options core.rooter.Opts
---@field opts core.rooter.Opts
---@field group integer
---@field cache table<string, string>
local Rooter = {}

---@return core.rooter.Rooter
Rooter.new = function()
  return setmetatable({
    default_options = { root_names = { ".git" } },
    group = vim.api.nvim_create_augroup("core-rooter", {}),
    cache = {},
  }, { __index = Rooter })
end

---@param opts core.rooter.Opts?
---@return nil
function Rooter:setup(opts)
  self.opts = vim.tbl_extend("force", self.default_options, opts or {})
  vim.api.nvim_create_autocmd("BufEnter", {
    group = self.group,
    ---@param ev core.rooter.EventInfo
    callback = function(ev)
      self:on_buf_enter(ev)
    end,
  })
end

---@param ev core.rooter.EventInfo
function Rooter:on_buf_enter(ev)
  if not self:is_file(ev.buf) then
    return
  end
  local file = vim.api.nvim_buf_get_name(ev.buf)
  if file == "" then
    return
  end
  local dir = vim.fs.dirname(file)
  if not self.cache[dir] then
    local root_file = vim.fs.find(self.opts.root_names, { path = dir, upward = true })[1]
    if not root_file then
      return
    end
    self.cache[dir] = vim.fs.dirname(root_file)
  end
  vim.api.nvim_set_current_dir(self.cache[dir])
  vim.notify("[rooter] Set CWD to " .. self.cache[dir], vim.log.levels.DEBUG)
end

---@param bufnr integer
---@return boolean
function Rooter:is_file(bufnr) -- luacheck: ignore 212
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  -- See :h 'buftype'
  for _, bt in ipairs { "", "acwrite" } do
    if buftype == bt then
      return true
    end
  end
  return false
end

local rooter = Rooter.new()

return {
  ---@param opts core.rooter.Opts?
  setup = function(opts)
    rooter:setup(opts)
  end,
}
