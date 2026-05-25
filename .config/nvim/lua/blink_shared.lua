-- Shared blink.cmp helpers and provider configs reused by both the main
-- nvim config and the nvim-dev/skkeleton sub-config (editprompt / gitcommit).
-- The dev config prepends this file's directory to package.path so it can
-- `require("blink_shared")` the same module the main config uses.

local M = {}

-- True if the token before cursor starts with a path-marker (/, ~/, ./, ../,
-- $VAR/, ${VAR}/). Mirrors blink.cmp の path source の lib.dirname() and
-- intentionally excludes URL/namespace strings like "github.com/foo/bar".
function M.in_path_context()
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

local function ghe_hosts()
  if not vim.env.GITHUB_ENTERPRISE_HOST then
    return {}
  end
  return vim.split(vim.env.GITHUB_ENTERPRISE_HOST, ",", { trimempty = true })
end

function M.matched_ghe_host()
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

-- Wrap blink-cmp-git's default github feature so that GHE hosts listed in
-- $GITHUB_ENTERPRISE_HOST are recognized as enabled and `gh` is invoked with
-- --hostname to target the right instance.
function M.github_feature_override(feature)
  return {
    enable = function()
      local default = require("blink-cmp-git.default.github")[feature]
      return default.enable() or M.matched_ghe_host() ~= nil
    end,
    get_command_args = function(command, token)
      local default = require("blink-cmp-git.default.github")[feature]
      local args = default.get_command_args(command, token)
      local host = M.matched_ghe_host()
      if host and command ~= "curl" then
        table.insert(args, "--hostname")
        table.insert(args, host)
      end
      return args
    end,
  }
end

