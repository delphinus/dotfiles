-- Karabiner-Elements 連携。左右の ⌘ を単体で押したときに skkeleton のかな・
-- 英数を切り替えるための下支え。
--
-- Karabiner 側 (.config/karabiner/assets/complex_modifications/japanese.json)
-- は変数 neovim_in_insert_mode を見て振る舞いを変える:
--   0 … macOS の IME を切り替える (japanese_eisuu / japanese_kana)
--   1 … skkeleton に <A-j> / <A-J> を送る
-- ここでその変数を nvim 側のモードに追随させる。補完エンジンが nvim-cmp か
-- blink.cmp かとは無関係なので、core.skkeleton_cmp とは別モジュールにして
-- 常に setup() すること (両者を混ぜて CMP=1 の時だけ有効にしてしまい、既定の
-- blink.cmp では ⌘ 単体押しが効かなくなっていた)。
local M = {}

local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

---@async
---@param cmds string[][]
---@return string[]
local function async_systems(cmds)
  local async = require "plenary.async"
  local async_system = async.wrap(vim.system, 3)
  local results = vim.tbl_map(
    function(v)
      return v[1]
    end,
    async.util.join(vim.tbl_map(function(cmd)
      return function()
        return async_system(cmd)
      end
    end, cmds))
  ) --[[@as vim.SystemCompleted[] ]]
  local stdouts = {}
  for j, job in ipairs(results) do
    if job.code ~= 0 then
      vim.notify(
        ("command execution failed => cmd: %s, err => %s"):format(cmds[j][1], job.stderr),
        vim.log.levels.ERROR
      )
    end
    table.insert(stdouts, job.stdout or "")
  end
  return stdouts
end

---@async
---@param val number
local function async_karabiner(val)
  async_systems { { karabiner_cli, "--set-variables", vim.json.encode { neovim_in_insert_mode = val } } }
end

---@param f async function
---@return function
local function void(f)
  return function(...)
    require("plenary.async").void(f)(...)
  end
end

---@param val number
---@return async fun()
local function set_karabiner(val)
  return function()
    void(async_karabiner)(val)
  end
end

---@async
local function async_mode_karabiner()
  local is_in_insert = not not require("plenary.async").api.nvim_get_mode().mode:match "[icrR]"
  async_karabiner(is_in_insert and 1 or 0)
end

---@param window table kitten @ ls が返すウィンドウ
---@return boolean そのウィンドウの前面プロセスが nvim か
local function runs_nvim(window)
  for _, proc in ipairs(window.foreground_processes or {}) do
    if vim.fs.basename((proc.cmdline or {})[1] or "") == "nvim" then
      return true
    end
  end
  return false
end

---@async
---@return number? いま実際に見られている kitty のウィンドウ id
---@return boolean そのウィンドウで nvim が動いているか
local function kitty_focused_window()
  -- kitty は OS ウィンドウ・タブ・ウィンドウのすべてに is_focused を持っている。
  -- OS ウィンドウのそれが「kitty が最前面のアプリか」を含んでいるので、WezTerm
  -- 版で要った osascript でのフロントモスト判定 (500ms ごとに 1 プロセス) が
  -- 丸ごと不要になる。
  --
  -- ただし **タブを先に絞らないと正しい答えが出ない**。kitty は OS ウィンドウが
  -- フォーカスされていると、そのウィンドウの *全タブ* のアクティブなウィンドウに
  -- is_focused = true を立てる (実測: タブが 6 つあると is_focused なウィンドウが
  -- 6 つ返る)。実際に見えている 1 つを区別できるのはタブの is_focused だけ。
  -- タブを見ずに最初の is_focused を拾うと、常に先頭タブのウィンドウ id を
  -- 返してしまい、そこに居る nvim が「自分が見られている」と誤認する。
  local results = async_systems { { "kitten", "@", "ls" } }
  local ok, os_windows = pcall(vim.json.decode, results[1])
  if not ok or type(os_windows) ~= "table" then
    return nil, false
  end
  for _, os_window in ipairs(os_windows) do
    if os_window.is_focused then
      for _, tab in ipairs(os_window.tabs or {}) do
        if tab.is_focused then
          for _, window in ipairs(tab.windows or {}) do
            if window.is_focused then
              return window.id, runs_nvim(window)
            end
          end
        end
      end
    end
  end
  return nil, false
end

function M.setup()
  if not vim.uv.fs_stat(karabiner_cli) then
    return
  end

  local group = vim.api.nvim_create_augroup("skkeleton_karabiner", {})

  vim.api.nvim_create_autocmd(
    { "InsertEnter", "CmdlineEnter" },
    { group = group, callback = set_karabiner(1), desc = "Enable Karabiner-Elements settings for skkeleton" }
  )
  vim.api.nvim_create_autocmd(
    { "InsertLeave", "CmdlineLeave", "FocusLost" },
    { group = group, callback = set_karabiner(0), desc = "Disable Karabiner-Elements settings for skkeleton" }
  )
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = void(async_mode_karabiner),
    desc = "Enable/Disable Karabiner-Elements settings for skkeleton",
  })

  -- 変数を 1 に上げた nvim が挿入モードのまま終了すると、誰も 0 に戻せない。
  -- 他のインスタンスは「フォーカスされた kitty ウィンドウの主」でない限り何も
  -- 書かないため。kitty の editprompt (オーバーレイの nvim で Claude Code の
  -- プロンプトを書く) を閉じたときがこれに当たるので、終了時に自分で戻す。
  -- VimLeavePre では非同期の完了を待てないので同期で叩く。
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    desc = "Reset Karabiner-Elements settings for skkeleton",
    callback = function()
      vim.system({ karabiner_cli, "--set-variables", vim.json.encode { neovim_in_insert_mode = 0 } }):wait()
    end,
  })

  local running = false
  assert(vim.uv.new_timer()):start(
    500,
    500,
    vim.schedule_wrap(void(function()
      if running then
        return
      end
      running = true
      local window_var = vim.uv.os_getenv "KITTY_WINDOW_ID"
      if not window_var then
        running = false
        return
      end
      local my_window = tonumber(window_var, 10)
      local focused, focused_runs_nvim = kitty_focused_window()
      if not focused then
        -- kitty が最前面でない。IME の設定は落としておく。
        async_karabiner(0)
      elseif focused == my_window then
        async_mode_karabiner()
      elseif not focused_runs_nvim then
        -- 見られているのは nvim でない kitty ウィンドウ (シェル、Claude Code 等)。
        -- 変数を 1 に上げた nvim が下がるとは限らないので、ここで落としておく。
        -- 具体例: kitty の editprompt は送信後に自分を隠すだけで終了しないため、
        -- 挿入モードのまま裏に残り、誰も 0 に戻さないと ⌘ が効かなくなる。
        async_karabiner(0)
      end
      -- 上以外 (自分ではない別の nvim が見られている) は、その nvim が自分の
      -- モードを書くので何もしない。
      running = false
    end))
  )
end

return M
