---Queries for the builtin multicursor session. See `:help multicursor`.
---
---Cursors are extmarks in the "nvim.multicursor" namespace, so the state is
---per-buffer. The alert (core.options.mcursor) and the lualine component both
---read from here.
local api = require("core.utils").api

local M = {}

---Namespace Neovim places the extra cursors in.
M.ns = api.create_namespace "nvim.multicursor"

---Number of extra cursors in the current buffer (the primary one is not one of them).
---@return integer
function M.count()
  return #api.buf_get_extmarks(0, M.ns, 0, -1, {})
end

---Whether a multicursor session is live in the current buffer.
---@return boolean
function M.active()
  return #api.buf_get_extmarks(0, M.ns, 0, -1, { limit = 1 }) > 0
end

return M
