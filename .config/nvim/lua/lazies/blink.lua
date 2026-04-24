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

local function ghe_hosts()
  if not vim.env.GITHUB_ENTERPRISE_HOST then
    return {}
  end
  return vim.split(vim.env.GITHUB_ENTERPRISE_HOST, ",", { trimempty = true })
end

local function matched_ghe_host()
  local hosts = ghe_hosts()
  if #hosts == 0 then
    return nil
  end
  local ok, utils = pcall(require, "blink-cmp-git.utils")
  if not ok then
    return nil
  end
  local url = utils.get_repo_remote_url()
  if not url or url == "" then
    return nil
  end
  for _, host in ipairs(hosts) do
    if url:find(host, 1, true) then
      return host
    end
  end
  return nil
end

-- Per-source single-letter icons used in the menu's kind_icon column for
-- sources whose default kind icon carries no useful information. Sources not
-- listed here (lsp, lazydev, snippets, path, buffer, ...) keep blink.cmp's
-- default kind icon.
local source_letters = {
  wezterm = "W",
  ripgrep = "R",
  ghq = "Q",
  digraphs = "D",
  git = "G",
  dictionary = "K",
  emoji = "E",
  nerdfont = "N",
  fish = "F",
  skkeleton = "J",
}

-- Per-source highlight group used both for the kind_icon override above and
-- for the source_name column on the right of the menu. Reuses Vim standard
-- syntax groups so colors come from the active colorscheme.
local source_groups = {
  lsp = "Type",
  path = "Directory",
  snippets = "Special",
  buffer = "Comment",
  lazydev = "Function",
  wezterm = "Constant",
  ripgrep = "Number",
  ghq = "String",
  digraphs = "Identifier",
  git = "WarningMsg",
  dictionary = "Keyword",
  emoji = "Statement",
  nerdfont = "Operator",
  fish = "Macro",
  skkeleton = "Tag",
}

-- Wrap blink-cmp-git's default github feature so that GHE hosts listed in
-- $GITHUB_ENTERPRISE_HOST are recognized as enabled and `gh` is invoked with
-- --hostname to target the right instance.
local function github_feature_override(feature)
  return {
    enable = function()
      local default = require("blink-cmp-git.default.github")[feature]
      return default.enable() or matched_ghe_host() ~= nil
    end,
    get_command_args = function(command, token)
      local default = require("blink-cmp-git.default.github")[feature]
      local args = default.get_command_args(command, token)
      local host = matched_ghe_host()
      if host and command ~= "curl" then
        table.insert(args, "--hostname")
        table.insert(args, host)
      end
      return args
    end,
  }
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
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name", gap = 1 },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local letter = source_letters[ctx.source_id]
                  if letter then
                    return letter .. ctx.icon_gap
                  end
                  return ctx.kind_icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  local hl = source_groups[ctx.source_id]
                  if hl then
                    return { { group = hl, priority = 20000 } }
                  end
                  return { { group = ctx.kind_hl, priority = 20000 } }
                end,
              },
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
              source_name = {
                width = { max = 12 },
                text = function(ctx)
                  return ctx.source_name
                end,
                highlight = function(ctx)
                  return source_groups[ctx.source_id] or "BlinkCmpSource"
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
          wezterm = { name = "wezterm", module = "blink-cmp-wezterm", min_keyword_length = 2, async = true },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            async = true,
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
            opts = {
              insert = true,
              trigger = function()
                return { ":" }
              end,
            },
          },
          dictionary = {
            name = "Dict",
            module = "blink-cmp-dictionary",
            min_keyword_length = 4,
            async = true,
            opts = { dictionary_files = { "/usr/share/dict/words" } },
          },
          fish = { name = "fish", module = "blink.compat.source", async = true },
          ghq = { name = "ghq", module = "blink-cmp-ghq", async = true },
          digraphs = {
            name = "Digraphs",
            module = "blink-cmp-digraphs",
            -- Allow invocation when no keyword chars are present (e.g. typing
            -- "->" or "+-") so trigger characters alone fire the source.
            min_keyword_length = 0,
            score_offset = 50,
          },
          git = {
            name = "Git",
            module = "blink-cmp-git",
            async = true,
            opts = {
              git_centers = {
                github = {
                  issue = github_feature_override "issue",
                  pull_request = github_feature_override "pull_request",
                  mention = github_feature_override "mention",
                },
              },
              -- Restrict commit-hash completion (`:` trigger) to commit
              -- message contexts so it doesn't pollute every buffer.
              -- Within those contexts, also override configure_score_offset
              -- to a no-op: blink-cmp-git's default assigns per-item offsets
              -- up to (N - 1), which would still drown out emoji items even
              -- when both sources are enabled.
              commit = {
                enable = function()
                  return vim.tbl_contains({ "gitcommit", "octo" }, vim.bo.filetype)
                end,
                configure_score_offset = function(items)
                  for i = 1, #items do
                    items[i].score_offset = 0
                  end
                end,
              },
            },
          },
          nerdfont = {
            name = "Nerd Fonts",
            module = "blink-nerdfont",
            score_offset = 15,
            opts = { insert = true },
          },
          skkeleton = { name = "skkeleton", module = "blink-cmp-skkeleton" },
        },
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
