-- Benchmark: luamigemo vs kensaku.vim (jsmigemo)
-- Usage: NVIM_APPNAME=nvim-dev/bench-migemo nvim +e\ ~/.local/share/nvim/lazy/vimdoc-ja/doc/usr_21.jax

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Determine dictionary path before lazy.setup (used in flash.nvim mode function closure)
local kensaku_dict = vim.env.HOME .. "/.cache/kensaku.vim/migemo-compact-dict"
local bench_dict_path = vim.uv.fs_stat(kensaku_dict) and kensaku_dict or nil

require("lazy").setup({
  { "vim-denops/denops.vim" },
  { "lambdalisue/kensaku.vim" },
  { "delphinus/luamigemo", dir = vim.env.HOME .. "/.local/share/nvim/lazy/luamigemo" },
  { "yuki-yano/fuzzy-motion.vim" },
  { "vim-jp/vimdoc-ja" },
  {
    "folke/flash.nvim",
    opts = {
      labels = "HJKLASDFGYUIOPQWERTNMZXCVB",
      search = {
        mode = function(str)
          if str == "" then
            return str
          end
          if #str < 2 then
            return "\\%#."
          end
          local luamigemo = require "luamigemo"
          local instance = luamigemo.get(bench_dict_path)
          return "\\c" .. instance:query(str, luamigemo.RXOP_VIM)
        end,
      },
    },
  },
})

-- Case-insensitive search (matches fuzzy-motion.vim default behavior)
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keymaps
vim.keymap.set({ "n", "x" }, "s", "<Cmd>FuzzyMotion<CR>")
vim.keymap.set({ "n", "x" }, "<Leader>s", function() require("flash").jump() end)

-- fuzzy-motion settings
vim.g.fuzzy_motion_labels = vim.split("HJKLASDFGYUIOPQWERTNMZXCVB", "")
vim.g.fuzzy_motion_matchers = "kensaku,fzf"

-- Pre-load dictionary and warm caches for common romaji prefixes in background
vim.defer_fn(function()
  local luamigemo = require("luamigemo")
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
  print("## Pattern generation: luamigemo vs kensaku.vim (jsmigemo + denops IPC)")
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

    print(("%-10s | %11.3f ms | %11.3f ms | %10d | %10d"):format(
      input, lua_ms, ken_ms, #lua_pat, #ken_pat
    ))
  end

  print()

  -- 2. Search time
  print("## vim.fn.searchpos() with generated patterns")
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

  -- 3. Flash simulation
  print("## Simulated flash.nvim total latency (incremental input for 'joutai')")
  print(sep)

  local lua_total = 0
  local ken_total = 0

  for _, input in ipairs(inputs) do
    local saved = vim.fn.getpos "."

    local t0 = vim.uv.hrtime()
    for _ = 1, N do
      local pat = migemo:query(input, rxop)
      vim.fn.cursor(1, 1)
      vim.fn.searchpos(pat, "cW")
    end
    local lua_ms = (vim.uv.hrtime() - t0) / 1e6 / N
    lua_total = lua_total + lua_ms

    local t1 = vim.uv.hrtime()
    for _ = 1, N do
      local pat = vim.fn["kensaku#query"](input)
      vim.fn.cursor(1, 1)
      vim.fn.searchpos(pat, "cW")
    end
    local ken_ms = (vim.uv.hrtime() - t1) / 1e6 / N
    ken_total = ken_total + ken_ms

    vim.fn.setpos(".", saved)

    print(("  %-10s | lua: %8.3f ms | ken: %8.3f ms"):format(input, lua_ms, ken_ms))
  end

  print(sep)
  print(("  %-10s | lua: %8.3f ms | ken: %8.3f ms"):format("TOTAL", lua_total, ken_total))
  print()
  print("  - kensaku includes denops IPC overhead (Vim -> Deno -> Vim)")
  print("  - fuzzy-motion.vim runs kensaku ASYNC in Deno, so UI never blocks")
  print("  - flash.nvim calls mode function SYNC, so all latency blocks UI")

  print()

  -- 4. True incremental search simulation
  print("## True incremental search: 'j' -> 'jo' -> 'jou' -> 'jout' -> 'jouta' -> 'joutai'")
  print("   (caches from previous keystroke benefit next keystroke)")
  print(sep)

  local incr_inputs = { "j", "jo", "jou", "jout", "jouta", "joutai" }

  -- Force fresh instance to simulate cold start
  package.loaded["luamigemo"] = nil
  local fresh_mod = require("luamigemo")
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
  print("  - luamigemo: cold start, each step benefits from previous step's cache")
  print("  - kensaku: always hot (denops already running)")

  -- Restore singleton
  package.loaded["luamigemo"] = nil
  require("luamigemo").get(bench_dict_path)
end, {})
