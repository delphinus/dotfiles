---@diagnostic disable: missing-fields
local lazy_require = require "lazy_require"

local default_sources = {
  "lsp",
  "path",
  "snippets",
  "buffer",
  "lazydev",
  "wezterm",
  "rg",
  "ctags",
  "treesitter",
  "ghq",
  "digraphs",
  "git",
  "look",
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
  "rg",
  "ghq",
  "digraphs",
  "git",
  "look",
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

  -- nvim-cmp source plugins, surfaced via blink.compat
  { "delphinus/cmp-wezterm" },
  { "delphinus/cmp-ctags" },
  { "delphinus/cmp-ghq" },
  { "ray-x/cmp-treesitter" },
  { "mtoohey31/cmp-fish" },
  { "octaltree/cmp-look" },
  { "dmitmel/cmp-digraphs" },
  { "hrsh7th/cmp-nvim-lua" },
  { "lukas-reineke/cmp-rg" },
  { "hrsh7th/cmp-emoji" },
  { "chrisgrieser/cmp-nerdfont" },
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
          lua = with_skk(vim.list_extend(vim.deepcopy(default_sources), { "nvim_lua" })),
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
          wezterm = { name = "wezterm", module = "blink.compat.source", min_keyword_length = 2 },
          rg = { name = "rg", module = "blink.compat.source", min_keyword_length = 4 },
          ctags = { name = "ctags", module = "blink.compat.source" },
          treesitter = { name = "treesitter", module = "blink.compat.source" },
          fish = { name = "fish", module = "blink.compat.source" },
          ghq = { name = "ghq", module = "blink.compat.source" },
          digraphs = { name = "digraphs", module = "blink.compat.source", min_keyword_length = 1 },
          git = { name = "git", module = "blink.compat.source" },
          look = {
            name = "look",
            module = "blink.compat.source",
            min_keyword_length = 4,
            opts = { convert_case = true, loud = true },
          },
          emoji = { name = "emoji", module = "blink.compat.source" },
          nerdfont = { name = "nerdfont", module = "blink.compat.source" },
          nvim_lua = { name = "nvim_lua", module = "blink.compat.source" },
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
