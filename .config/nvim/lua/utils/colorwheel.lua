--- colorwheel()
-- This returns a function-like table to draw a color wheel
--
-- require'utils.colorwheel'()
return setmetatable({
  pixel_ratio = 2 / 1,

  -- Converts the coordinate into the color in RGB representation.
  position_to_rgb = function(_, x, y, r)
    local theta = math.atan2(y, x)
    local angle = theta >= 0 and theta or theta + 2 * math.pi
    -- TODO: enable to change v
    local h, s, v = angle / (2 * math.pi), r, 1

    -- Convert HSV to RGB
    local rgb = {}
    if v == 0 then
      rgb = { 0, 0, 0 }
    elseif s == 0 then
      rgb = { v, v, v }
    else
      local chroma = s * v
      local min_v = v - chroma
      local ratio
      if h > 2 / 3 then
        local temp = (h - 2 / 3) * 6
        ratio = temp < 1 and { v * temp, 0, v } or { v, 0, v * (2 - temp) }
      elseif h > 1 / 3 then
        local temp = (h - 1 / 3) * 6
        ratio = temp < 1 and { 0, v, v * temp } or { 0, v * (2 - temp), v }
      else
        local temp = h * 6
        ratio = temp < 1 and { v, v * temp, 0 } or { v * (2 - temp), v, 0 }
      end
      for i = 1, 3 do
        rgb[i] = ratio[i] / v * (v - min_v) + min_v
      end
    end
    return ("#%02x%02x%02x"):format(rgb[1] * 255, rgb[2] * 255, rgb[3] * 255)
  end,
}, {
  __call = function(self)
    local center_x, center_y = vim.o.columns / 2, vim.o.lines / 2
    local radius = math.min(vim.o.columns / self.pixel_ratio, vim.o.lines) / 8 * 3
    -- loop over the distance multiplied by pixel_ratio in the horizontal
    -- direction because the character has a rectangular shape.
    local min_col, max_col = center_x - radius * self.pixel_ratio, center_x + radius * self.pixel_ratio - 1
    local min_row, max_row = center_y - radius * self.pixel_ratio, center_y + radius * self.pixel_ratio - 1
    for col = min_col, max_col do
      for row = min_row, max_row do
        -- calculate the coordinate mathematically
        local x, y = (col - center_x) / self.pixel_ratio, center_y - row
        -- distance from the center max to 1.0
        local r = math.sqrt(x * x + y * y) / radius
        if r < 1.0 then
          local i_col, i_row = math.floor(col), math.floor(row)
          -- open a float window with 1x1 size
          local winid = api.open_win(fn.bufnr "", false, {
            style = "minimal",
            relative = "win",
            width = 1,
            height = 1,
            col = i_col,
            row = i_row,
          })
          local hl_name = ("CircleBG%d%d"):format(i_col, i_row)
          api.set_hl(0, hl_name, { bg = self:position_to_rgb(x, y, r) })
          api.win_set_option(winid, "winhighlight", "Normal:" .. hl_name)
        end
      end
    end
  end,
})
