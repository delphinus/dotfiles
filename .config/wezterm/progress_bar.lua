---@class wezterm.ProgressBar
---@field size integer
local ProgressBar = {}

---@param size integer
---@return wezterm.ProgressBar
function ProgressBar.new(size)
  return setmetatable({ size = size }, { __index = ProgressBar })
end

---@param percent number
---@return string
function ProgressBar:render(percent)
  local glyphs = { "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█" }
  local f = math.floor
  local count = f(self.size * #glyphs * percent)
  local full = f(count / #glyphs)
  local result = {}
  for _ = 1, full do
    table.insert(result, glyphs[#glyphs])
  end
  local rest = count % #glyphs
  local spaces = self.size - full
  if rest > 0 then
    table.insert(result, glyphs[rest])
    spaces = spaces - 1
  end
  if spaces > 0 then
    for _ = 1, spaces do
      table.insert(result, " ")
    end
  end
  return table.concat(result)
end

return ProgressBar
