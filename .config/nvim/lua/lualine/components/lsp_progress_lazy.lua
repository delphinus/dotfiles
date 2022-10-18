local _, _, api = require("core.utils").globals()
local LspProgressLazy = require("lualine.components.lsp_progress"):extend()

LspProgressLazy.register_progress = function(_) end

LspProgressLazy.init = function(self, options)
  api.create_autocmd("LspAttach", {
    once = true,
    callback = function()
      self.super.register_progress(self)
    end,
  })
  self.super.init(self, options)
  self.clients = {}
end

return LspProgressLazy
