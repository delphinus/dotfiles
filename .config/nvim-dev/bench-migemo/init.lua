-- Benchmark: luamigemo vs kensaku.vim (jsmigemo)
-- Usage: NVIM_APPNAME=nvim-dev/bench-migemo nvim +e\ ~/.local/share/nvim/lazy/vimdoc-ja/doc/usr_21.jax

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Determine dictionary path before lazy.setup (used by the migemo warmup and BenchMigemo below)
local kensaku_dict = vim.env.HOME .. "/.cache/kensaku.vim/migemo-compact-dict"
local bench_dict_path = vim.uv.fs_stat(kensaku_dict) and kensaku_dict or nil

require("lazy").setup {
  {
    "folke/tokyonight.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { "vim-denops/denops.vim" },
  { "lambdalisue/kensaku.vim" },
  { "delphinus/luamigemo", dir = vim.env.HOME .. "/.local/share/nvim/lazy/luamigemo" },
  { "yuki-yano/fuzzy-motion.vim" },
  { "vim-jp/vimdoc-ja" },
  -- インタラクティブな s (ウィンドウ内インクリメンタル検索) は jab.nvim を使う。
  -- jab は luamigemo (バンドル辞書) を直接叩くので mode 関数の設定は不要。
  { "atusy/jab.nvim", dir = vim.env.HOME .. "/.local/share/nvim/lazy/jab.nvim" },
}

-- Case-insensitive search (matches fuzzy-motion.vim default behavior)
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keymaps
vim.keymap.set({ "n", "x" }, "<Leader>s", "<Cmd>FuzzyMotion<CR>")
vim.keymap.set({ "n", "x", "o" }, "s", function()
  return require("jab").jab_win {
    labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", ""),
  }
end, { expr = true })

-- fuzzy-motion settings
vim.g.fuzzy_motion_labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", "")
vim.g.fuzzy_motion_matchers = "kensaku,fzf"

-- Pre-load dictionary and warm caches for common romaji prefixes in background
vim.defer_fn(function()
  local luamigemo = require "luamigemo"
  local instance = luamigemo.get(bench_dict_path)
  local rxop = luamigemo.RXOP_VIM
  -- Query each single character to populate dictionary/mapping caches.
  -- Subsequent 2-char queries (e.g. "jo") benefit from the parent subtree cache.
  for c in ("aiueokstjnhmyrwgzdbpf"):gmatch "." do
    instance:query(c, rxop)
  end
end, 0)

-- Benchmark command
vim.api.nvim_create_user_command("BenchMigemo", function()
  local luamigemo = require "luamigemo"
  -- Get instance with the kensaku dictionary (or bundled if not available)
  local migemo = luamigemo.get(bench_dict_path)
  local rxop = luamigemo.RXOP_VIM
  local inputs = { "a", "jo", "jou", "jout", "jouta", "joutai" }
  local N = 50

  -- Warm up
  migemo:query("warmup", rxop)
  pcall(vim.fn["kensaku#query"], "warmup")

  local sep = string.rep("-", 100)

  -- 1. Pattern generation
  print "## Pattern generation: luamigemo vs kensaku.vim (jsmigemo + denops IPC)"
  if bench_dict_path then
    print("   (luamigemo using kensaku dictionary: " .. bench_dict_path .. ")")
  end
  print(("%-10s | %14s | %14s | %10s | %10s"):format("input", "luamigemo (ms)", "kensaku (ms)", "lua len", "ken len"))
  print(sep)

  local lua_patterns = {}
  local ken_patterns = {}

  for _, input in ipairs(inputs) do
    local t0 = vim.uv.hrtime()
    local lua_pat
    for _ = 1, N do
      lua_pat = migemo:query(input, rxop)
    end
    local lua_ms = (vim.uv.hrtime() - t0) / 1e6 / N
    lua_patterns[input] = lua_pat

    local t1 = vim.uv.hrtime()
    local ken_pat
    for _ = 1, N do
      ken_pat = vim.fn["kensaku#query"](input)
    end
    local ken_ms = (vim.uv.hrtime() - t1) / 1e6 / N
    ken_patterns[input] = ken_pat

    print(("%-10s | %11.3f ms | %11.3f ms | %10d | %10d"):format(input, lua_ms, ken_ms, #lua_pat, #ken_pat))
  end

  print()

  -- 2. Search time
  print "## vim.fn.searchpos() with generated patterns"
  print(("%-10s | %14s | %14s"):format("input", "luamigemo (ms)", "kensaku (ms)"))
  print(sep)

  for _, input in ipairs(inputs) do
    local saved = vim.fn.getpos "."

    local t0 = vim.uv.hrtime()
    for _ = 1, N do
      vim.fn.cursor(1, 1)
      vim.fn.searchpos(lua_patterns[input], "cW")
    end
    local lua_ms = (vim.uv.hrtime() - t0) / 1e6 / N

    local t1 = vim.uv.hrtime()
    for _ = 1, N do
      vim.fn.cursor(1, 1)
      vim.fn.searchpos(ken_patterns[input], "cW")
    end
    local ken_ms = (vim.uv.hrtime() - t1) / 1e6 / N

    vim.fn.setpos(".", saved)

    print(("%-10s | %11.3f ms | %11.3f ms"):format(input, lua_ms, ken_ms))
  end

  print()

  -- 3. jab simulation
  -- jab.nvim はクエリごとに migemo 正規表現を 1 度だけコンパイルし
  -- (単一エントリキャッシュ)、その vim.regex を各行に match_str で当てて走査する。
  -- flash のように Vim 組み込み検索へ 1 本のパターンを渡すのではなく、
  -- 行ごとに matcher を呼ぶのが jab の作り。ここでは可視範囲の代わりに
  -- バッファ全行を走査して 1 キーストロークあたりのコスト上限を測る。
  print "## Simulated jab.nvim total latency (incremental input for 'joutai')"
  print "   (compile migemo regex once per query, then scan every line with match_str)"
  print(sep)

  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local lua_total = 0
  local ken_total = 0

  for _, input in ipairs(inputs) do
    -- luamigemo: パターン生成 -> vim.regex を 1 回コンパイル -> 全行を走査
    local t0 = vim.uv.hrtime()
    for _ = 1, N do
      local re = vim.regex("\\c" .. migemo:query(input, rxop))
      for _, line in ipairs(buf_lines) do
        re:match_str(line)
      end
    end
    local lua_ms = (vim.uv.hrtime() - t0) / 1e6 / N
    lua_total = lua_total + lua_ms

    -- kensaku: 同じ形で kensaku 生成パターンを使う
    local t1 = vim.uv.hrtime()
    for _ = 1, N do
      local re = vim.regex("\\c" .. vim.fn["kensaku#query"](input))
      for _, line in ipairs(buf_lines) do
        re:match_str(line)
      end
    end
    local ken_ms = (vim.uv.hrtime() - t1) / 1e6 / N
    ken_total = ken_total + ken_ms

    print(("  %-10s | lua: %8.3f ms | ken: %8.3f ms"):format(input, lua_ms, ken_ms))
  end

  print(sep)
  print(("  %-10s | lua: %8.3f ms | ken: %8.3f ms"):format("TOTAL", lua_total, ken_total))
  print()
  print "  - kensaku includes denops IPC overhead (Vim -> Deno -> Vim)"
  print "  - fuzzy-motion.vim runs kensaku ASYNC in Deno, so UI never blocks"
  print "  - jab.nvim runs the matcher SYNC per line, so all latency blocks UI"

  print()

  -- 4. True incremental search simulation
  print "## True incremental search: 'j' -> 'jo' -> 'jou' -> 'jout' -> 'jouta' -> 'joutai'"
  print "   (caches from previous keystroke benefit next keystroke)"
  print(sep)

  local incr_inputs = { "j", "jo", "jou", "jout", "jouta", "joutai" }

  -- Force fresh instance to simulate cold start
  package.loaded["luamigemo"] = nil
  local fresh_mod = require "luamigemo"
  local fresh_migemo = fresh_mod.get(bench_dict_path)

  lua_total = 0
  ken_total = 0

  for _, input in ipairs(incr_inputs) do
    local saved = vim.fn.getpos "."

    local t0 = vim.uv.hrtime()
    local pat = fresh_migemo:query(input, rxop)
    vim.fn.cursor(1, 1)
    vim.fn.searchpos(pat, "cW")
    local lua_ms = (vim.uv.hrtime() - t0) / 1e6
    lua_total = lua_total + lua_ms

    local t1 = vim.uv.hrtime()
    local kpat = vim.fn["kensaku#query"](input)
    vim.fn.cursor(1, 1)
    vim.fn.searchpos(kpat, "cW")
    local ken_ms = (vim.uv.hrtime() - t1) / 1e6
    ken_total = ken_total + ken_ms

    vim.fn.setpos(".", saved)

    print(("  %-10s | lua: %8.3f ms | ken: %8.3f ms"):format(input, lua_ms, ken_ms))
  end

  print(sep)
  print(("  %-10s | lua: %8.3f ms | ken: %8.3f ms"):format("TOTAL", lua_total, ken_total))
  print "  - luamigemo: cold start, each step benefits from previous step's cache"
  print "  - kensaku: always hot (denops already running)"

  -- Restore singleton
  package.loaded["luamigemo"] = nil
  require("luamigemo").get(bench_dict_path)
end, {})

vim.cmd.colorscheme "tokyonight"
