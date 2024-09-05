local api = require("core.utils").api

---@class AutoFormattingOptions
---@field enabled boolean
---@field filter fun(client: { name: string }): boolean

---@class AutoFormatting
---@field instances table<string, AutoFormatting>
---@field buffer integer
---@field enabled boolean
---@field filter fun(client: { name: string }): boolean
---@field group integer
local AutoFormatting = {
  instances = {},
}

---@param buffer integer
---@param opts AutoFormattingOptions
---@return AutoFormatting
AutoFormatting.set = function(buffer, opts)
  buffer = buffer == 0 and api.get_current_buf() or buffer
  local i = AutoFormatting.instances
  local key = tostring(buffer)
  i[key] = i[key] or AutoFormatting.new(buffer, opts)
  return i[key]
end

---@param buffer integer
---@return boolean
AutoFormatting.is_enabled = function(buffer)
  buffer = buffer == 0 and api.get_current_buf() or buffer
  local key = tostring(buffer)
  local i = AutoFormatting.instances[key]
  return i and i.enabled or false
end

---@param buffer integer
---@param opts AutoFormattingOptions?
---@return AutoFormatting
AutoFormatting.new = function(buffer, opts)
  if not buffer then
    error "[AutoFormatting] needs buffer in opts"
  end
  opts = vim.tbl_extend("force", {
    enabled = true,
    ---@param client { name: string }
    ---@return boolean
    filter = function(client)
      return client.name ~= "ts_ls"
    end,
  }, opts or {}) --[[@as AutoFormattingOptions]]
  local self = setmetatable({}, { __index = AutoFormatting })
  self.buffer = buffer
  self.enabled = opts.enabled
  self.filter = opts.filter
  self.group = api.create_augroup("lsp_formatting", { clear = false })
  if self.enabled then
    self:enable()
  end
  return self
end

function AutoFormatting:toggle()
  if self.enabled then
    self:disable()
  else
    self:enable()
  end
  self.enabled = not self.enabled
end

function AutoFormatting:enable()
  api.create_autocmd("BufWritePre", {
    group = self.group,
    buffer = self.buffer,
    callback = function()
      vim.lsp.buf.format { filter = self.filter, timeout_ms = 5000 }
    end,
  })
end

function AutoFormatting:disable()
  api.clear_autocmds { group = self.group, buffer = self.buffer }
end

return AutoFormatting
