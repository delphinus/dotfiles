-- :CodeDiffWatch — 変更が無くても codediff の explorer を開いて、変更を待ち受ける。
--
-- 素の :CodeDiff は作業ツリーがきれいだと "No changes to show" と通知して何も
-- 開かない (handlers/explorer.lua の process_status)。変更の監視は explorer を
-- 開いたときに始まるので、そのあと変更が入っても映らない。kitty の codediff
-- ペイン (~/.config/kitty/codediff.py) は Claude Code の編集を待ち受けたいので、
-- 空でも開いてほしい。
--
-- explorer が空になったときに codediff 自身が出す "Working tree is clean" の
-- 画面 (ui/welcome.lua) がそのまま使えるので、空の status で explorer を作る。
-- 変更があるときは素の :CodeDiff に任せる。
--
-- もう 1 つ、何も選ばれていない explorer に変更が現れたら最初のファイルを選ぶ。
-- codediff は一覧を更新するだけで、右側は "Working tree is clean" のままになる
-- (]f を押せば開くが、待ち受けているペインでは押す人がいない)。空で開いた
-- ときに限らず、コミットして一覧が空になったあとにも同じことが起きる。
--
-- codediff の内部 API (core.git / ui.view / core.path) を直接呼んでいるので、
-- プラグインの更新で動かなくなることがある。そのときは素の :CodeDiff に落とす。

local M = {}

local function fallback(msg)
  if msg then
    vim.notify("CodeDiffWatch: " .. msg .. " (:CodeDiff で開きます)", vim.log.levels.WARN)
  end
  vim.cmd.CodeDiff()
end

-- 起動直後の空のタブを閉じる (:CodeDiffWatch!)。codediff は新しいタブに開くので、
-- nvim +CodeDiffWatch で起動すると 1 枚目に空のタブが残る。開くのは非同期なので、
-- 起動時に +tabonly を並べても間に合わない。タブが開くのを待ってから閉じる。
local function close_others_when_opened()
  vim.api.nvim_create_autocmd("TabNew", {
    once = true,
    callback = function()
      vim.schedule(function()
        vim.cmd "silent! tabonly"
      end)
    end,
  })
end

local function open_empty(git_root, status_result)
  local ok, err = pcall(function()
    local view = require "codediff.ui.view"
    view.create({
      panel = { name = "explorer", data = { status_result = status_result } },
      git_root = git_root,
      original = require("codediff.core.path").empty(),
      modified = require("codediff.core.path").empty(),
    }, "")
    -- create は新しいタブを開いた時点で戻ってくる。空の explorer では差分の
    -- 両側が埋まらないので、"Working tree is clean" の画面は自分で出す。
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.schedule(function()
      pcall(view.show_welcome, tabpage)
    end)
  end)
  if not ok then
    fallback(tostring(err))
  end
end

-- 選択中のファイルが無く、一覧にファイルがあれば最初のものを選ぶ。tab が
-- 閉じたら false を返してタイマーを止める。
local function select_first_if_idle(tabpage)
  if not vim.api.nvim_tabpage_is_valid(tabpage) then
    return false
  end
  local lifecycle = require "codediff.ui.lifecycle"
  local panel = lifecycle.get_panel(tabpage)
  local explorer = lifecycle.get_panel_view(tabpage)
  if not (panel and panel.name == "explorer" and explorer and explorer.tree) then
    return lifecycle.get_session(tabpage) ~= nil
  end
  if panel.data.current_file_path then
    return true
  end
  local files = require("codediff.ui.explorer.tree").get_all_files(explorer.tree)
  if #files > 0 then
    explorer.on_file_select(files[1].data)
  end
  return true
end

local INTERVAL = 1000

-- :CodeDiffWatch で開いた explorer だけを対象にする。素の :CodeDiff の挙動は変えない。
local pending = false

local function watch(tabpage)
  local timer = assert(vim.uv.new_timer())
  timer:start(
    INTERVAL,
    INTERVAL,
    vim.schedule_wrap(function()
      local ok, alive = pcall(select_first_if_idle, tabpage)
      if not (ok and alive) and not timer:is_closing() then
        timer:close()
      end
    end)
  )
end

function M.open(opts)
  pending = true
  if opts and opts.bang then
    close_others_when_opened()
  end
  local ok, git = pcall(require, "codediff.core.git")
  if not ok or not git.get_git_root or not git.get_status_with_line_stats then
    return fallback "codediff の内部 API が見つかりません"
  end
  git.get_git_root(vim.fn.getcwd(), function(err_root, git_root)
    if err_root or not git_root then
      vim.schedule(function()
        vim.notify("CodeDiffWatch: git リポジトリではありません: " .. vim.fn.getcwd(), vim.log.levels.ERROR)
      end)
      return
    end
    git.get_status_with_line_stats(git_root, function(err_status, status_result)
      vim.schedule(function()
        if err_status or not status_result then
          return fallback(err_status)
        end
        local empty = #(status_result.unstaged or {}) == 0
          and #(status_result.staged or {}) == 0
          and #(status_result.conflicts or {}) == 0
        if empty then
          open_empty(git_root, status_result)
        else
          vim.cmd.CodeDiff()
        end
      end)
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeDiffOpen",
    group = vim.api.nvim_create_augroup("codediff_watch", {}),
    callback = function(ev)
      if pending and ev.data and ev.data.mode == "explorer" and ev.data.tabpage then
        pending = false
        watch(ev.data.tabpage)
      end
    end,
  })
  vim.api.nvim_create_user_command("CodeDiffWatch", M.open, {
    nargs = 0,
    bang = true,
    desc = "Open codediff explorer even when the working tree is clean",
  })
end

return M
