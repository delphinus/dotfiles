return function()
  ---@class modules.start.config.lualine.Lualine
  local Lualine = {}

  ---@return modules.start.config.lualine.Lualine
  Lualine.new = function()
    local self = {}
    return setmetatable(self, { __index = Lualine })
  end

  ---@return nil
  function Lualine:config()
    vim.loop.new_timer():start(
      0, -- never timeout
      500, -- repeat every 500 ms
      vim.schedule_wrap(vim.cmd.redrawtabline)
    )

    require("lualine").setup {
      extensions = { "quickfix" },
      options = {
        theme = "nord",
        section_separators = "",
        component_separators = "❘",
        globalstatus = true,
      },
      sections = {
        lualine_a = { { "mode", fmt = self:no_ellipsis_tr { 80, 4 } } },
        lualine_b = { { "filename", fmt = self:tr { { 40, 0 }, { 80, 10 }, { 100, 30 } } } },
        lualine_c = {
          { "branch", fmt = self:tr { { 80, 0 }, { 90, 10 } } },
          { self:lsp(), color = { fg = "#ebcb8b" }, fmt = self:tr { 100, 0 } },
          {
            "diff",
            symbols = {
              added = "↑",
              modified = "→",
              removed = "↓",
            },
            fmt = self:tr { 110, 0 },
          },
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            diagnostics_color = {
              error = { fg = "#e5989f" },
              warn = { fg = "#ebcb8b" },
              info = { fg = "#8ca9cd" },
              hint = { fg = "#616e88" },
            },
            symbols = {
              error = "●", -- U+25CF
              warn = "○", -- U+25CB
              info = "■", -- U+25A0
              hint = "□", -- U+25A1
            },
            fmt = self:tr { 120, 0 },
          },
        },
        lualine_x = {
          {
            function()
              return "AutoFmt"
            end,
            fmt = self:tr { { 30, 0 }, { 50, "F" }, { 80, "Fmt" } },
            separator = "",
            color = function()
              local is_enabled = require("core.utils.lsp.auto_formatting").is_enabled(0)
              return is_enabled and { fg = "#2e3440", bg = "#a3be8c" } or { fg = "#81a1c1" }
            end,
          },
          {
            function()
              return "LspDiag"
            end,
            separator = "",
            fmt = self:tr { { 30, 0 }, { 50, "D" }, { 80, "Diag" } },
            color = function()
              -- See core.utils.lsp
              local is_enabled = not vim.b.lsp_diagnostics_disabled and #vim.lsp.get_active_clients { bufnr = 0 } > 0
              return is_enabled and { fg = "#2e3440", bg = "#a3be8c" } or { fg = "#81a1c1" }
            end,
          },
          { "filetype", fmt = self:tr { 100, 0 } },
        },
        lualine_y = {
          { "progress", fmt = self:tr { 90, 0 } },
          { "filesize", fmt = self:tr { 120, 0 } },
        },
        lualine_z = { { "location", fmt = self:tr { 50, 0 } } },
      },
      tabline = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { self:tag(), separator = "❘" },
          {
            "lsp_progress",
            display_components = { "lsp_client_name", "spinner", { "title", "percentage" } },
            colors = {
              percentage = "#a3be8c",
              title = "#d08770",
              message = "#8ca9cd",
              spinner = "#ebcb8b",
              lsp_client_name = "#b48ead",
              use = true,
            },
            color = { fg = "#b48ead" },
            spinner_symbols = { "⡿", "⣟", "⣯", "⣷", "⣾", "⣽", "⣻", "⢿" },
            --fmt = tr { { 80, 0 }, { 90, 10 }, { 999, 60 } },
            -- colored components cannot be truncated
          },
        },
        lualine_x = { { self:char_info(), fmt = self:tr { 80, 0 } } },
        lualine_y = {
          { "encoding", fmt = self:tr { 90, 0 } },
          { "fileformat", padding = { left = 0 }, fmt = self:tr { 90, 0 } },
        },
        lualine_z = {},
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
  function Lualine:truncator(str, settings, no_ellipsis)
    local truncate = require("plenary.strings").truncate
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
        local truncated = truncate(str, len, (no_ellipsis and "" or nil))
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

  ---@return fun() -> string
  function Lualine:lsp()
    return function()
      ---@type { id: integer, name: string }[]
      local clients = vim.lsp.get_active_clients { bufnr = 0 }
      local result = ""
      for _, client in pairs(clients) do
        if result ~= "" then
          result = result .. " "
        end
        result = result .. ("%s(%d)"):format(client.name, client.id)
      end
      return result
    end
  end

  ---@return fun() -> string
  function Lualine:char_info()
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
      local sign = require 'eaw'.get(char)
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

  ---@return fun() -> string
  function Lualine:tag()
    return function()
      ---@return string | nil
      local treesitter_tag = function()
        local tag = require("nvim-treesitter").statusline {
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

  local lualine = Lualine.new()
  lualine:config()
end