-- Per-source single-letter icons for the menu's kind_icon column. Sources not
-- listed here keep blink.cmp's default kind icon.
M.source_letters = {
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

-- Per-source highlight group used both for the kind_icon override and the
-- source_name column. Reuses Vim standard syntax groups so colors track the
-- active colorscheme.
M.source_groups = {
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

-- カタカナ U+30A1..U+30F6 をひらがなにずらして返す。
-- ー (U+30FC) や記号類、漢字、ASCII はそのまま素通し。
local function kata_to_hira(s)
  return (
    s:gsub("[\xE3][\x82-\x83][\x80-\xBF]", function(ch)
      local cp = vim.fn.char2nr(ch)
      if cp >= 0x30A1 and cp <= 0x30F6 then
        return vim.fn.nr2char(cp - 0x60)
      end
      return ch
    end)
  )
end

-- frizbee は UTF-8 を理解しないバイト単位 subsequence matcher なので、入力
-- ひらがなが label のカタカナや漢字と「先頭 1 byte だけ」「2 byte だけ」一致
-- して中途半端に光ってしまう。skkeleton 項目では辞書 key 全体 (item.data.kana,
-- 例 "おねがいします") と label (例 "お願いします") を文字単位で整列させ、各
-- label char が読みのどの範囲を担当するかを決定 → 入力の prefix
-- (item.filterText, 例 "おねがいし") がその範囲を完全に覆っていれば光らせる。
-- 整列のルール:
--   * 各 label char をひらがな化したものが「読みの残り」と一致したら、その
--     位置を端点として確定 (kp = j+1 に進める)。
--   * 一致しない char (漢字、ASCII 等) は pending に積み、次に揃った hira/kata
--     が見つかった時点で「前回の確定位置 .. 今回の j-1」を pending 全体に割り
--     当てる (連続する漢字は同じ範囲を共有する保守的な扱い)。
--   * 末尾に残った pending は読みの末尾まで覆うとみなす。
-- これにより、漢字も「自分が担当する読み区間がユーザ入力に完全に含まれている」
-- 場合だけ光る。逆に半端な入力 ("おね" だけで「願」がまだ "ねが" の "ね" しか
-- 来ていない等) では光らない、保守的な挙動になる。
local function skk_label_match_ranges(item)
  if not (item and item.label and item.filterText and item.filterText ~= "") then
    return {}
  end
  local full_kana = item.data and item.data.kana
  if not full_kana or full_kana == "" then
    return {}
  end
  local label_chars = vim.fn.split(item.label, "\\zs")
  local fk_chars = vim.fn.split(kata_to_hira(full_kana), "\\zs")
  local typed_n = vim.fn.strchars(item.filterText)

  local start_pos, end_pos = {}, {}
  local pending = {}
  local kp = 1
  for i, ch in ipairs(label_chars) do
    local norm = kata_to_hira(ch)
    local j
    for m = kp, #fk_chars do
      if fk_chars[m] == norm then
        j = m
        break
      end
    end
    if j then
      for _, ki in ipairs(pending) do
        start_pos[ki] = kp
        end_pos[ki] = j - 1
      end
      pending = {}
      start_pos[i], end_pos[i] = j, j
      kp = j + 1
    else
      table.insert(pending, i)
    end
  end
  for _, ki in ipairs(pending) do
    start_pos[ki] = kp
    end_pos[ki] = #fk_chars
  end

  local ranges, byte_pos = {}, 0
  for i, ch in ipairs(label_chars) do
    -- start > end means this char covers zero kana (e.g. ラベル中の余計な
    -- 記号や読みに含まれない文字)。読みを担当していないのでハイライト対象外。
    if start_pos[i] and end_pos[i] and start_pos[i] <= end_pos[i] and end_pos[i] <= typed_n then
      table.insert(ranges, { byte_pos, byte_pos + #ch })
    end
    byte_pos = byte_pos + #ch
  end
  return ranges
end

-- label.highlight コールバック本体を包む wrapper。skkeleton 項目について
-- だけ ctx.label_matched_indices を一時的に空にして inner を呼ぶことで、
-- inner (および colorful-menu) が出してくる frizbee 由来の誤
-- BlinkCmpLabelMatch を抑止し、その後で正しい文字単位の range を追加する。
-- skkeleton 以外の項目では完全な no-op として振る舞う。
function M.with_skk_label_match(ctx, inner)
  local is_skk = ctx.item and ctx.item.data and ctx.item.data.skkeleton
  local saved
  if is_skk then
    saved = ctx.label_matched_indices
    ctx.label_matched_indices = {}
  end
  local highlights = inner(ctx)
  if is_skk then
    ctx.label_matched_indices = saved
    for _, r in ipairs(skk_label_match_ranges(ctx.item)) do
      table.insert(highlights, { r[1], r[2], group = "BlinkCmpLabelMatch" })
    end
  end
  return highlights
end

-- Returns blink.cmp menu draw components (kind_icon override + source_name)
-- that color each candidate by its source. The caller can merge with its own
-- `label` component (e.g. for colorful-menu integration).
function M.menu_components()
  return {
    kind_icon = {
      ellipsis = false,
      text = function(ctx)
        local letter = M.source_letters[ctx.source_id]
        if letter then
          return letter .. ctx.icon_gap
        end
        return ctx.kind_icon .. ctx.icon_gap
      end,
      highlight = function(ctx)
        local hl = M.source_groups[ctx.source_id]
        if hl then
          return { { group = hl, priority = 20000 } }
        end
        return { { group = ctx.kind_hl, priority = 20000 } }
      end,
    },
    source_name = {
      width = { max = 12 },
      text = function(ctx)
        return ctx.source_name
      end,
      highlight = function(ctx)
        return M.source_groups[ctx.source_id] or "BlinkCmpSource"
      end,
    },
  }
end

-- Returns the common blink.cmp provider configs. Callers extend with their
-- own config-specific providers (e.g. lazydev / lsp / fish / nerdfont / path
-- with custom opts) via vim.tbl_extend.
function M.providers()
  return {
    -- Boost LSP above source-flooding providers (ghq returns ~800 items,
    -- buffer can return ~400, wezterm 100+, etc.). Without this, an empty-
    -- prefix LSP query like `vim.|` ranks LSP items in the noise and the
    -- menu's visible top-N is dominated by other sources. lazydev sits at
    -- score_offset = 100 so it stays above LSP for require()-style paths.
    lsp = { score_offset = 50 },
    buffer = {
      opts = {
        get_bufnrs = function()
          return vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded):totable()
        end,
      },
    },
    wezterm = { name = "wezterm", module = "blink-cmp-wezterm", min_keyword_length = 2, async = true },
    ghq = { name = "ghq", module = "blink-cmp-ghq", async = true },
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
    digraphs = {
      name = "Digraphs",
      module = "blink-cmp-digraphs",
      -- Allow invocation when no keyword chars are present (e.g. typing
      -- "->" or "+-") so trigger characters alone fire the source.
      min_keyword_length = 0,
      -- Boost only when the user has typed both characters of a digraph
      -- (e.g. "Ye", "oe"). On a single-char prefix (e.g. just ":"), leave
      -- the boost off so we don't drown out emoji on the shared `:`
      -- trigger.
      transform_items = function(ctx, items)
        local col = ctx.cursor[2]
        local prefix = ctx.line:sub(math.max(1, col - 1), col)
        local boost = #prefix >= 2 and 50 or 0
        for _, item in ipairs(items) do
          item.score_offset = (item.score_offset or 0) + boost
        end
        return items
      end,
    },
    git = {
      name = "Git",
      module = "blink-cmp-git",
      async = true,
      opts = {
        git_centers = {
          github = {
            issue = M.github_feature_override "issue",
            pull_request = M.github_feature_override "pull_request",
            mention = M.github_feature_override "mention",
          },
        },
        -- Override the commit feature so it:
        -- 1. Uses `;` instead of the default `:` trigger. The default
        --    collides with emoji / nerdfont / digraphs on `:` and the
        --    commit hashes get drowned out. `;` is rare in real code and
        --    dedicates the trigger to commit completion.
        -- 2. Also activates in GHE repos (default only checks github.com).
        -- 3. Limits `git log` to the most recent 100 commits so pre-cache
        --    stays fast in large repos.
        commit = {
          triggers = { ";" },
          enable = function()
            local default = require("blink-cmp-git.default.commit").enable
            return default() or M.matched_ghe_host() ~= nil
          end,
          get_command_args = function(command, token)
            local default = require("blink-cmp-git.default.commit").get_command_args
            local args = default(command, token)
            if command == "git" then
              table.insert(args, "-100")
            end
            return args
          end,
        },
      },
    },
    skkeleton = { name = "skkeleton", module = "blink-cmp-skkeleton" },
  }
end

-- Register `:BlinkProf` and `:BlinkProfPath` user commands. The profiler
-- monkey-patches each blink.cmp source provider's `get_completions` to record
-- per-source latency and item counts. Call once during config load; the
-- patching is lazy and only kicks in when the user runs `:BlinkProf`.
function M.setup_profiler()
  local prof = { on = false, log = {}, wrapped = {} }

  local function wrap_module(id, mod)
    if prof.wrapped[id] or type(mod.get_completions) ~= "function" then
      return
    end
    prof.wrapped[id] = true
    local orig = mod.get_completions
    mod.get_completions = function(self, ctx, cb)
      if not prof.on then
        return orig(self, ctx, cb)
      end
      local t0 = vim.uv.hrtime()
      local kw = ctx.line:sub(ctx.bounds.start_col, ctx.cursor[2])
      return orig(self, ctx, function(resp)
        local dt = (vim.uv.hrtime() - t0) / 1e6
        table.insert(prof.log, {
          id = id,
          ms = dt,
          kw = kw,
          n = (resp and resp.items) and #resp.items or 0,
        })
        cb(resp)
      end)
    end
  end

  local function arm()
    local lib = require "blink.cmp.sources.lib"
    for id, prov in pairs(lib.providers) do
      if prov and prov.module then
        wrap_module(id, prov.module)
      end
    end
    if not lib._blink_prof_patched then
      lib._blink_prof_patched = true
      local orig = lib.get_provider_by_id
      lib.get_provider_by_id = function(pid)
        local prov = orig(pid)
        if prov and prov.module then
          wrap_module(pid, prov.module)
        end
        return prov
      end
    end
  end

  vim.api.nvim_create_user_command("BlinkProfPath", function(opts)
    local dir = vim.fn.expand(opts.args ~= "" and opts.args or "%:p:h")
    local t0 = vim.uv.hrtime()
    vim.uv.fs_scandir(dir, function(err, req)
      local t_open = (vim.uv.hrtime() - t0) / 1e6
      if err or not req then
        vim.schedule(function()
          vim.notify("scandir error: " .. tostring(err))
        end)
        return
      end
      local count = 0
      while vim.uv.fs_scandir_next(req) do
        count = count + 1
      end
      local t_walk = (vim.uv.hrtime() - t0) / 1e6
      local t_sched = vim.uv.hrtime()
      vim.schedule(function()
        local t_lat = (vim.uv.hrtime() - t_sched) / 1e6
        vim.notify(
          string.format(
            "%s\n  scandir open : %.2fms\n  walk %d entries: %.2fms\n  schedule lat : %.2fms",
            dir,
            t_open,
            count,
            t_walk - t_open,
            t_lat
          )
        )
      end)
    end)
  end, { nargs = "?", complete = "dir" })

  vim.api.nvim_create_user_command("BlinkProf", function(opts)
    local arg = opts.args
    if arg == "off" then
      prof.on = false
      vim.notify("BlinkProf OFF (" .. #prof.log .. " entries logged)")
    elseif arg == "clear" then
      prof.log = {}
      vim.notify "BlinkProf log cleared"
    elseif arg == "dump" then
      local sums = {}
      for _, e in ipairs(prof.log) do
        local s = sums[e.id] or { n = 0, total = 0, max = 0, items = 0 }
        s.n = s.n + 1
        s.total = s.total + e.ms
        s.max = math.max(s.max, e.ms)
        s.items = s.items + e.n
        sums[e.id] = s
      end
      local rows = {}
      for id, s in pairs(sums) do
        table.insert(rows, { id = id, s = s })
      end
      table.sort(rows, function(a, b)
        return a.s.total > b.s.total
      end)
      local lines = {
        string.format("%-15s %5s  %9s  %7s  %8s  %6s", "source", "calls", "total(ms)", "avg(ms)", "max(ms)", "items"),
      }
      for _, r in ipairs(rows) do
        table.insert(
          lines,
          string.format(
            "%-15s %5d  %9.1f  %7.2f  %8.2f  %6d",
            r.id,
            r.s.n,
            r.s.total,
            r.s.total / r.s.n,
            r.s.max,
            r.s.items
          )
        )
      end
      table.insert(lines, "")
      table.insert(lines, "slowest single calls:")
      local sorted = vim.deepcopy(prof.log)
      table.sort(sorted, function(a, b)
        return a.ms > b.ms
      end)
      for i = 1, math.min(10, #sorted) do
        local e = sorted[i]
        table.insert(lines, string.format("  %7.2fms  %-12s  items=%d  kw=%q", e.ms, e.id, e.n, e.kw))
      end
      vim.notify(table.concat(lines, "\n"))
    else
      arm()
      prof.on = true
      prof.log = {}
      vim.notify "BlinkProf ON"
    end
  end, {
    nargs = "?",
    complete = function()
      return { "off", "clear", "dump" }
    end,
  })
end

return M
