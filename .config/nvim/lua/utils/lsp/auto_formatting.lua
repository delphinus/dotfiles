local AutoFormatting = {
  instances = {},
}

AutoFormatting.set = function(buffer, opts)
  local i = AutoFormatting.instances
  local key = tostring(buffer)
  i[key] = i[key] or AutoFormatting.new(buffer, opts)
  return i[key]
end

AutoFormatting.new = function(buffer, opts)
  if not buffer then
    error "[AutoFormatting] needs buffer in opts"
  end
  opts = vim.tbl_extend("force", {
    enabled = true,
    filter = function(client)
      return client.name ~= "tsserver"
    end,
  }, opts or {})
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
    self:enable()
  else
    self:disable()
  end
  self.enabled = not self.enabled
end

function AutoFormatting:enable()
  api.create_autocmd("BufWritePre", {
    group = self.group,
    buffer = self.buffer,
    callback = function()
      vim.lsp.buf.format { filter = self.filter }
    end,
  })
  self:log "Enabled auto formatting"
end

function AutoFormatting:disable()
  api.clear_autocmds { group = self.group, buffer = self.buffer }
  self:log "Disabled auto formatting"
end

function AutoFormatting:log(message)
  vim.notify(("[AutoFormatting] %s : buffer = %d"):format(message, self.buffer))
end

return AutoFormatting
