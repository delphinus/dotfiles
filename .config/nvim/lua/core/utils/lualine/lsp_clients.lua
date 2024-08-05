local lualine_require = require "lualine_require"
local M = lualine_require.require("lualine.component"):extend()

function M:init(options)
  local palette = require "core.utils.palette"
  local colors = palette.colors
  M.super.init(self, options)
  self.highlights = {
    name = self:create_hl({ fg = colors.yellow }, "name"),
    id = self:create_hl({ fg = colors.orange or colors.blue }, "id"),
    source = self:create_hl({ fg = colors.grey }, "source"),
  }
end

function M:update_status()
  local colors = vim.iter(self.highlights):fold({}, function(a, k, v)
    a[k] = self:format_hl(v)
    return a
  end)
  return table.concat(
    vim
      .iter(vim.lsp.get_clients { bufnr = 0 })
      :map(function(client)
        local additionals = ""
        if client.name == "null-ls" then
          local availables = require("null-ls.sources").get_available(vim.bo.filetype)
          local sources = vim
            .iter(availables)
            :map(function(source)
              return source.name
            end)
            :totable()
          if #sources > 0 then
            additionals = " [" .. table.concat(sources, ",") .. "]"
          end
        end
        return ("%s%s(%s%d%s)%s%s"):format(
          colors.name,
          client.name,
          colors.id,
          client.id,
          colors.name,
          colors.source,
          additionals
        )
      end)
      :totable(),
    " "
  )
end

return M
