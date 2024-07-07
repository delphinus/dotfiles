local fn, uv, api = require("core.utils").globals()

---@class core.utils.lualine.Lualine
---@field is_lsp_available boolean
local Lualine = {}

---@alias color {fg: string, bg: string}

---@return core.utils.lualine.Lualine
Lualine.new = function()
  return setmetatable({
    is_lsp_available = false,
  }, { __index = Lualine })
end

---@return nil
function Lualine:config()
  local palette = require "core.utils.palette"
  local colors = palette.colors

  -- TODO: borrow from set.lua
  local home_re = uv.os_homedir():gsub("%.", "%.")

  local function octo_host()
    local ok, octo = pcall(require, "core.utils.octo")
    if ok then
      return "" .. (octo.current_host == octo.enterprise_host and " Ent" or ".com")
    end
    return ""
  end

  local function octo_color()
    local ok, octo = pcall(require, "core.utils.octo")
    if ok and octo.current_host == octo.enterprise_host then
      return { fg = colors.green, bg = colors.black }
    end
    return { fg = colors.black, bg = colors.orange }
  end

  local function title()
    local filename = api.buf_get_name(0)
    if vim.o.filetype == "help" then
      return "ヘルプ"
      -- TODO: vim.opt has no 'previewwindow'?
    elseif vim.o.previewwindow then
      return "プレビュー"
    elseif vim.o.buftype == "terminal" then
      return "TERM"
    end
    local dir = uv.cwd():gsub("^" .. home_re, "~", 1)
    return table.concat(
      vim
        .iter(vim.split(dir, "/"))
        :map(function(v)
          return "󰉋 " .. v
        end)
        :totable(),
      ""
    )
  end

  require("lualine").setup {
    extensions = { "quickfix" },
    options = {
      theme = self:theme(colors),
      section_separators = "",
      component_separators = "❘",
      globalstatus = true,
    },
    sections = {
      lualine_a = { { "mode", fmt = self:no_ellipsis_tr { 80, 4 } } },
      lualine_b = { { "filename", fmt = self:tr { { 40, 0 }, { 80, 10 }, { 100, 30 } } } },
      lualine_c = {
        { "branch", fmt = self:tr { { 80, 0 }, { 90, 10 } } },
        {
          self:lsp(function()
            return self:lsp_clients()
          end),
          color = { fg = colors.yellow },
          fmt = self:tr { 100, 0 },
        },
      },
      lualine_x = {
        {
          function()
            return "AutoFmt"
          end,
          fmt = self:tr { { 30, 0 }, { 50, "F" }, { 80, "Fmt" } },
          separator = "",
          color = self:lsp(function()
            return require("auto_fmt").is_enabled() and { fg = colors.black, bg = colors.green } or { fg = colors.blue }
          end),
        },
        {
          function()
            return "LspDiag"
          end,
          separator = "",
          fmt = self:tr { { 30, 0 }, { 50, "D" }, { 80, "Diag" } },
          color = self:lsp(function()
            local is_enabled = #vim.lsp.get_clients { bufnr = 0 } > 0 and vim.diagnostic.is_enabled { bufnr = 0 }
            -- See core.utils.lsp
            return is_enabled and { fg = colors.black, bg = colors.green } or { fg = colors.blue }
          end),
        },
        { "filetype", fmt = self:tr { 100, 0 } },
      },
      lualine_y = {
        { "progress", fmt = self:tr { 90, 0 } },
        { "filesize", fmt = self:tr { 120, 0 } },
      },
      lualine_z = { { "%l:%c%V", fmt = self:tr { 50, 0 } } },
    },
    tabline = {
      lualine_a = { { octo_host, fmt = self:tr { { 120, 0 } }, color = octo_color } },
      lualine_b = { { title, fmt = self:tr { { 120, 60 } }, color = { fg = colors.yellow } } },
      lualine_c = {
        {
          self:noice "message" "get",
          cond = self:noice "message" "has",
          color = { fg = colors.orange },
          fmt = self:tr { { 90, 0 }, { 120, 30 }, { 999, 80 } },
        },
        {
          self:noice "command" "get",
          cond = self:noice "command" "has",
          color = { fg = colors.cyan },
        },
        {
          self:noice "mode" "get",
          cond = self:noice "mode" "has",
          color = { fg = colors.blue },
        },
        {
          self:noice "search" "get",
          cond = self:noice "search" "has",
          color = { fg = colors.magenta },
        },
      },
      lualine_x = { { self:char_info(), fmt = self:tr { 80, 0 } } },
      lualine_y = {
        { "encoding", fmt = self:tr { 90, 0 } },
        { "fileformat", padding = { left = 0 }, fmt = self:tr { 90, 0 } },
      },
      lualine_z = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { bg = colors.brighter_red },
        },
      },
    },
  }
end

