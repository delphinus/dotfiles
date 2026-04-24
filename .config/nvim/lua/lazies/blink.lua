---@diagnostic disable: missing-fields
local lazy_require = require "lazy_require"
local shared = require "blink_shared"

shared.setup_profiler()

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

local function is_skk_enabled()
  local ok, skk = pcall(require, "blink-cmp-skkeleton")
  return ok and skk.is_enabled()
end

local function with_skk(fallback)
  return function()
    if is_skk_enabled() then
      return { "skkeleton" }
    end
    if shared.in_path_context() then
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
  { "delphinus/cmp-ghq", version = "*" }, -- v1.1.0+ exposes a native blink-cmp-ghq module
  { "mikavilpas/blink-ripgrep.nvim", version = "*" },
  { "moyiz/blink-emoji.nvim" },
  { "Kaiser-Yang/blink-cmp-dictionary" },
  { "delphinus/blink-cmp-digraphs", version = "*" },
  -- Pinned to delphinus' fork while
  -- https://github.com/Kaiser-Yang/blink-cmp-git/pull/68 (fix for ssh:// remote
  -- URL parsing) is awaiting upstream review. Drop the branch pin and switch
  -- back to Kaiser-Yang/blink-cmp-git once that PR is merged.
  { "delphinus/blink-cmp-git", branch = "fix/parse-ssh-url" },
  { "MahanRahmati/blink-nerdfont.nvim" },

  -- nvim-cmp source plugins, surfaced via blink.compat
  { "mtoohey31/cmp-fish" },

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
        -- Don't break undo on accept. blink.cmp's default treats each accept
        -- as a discrete operation (so `u` rewinds one accept at a time), but
        -- the trade-off is that `u` to revert to the file's initial state
        -- requires many presses. Match nvim-cmp's behavior so an i...<Esc>
        -- session is one undo unit; use `:earlier 1f` for "back to file open".
        accept = { create_undo_point = false },
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name", gap = 1 },
            },
            components = vim.tbl_extend("force", shared.menu_components(), {
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
            }),
          },
        },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = with_skk(default_sources),
        per_filetype = {
          fish = with_skk(vim.list_extend(vim.deepcopy(default_sources), { "fish" })),
        },
        providers = vim.tbl_extend("force", shared.providers(), {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          fish = { name = "fish", module = "blink.compat.source", async = true },
          nerdfont = {
            name = "Nerd Fonts",
            module = "blink-nerdfont",
            score_offset = 15,
            opts = { insert = true },
          },
        }),
      },
      fuzzy = {
        -- skkeleton 由来の候補は blink.cmp の fuzzy score / frecency を無視し、
        -- skkeleton 自身が付与した data.rank (Date.now() か負のグローバル順) で
        -- 並べる。skkeleton 以外の組み合わせでは nil を返して 'score' に委譲。
        sorts = {
          function(a, b)
            if not (a.data and a.data.skkeleton and b.data and b.data.skkeleton) then
              return nil
            end
            if a.data.rank == b.data.rank then
              return nil
            end
            return a.data.rank > b.data.rank
          end,
          "score",
          "sort_text",
        },
      },
      keymap = {
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
        -- macOS の IME 切り替えと被るため `<C-Space>` 代わりの手動トリガー。
        ["<C-,>"] = { "show", "fallback" },
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
