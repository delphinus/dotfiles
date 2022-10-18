local _, _, api = require("core.utils").globals()
local LspProgressLazy = require("lualine.components.lsp_progress"):extend()

LspProgressLazy.register_progress = function(_) end

LspProgressLazy.init = function(self, options)
  api.create_autocmd("LspAttach", {
    once = true,
    callback = function()
      local orig = vim.lsp.handlers["$/progress"]
      self.super.register_progress(self)
      if orig then
        local f = vim.lsp.handlers["$/progress"]
        vim.lsp.handlers["$/progress"] = function(...)
          orig(...)
          f(...)
        end
      end
    end,
  })
  self.super.init(self, options)
  self.clients = {}
end

return LspProgressLazy
