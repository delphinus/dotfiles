-- Recolor the primary cursor while a multicursor session is live, so a session
-- scrolled off-screen can't be mistaken for a plain buffer. See `:help multicursor`.
local api = require("core.utils").api
local mcursor = require "core.utils.mcursor"

---Cursor highlight as the colorscheme defined it, saved while the alert is on.
---@type vim.api.keyset.get_hl_info?
local saved

---@param on boolean
local function alert(on)
  if on and not saved then
    local colors = require("core.utils.palette").colors
    saved = api.get_hl(0, { name = "Cursor", link = false })
    if not vim.tbl_isempty(saved) then
      -- MCursor links to Cursor by default; bake the value in so the extra
      -- cursors keep the normal look while the primary one turns red.
      api.set_hl(0, "MCursor", saved)
    end
    api.set_hl(0, "Cursor", { fg = colors.black, bg = colors.bright_red })
  elseif not on and saved then
    api.set_hl(0, "Cursor", saved)
    api.set_hl(0, "MCursor", { link = "Cursor" })
    saved = nil
  end
end

local group = api.create_augroup("mcursor_alert", {})

-- There is no event for session start/end, but CmdAtom fires after every user
-- action -- including the "Q" that starts a session and the CTRL-L that ends it.
api.create_autocmd("CmdAtom", {
  desc = "Recolor the primary cursor during a multicursor session",
  group = group,
  callback = function()
    alert(mcursor.active())
  end,
})

api.create_autocmd("ColorScheme", {
  desc = "Re-read the Cursor highlight when the colorscheme changes mid-session",
  group = group,
  callback = function()
    if saved then
      saved = nil
      alert(true)
    end
  end,
})