-- https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
-- settings should be tables below
-- { 80, 3 }
-- --> The component should be truncated to 3 chars when width < 80.
-- { { 80, 3 }, { 50, 0 } }
-- --> The component should be truncated to 3 chars when width < 80 and
-- disappear when width < 50.
-- { { 80, 'Foo' }, { 50, 'F' }, { 30, 0 } }
-- --> The component should be truncated to 'Foo' when width < 80 and 'F'
-- when width < 50 and disappear when width < 30.
---@param str string
---@param settings table
---@param no_ellipsis boolean | nil
---@return string
function Lualine:truncator(str, settings, no_ellipsis) -- luacheck: ignore 212
  ---@type integer
  local columns = vim.opt.columns:get()
  if type(settings[1]) ~= "table" then
    settings = { settings }
  end
  ---@type table
  for _, t in ipairs(settings) do
    ---@type integer
    local width = t[1]
    ---@type integer | string
    local len_or_str = t[2]
    ---@type integer
    local len
    ---@type string
    local alt_str
    if type(len_or_str) == "string" then
      alt_str = len_or_str
      len = #alt_str
    else
      len = len_or_str
    end
    if columns < width and #str > len then
      if alt_str then
        return alt_str
      elseif len == 0 then
        return ""
      end
      local truncated = require("plenary.strings").truncate(str, len, (no_ellipsis and "" or nil))
      -- TODO: deal with ellipsis
      if not no_ellipsis and truncated:match("[^%%]%%" .. "…$") then
        truncated = truncated:gsub("%%…$", "…")
      end
      return truncated
    end
  end
  return str
end

---@param settings table
---@return fun(str: string) -> string
function Lualine:tr(settings)
  ---@param str string
  return function(str)
    return self:truncator(str, settings)
  end
end

---@param settings table
---@return fun(str: string) -> string
function Lualine:no_ellipsis_tr(settings)
  ---@param str string
  return function(str)
    return self:truncator(str, settings, true)
  end
end

---@return string
function Lualine:lsp_clients() -- luacheck: ignore 212
  ---@type { id: integer, name: string }[]
  local clients = vim.lsp.get_active_clients { bufnr = 0 }
  local segments = vim
    .iter(clients)
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
      return ("%s(%d)%s"):format(client.name, client.id, additionals)
    end)
    :totable()
  return table.concat(segments, " ")
end

---@return fun() -> string
function Lualine:char_info() -- luacheck: ignore 212
  return function()
    local characterize = require "characterize"
    ---@type string
    local char = characterize.cursor_char()
    ---@type { char: string, nr: string, codepoint: string, description: string, shikakugoma: string, digraphs: string, emojis: string, html_entity: string }[]
    local results = characterize.info_table(char)
    if #results == 0 then
      return "NUL"
    end
    local r = results[1]
    local escaped = r.char:gsub("%%", "%%%%")
    local sign = require("eaw").get(char)
    local text = ("<%s> %s %s"):format(escaped, r.codepoint, sign)
    if r.digraphs and #r.digraphs > 0 then
      text = text .. ", \\<C-K>" .. r.digraphs[1]
    end
    if r.description ~= "<unknown>" then
      text = text .. ", " .. r.description
    end
    if r.shikakugoma then
      text = text .. ", " .. r.shikakugoma
    end
    return text
  end
end

---@deprecated This is replaced by dropbar.nvim
---@return fun(): string
function Lualine:tag() -- luacheck: ignore 212
  return function()
    if not package.loaded["nvim-treesitter"] then
      return ""
    end
    ---@return string | nil
    local treesitter_tag = function()
      local tag = require("nvim-treesitter.statusline").statusline {
        separator = " » ",
        ---@param t string
        transform_fn = function(t)
          return t:gsub("%s*[%[%(%{].*$", "")
        end,
      }
      return tag and tag ~= "" and tag or nil
    end

    local ok, ts = pcall(treesitter_tag)
    return ok and ts or "«no tag»"
  end
end

---@generic T
---@param f fun(): T
---@return fun(): T
function Lualine:lsp(f)
  ---@return string
  return function()
    return self.is_lsp_available and f() or ""
  end
end

---@param kind string
---@return fun(method: string): (fun(): string)
function Lualine:noice(kind) -- luacheck: ignore 212
  ---@param method string
  ---@return fun(): string?
  return function(method)
    ---@return string?
    return function()
      return package.loaded.noice and require("noice").api.status[kind][method]() or ""
    end
  end
end

---@param colors core.utils.palette.Colors
---@return string|table
function Lualine:theme(colors)
  if vim.g.colors_name == "nord" then
    return "nord"
  elseif vim.g.colors_name == "sweetie" then
    return {
      normal = {
        a = { bg = colors.teal, fg = colors.black, gui = "bold" },
        b = { bg = colors.bg_alt, fg = colors.white },
        c = { bg = colors.bg_hl, fg = colors.white },
      },
      insert = {
        a = { bg = colors.white, fg = colors.black, gui = "bold" },
      },
      visual = {
        a = { bg = colors.blue, fg = colors.black, gui = "bold" },
      },
      replace = {
        a = { bg = colors.yellow, fg = colors.black, gui = "bold" },
      },
      command = {
        a = { bg = colors.green, fg = colors.black, gui = "bold" },
      },
      inactive = {
        a = { bg = colors.cyan, fg = colors.black, gui = "bold" },
        b = { bg = colors.bg_hl, fg = colors.white },
        c = { bg = colors.bg_hl, fg = colors.white },
      },
    }
  end
end

return Lualine.new()
