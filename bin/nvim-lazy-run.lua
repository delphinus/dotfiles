-- 設定を読み込んだ headless nvim の中で走る、自動化フローの「実行」部分。
-- `:Lazy sync` を回し、そのままでは取りこぼす後始末までやってから結果を返す。
--
-- なぜ独立したファイルなのか: `nvim -l` は user config を読まないので lazy の
-- API に手が届かない。config を読ませるには `nvim --headless -c 'luafile ...'`
-- しかなく、その -c に渡す本体がこれ。呼ぶのは nvim-lazy-sync。
--
-- 結果は stdout ではなく $NVIM_LAZY_OUT に JSON で書く。lazy は headless でも
-- 進捗を stdout に流すので、混ぜると機械が読めなくなる。
--
-- env:
--   NVIM_LAZY_OUT          結果 JSON の書き出し先 (必須)
--   NVIM_LAZY_TS_TIMEOUT   TSUpdate の上限 ms (既定 1800000 = 30 分)

local out_path = vim.env.NVIM_LAZY_OUT
if not out_path or out_path == "" then
  io.stderr:write "nvim-lazy-run: NVIM_LAZY_OUT is required\n"
  vim.cmd "cquit 2"
end

local DATA = vim.fn.stdpath "data"
local INFO = DATA .. "/site/parser-info"
local TS_DIR = DATA .. "/lazy/nvim-treesitter"

local result = {}

local function finish()
  vim.fn.writefile({ vim.json.encode(result) }, out_path)
  vim.cmd "qall!"
end

-- パーサの現状。lazy-lock.json には載らないので、自前で前後を撮って
-- 「何が再ビルドされたか」を割り出す。
---@return table<string, string>
local function snapshot_parsers()
  local snap = {}
  if not vim.uv.fs_stat(INFO) then
    return snap
  end
  for name, kind in vim.fs.dir(INFO) do
    local lang = name:match "^(.+)%.revision$"
    if lang and kind == "file" then
      snap[lang] = vim.trim(table.concat(vim.fn.readfile(INFO .. "/" .. name), ""))
    end
  end
  return snap
end

-- 更新後も pin と一致しない言語 = コンパイルに失敗した言語。
---@param installed table<string, string>
---@return string[]?, string?
local function still_stale(installed)
  local pfile = TS_DIR .. "/lua/nvim-treesitter/parsers.lua"
  if not vim.uv.fs_stat(pfile) then
    return nil, "parsers.lua not found"
  end
  local ok, parsers = pcall(dofile, pfile)
  if not ok then
    return nil, tostring(parsers)
  end
  local stale = {}
  for lang, rev in pairs(installed) do
    local spec = parsers[lang]
    local pinned = spec and spec.install_info and spec.install_info.revision
    if pinned and pinned ~= rev then
      stale[#stale + 1] = lang
    end
  end
  table.sort(stale)
  return stale, nil
end

--------------------------------------------------------------------- 1. sync

local before = snapshot_parsers()

-- bang を付けると lazy が自分のタスクを同期的に待つ
-- (lazy/view/commands.lua: `local opts = { wait = cmd.bang == true }`)。
-- ただし待つのは lazy のタスクまでで、build フックの中で始まった非同期処理は
-- 待たない。treesitter の後始末を下でやるのはそのため。
local ok, err = pcall(vim.cmd, "Lazy! sync")
result.sync = { ok = ok, error = not ok and tostring(err) or nil }

------------------------------------------------------- 2. lazy のタスク失敗を拾う

-- headless では :Lazy の画面が出ないので、失敗しても黙って通り過ぎる。
-- markdown-preview の yarn / op.nvim の go build / CopilotChat の luarocks は
-- ここでしか落ちたことが分からない。
do
  local errors, warnings = {}, {}
  local okc, Config = pcall(require, "lazy.core.config")
  if okc then
    for name, plugin in pairs(Config.plugins) do
      for _, task in ipairs(plugin._.tasks or {}) do
        if task:has_errors() then
          errors[#errors + 1] = {
            plugin = name,
            task = task.name,
            output = task:output(vim.log.levels.ERROR),
          }
        elseif task:has_warnings() then
          warnings[#warnings + 1] = {
            plugin = name,
            task = task.name,
            output = task:output(vim.log.levels.WARN),
          }
        end
      end
    end
  else
    result.sync.error = (result.sync.error and result.sync.error .. "; " or "")
      .. "cannot require lazy.core.config: "
      .. tostring(Config)
  end
  table.sort(errors, function(a, b)
    return a.plugin < b.plugin
  end)
  table.sort(warnings, function(a, b)
    return a.plugin < b.plugin
  end)
  result.task_errors = errors
  result.task_warnings = warnings
end

--------------------------------------------------- 3. treesitter の後始末を待つ

-- `build = ":TSUpdate"` は非同期で、lazy は「コマンドを実行した」時点で完了と
-- みなす。headless だとそのまま nvim が終了し、中途半端な .so が残りうる。
-- プラグイン側のドキュメント (doc/nvim-treesitter.txt) が script 文脈での作法と
-- して示している update():wait() を、ここで明示的に回して待ち切る。
local ts = { attempted = false }
if vim.uv.fs_stat(TS_DIR) then
  ts.attempted = true
  local timeout = tonumber(vim.env.NVIM_LAZY_TS_TIMEOUT) or 30 * 60 * 1000
  ts.timeout_ms = timeout

  -- nvim-treesitter は lazy 扱いなので、まず読み込まないと install に届かない。
  local lok, install = pcall(function()
    require("lazy").load { plugins = { "nvim-treesitter" } }
    return require "nvim-treesitter.install"
  end)
  if not lok then
    ts.error = "cannot load nvim-treesitter: " .. tostring(install)
  else
    -- pcall(f) は (pcall_ok, f の戻り値...) なので、pwait の (ok, err) が
    -- そのまま後ろに並ぶ。
    local pok, wok, werr = pcall(function()
      return install.update(nil, { summary = true }):pwait(timeout)
    end)
    if not pok then
      ts.error = tostring(wok)
    else
      ts.ok = wok
      if not wok then
        ts.error = tostring(werr)
      end
    end
  end
end

local after = snapshot_parsers()
do
  local rebuilt, installed, gone = {}, {}, {}
  for lang, rev in pairs(after) do
    if before[lang] == nil then
      installed[#installed + 1] = lang
    elseif before[lang] ~= rev then
      rebuilt[#rebuilt + 1] = lang
    end
  end
  for lang in pairs(before) do
    if after[lang] == nil then
      gone[#gone + 1] = lang
    end
  end
  table.sort(rebuilt)
  table.sort(installed)
  table.sort(gone)
  ts.rebuilt = rebuilt
  ts.newly_installed = installed
  ts.uninstalled = gone
  ts.parser_count = vim.tbl_count(after)

  local stale, serr = still_stale(after)
  if serr then
    ts.stale_error = serr
  else
    -- 更新を回した後にまだ残っている = そのコンパイルは失敗している。
    ts.failed = stale
  end
end
result.treesitter = ts

finish()
