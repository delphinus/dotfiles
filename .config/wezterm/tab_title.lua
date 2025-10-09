---@type Wezterm
local wezterm = require "wezterm"
local ProgressBar = require "progress_bar"

local progress_bar = ProgressBar.new(8)

local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

local PCT_GLYPHS = {
  wezterm.nerdfonts.md_circle_slice_1,
  wezterm.nerdfonts.md_circle_slice_2,
  wezterm.nerdfonts.md_circle_slice_3,
  wezterm.nerdfonts.md_circle_slice_4,
  wezterm.nerdfonts.md_circle_slice_5,
  wezterm.nerdfonts.md_circle_slice_6,
  wezterm.nerdfonts.md_circle_slice_7,
  wezterm.nerdfonts.md_circle_slice_8,
}
local function pct_glyph(pct)
  local slot = math.floor(pct / 12)
  return PCT_GLYPHS[slot + 1]
end

return function(config)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local progress = tab.active_pane.progress or "None"
    local title = tab_title(tab)
    local elements = {
      { Text = string.format("%d: ", tab.tab_index + 1) },
    }

    if progress ~= "None" then
      local color = config.colors.ansi[3]
      local status
      if progress.Percentage ~= nil then
        -- status = string.format("%d%%", progress.Percentage)
        status = progress_bar:render(progress.Percentage / 100)
      elseif progress.Error ~= nil then
        -- status = string.format("%d%%", progress.Error)
        status = pct_glyph(progress.Error)
        color = config.colors.ansi[2]
      elseif progress == "Indeterminate" then
        status = "~"
      else
        status = wezterm.serde.json_encode(progress)
      end

      table.insert(elements, { Foreground = { Color = color } })
      table.insert(elements, { Text = status })
      table.insert(elements, { Foreground = "Default" })
    end

    table.insert(elements, { Text = " " .. title .. " " })

    return elements
  end)
end
