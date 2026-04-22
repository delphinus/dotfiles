---@diagnostic disable: missing-fields
local lazy_require = require "lazy_require"

local default_sources = {
  "lsp",
  "path",
  "snippets",
  "buffer",
  "lazydev",
  "wezterm",
  "ripgrep",
  "ghq",
  "digraphs",
  "git",
  "dictionary",
  "emoji",
  "nerdfont",
}

local markdown_sources = {
  "lsp",
  "path",
  "snippets",
  "buffer",
  "lazydev",
  "wezterm",
  "ripgrep",
  "ghq",
  "digraphs",
  "git",
  "dictionary",
  "emoji",
  "nerdfont",
}

local function is_skk_enabled()
  local ok, skk = pcall(require, "blink-cmp-skkeleton")
  return ok and skk.is_enabled()
end

-- True if the token before cursor starts with a path-marker (/, ~/, ./, ../,
-- $VAR/, ${VAR}/). This mirrors blink.cmp の path source の lib.dirname() and
-- intentionally excludes URL/namespace strings like "github.com/foo/bar".
local function in_path_context()
  if vim.in_fast_event() then
    return false
  end
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local last = (line:sub(1, col):match "(%S+)$" or ""):gsub("^[\"'`]", "")
  return last:match "^/" ~= nil
    or last:match "^~/" ~= nil
    or last:match "^%.%.?/" ~= nil
    or last:match "^%$[%w_]+/" ~= nil
    or last:match "^%$%{[%w_]+%}/" ~= nil
end

local function with_skk(fallback)
  return function()
    if is_skk_enabled() then
      return { "skkeleton" }
    end
    if in_path_context() then
      return { "path" }
    end
    return fallback
  end
end

return {
  { "rafamadriz/friendly-snippets" },
  { "xzbdmw/colorful-menu.nvim" },
  {
    "L3MON4D3/LuaSnip",
    config = lazy_require("luasnip.loaders.from_vscode").lazy_load(),
  },

  { "saghen/blink.compat", version = "*", opts = {} },

  -- Native blink.cmp sources
  { "delphinus/cmp-wezterm" }, -- v1.1.0+ exposes a native blink-cmp-wezterm module
  { "mikavilpas/blink-ripgrep.nvim", version = "*" },
  { "moyiz/blink-emoji.nvim" },
  { "Kaiser-Yang/blink-cmp-dictionary" },
  { "MahanRahmati/blink-nerdfont.nvim" },

  -- nvim-cmp source plugins, surfaced via blink.compat
  { "delphinus/cmp-ghq" },
  { "mtoohey31/cmp-fish" },
  { "dmitmel/cmp-digraphs" },
  -- blink-cmp-git is upstream-blocked on GitHub Enterprise host support; keep
  -- petertriho/cmp-git via blink.compat until that lands.
  {
    "petertriho/cmp-git",
    opts = function()
      return vim.env.GITHUB_ENTERPRISE_HOST and { github = { hosts = vim.split(vim.env.GITHUB_ENTERPRISE_HOST, ",") } }
        or {}
    end,
  },

  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
      "xzbdmw/colorful-menu.nvim",
      "L3MON4D3/LuaSnip",
      "saghen/blink.compat",
    },
    version = "*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      snippets = { preset = "luasnip" },
      completion = {
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  local text = require("colorful-menu").blink_components_text(ctx)
                  if ctx.label_detail and ctx.label_detail ~= "" and not text:find(ctx.label_detail, 1, true) then
                    text = text .. " " .. ctx.label_detail
                  end
                  return text
                end,
                highlight = function(ctx)
                  local highlights = require("colorful-menu").blink_components_highlight(ctx)
                  local text = require("colorful-menu").blink_components_text(ctx)
                  if ctx.label_detail and ctx.label_detail ~= "" and not text:find(ctx.label_detail, 1, true) then
                    table.insert(
                      highlights,
                      { #text + 1, #text + 1 + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
                    )
                  end
                  return highlights
                end,
              },
            },
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = with_skk(default_sources),
        per_filetype = {
          fish = with_skk(vim.list_extend(vim.deepcopy(default_sources), { "fish" })),
          markdown = with_skk(markdown_sources),
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          buffer = {
            opts = { get_bufnrs = vim.api.nvim_list_bufs },
          },
          wezterm = { name = "wezterm", module = "blink-cmp-wezterm", min_keyword_length = 2 },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            opts = {
              prefix_min_len = 4,
              backend = {
                use = "ripgrep",
                ripgrep = {
                  context_size = 5,
                  max_filesize = "1M",
                  search_casing = "--ignore-case",
                },
              },
            },
          },
          emoji = {
            name = "Emoji",
            module = "blink-emoji",
            score_offset = 15,
            opts = { insert = true, trigger = function() return { ":" } end },
          },
          dictionary = {
            name = "Dict",
            module = "blink-cmp-dictionary",
            min_keyword_length = 4,
            opts = { dictionary_files = { "/usr/share/dict/words" } },
          },
          fish = { name = "fish", module = "blink.compat.source" },
          ghq = { name = "ghq", module = "blink.compat.source" },
          digraphs = { name = "digraphs", module = "blink.compat.source", min_keyword_length = 1 },
          git = { name = "git", module = "blink.compat.source" },
          nerdfont = {
            name = "Nerd Fonts",
            module = "blink-nerdfont",
            score_offset = 15,
            opts = { insert = true },
          },
          skkeleton = { name = "skkeleton", module = "blink-cmp-skkeleton" },
        },
      },
      keymap = {
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<A-u>"] = { "scroll_documentation_up", "fallback" },
        ["<A-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-f>"] = { "snippet_forward", "fallback" },
        ["<C-b>"] = { "snippet_backward", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Space>"] = {}, -- let skkeleton handle Space
      },
      cmdline = {
        completion = {
          menu = { auto_show = true },
          list = { selection = { preselect = false, auto_insert = true } },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
