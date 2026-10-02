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
-- 比べる相手は、引数が無ければデフォルトブランチとの分岐点 (git merge-base origin/HEAD
-- HEAD)。作業ツリーと HEAD を比べる素の :CodeDiff だと、Claude Code が変更を
-- すぐコミットしたとたん一覧が空になり、何も残らない。分岐点と作業ツリーを
-- 比べれば、コミット済みの変更も含めてブランチ全体 (= PR の差分) が見える。
-- :CodeDiffWatch HEAD で素の :CodeDiff と同じ比較、:CodeDiffWatch <rev> で
-- <rev> との分岐点と比べる。
--
-- codediff の内部 API (core.git / ui.view / core.path) を直接呼んでいるので、
-- プラグインの更新で動かなくなることがある。そのときは素の :CodeDiff に落とす。

local M = {}

-- 素の :CodeDiff で開く。msg があれば、内部 API が使えなかったとして警告する。
local function open_plain(msg, revision)
  if msg then
    vim.notify("CodeDiffWatch: " .. msg .. " (:CodeDiff で開きます)", vim.log.levels.WARN)
  end
  if revision then
    vim.cmd.CodeDiff(revision)
  else
    vim.cmd.CodeDiff()
  end
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

-- revision が nil なら作業ツリーと HEAD (Status Mode)、あればその commit と
-- 作業ツリーを比べる explorer を空で作る。
local function open_empty(git_root, status_result, revision)
  local ok, err = pcall(function()
    local view = require "codediff.ui.view"
    view.create({
      panel = {
        name = "explorer",
        data = {
          status_result = status_result,
          source_revisions = revision and { original = revision, modified = "WORKING" } or nil,
        },
      },
      git_root = git_root,
      original = require("codediff.core.path").empty(),
      modified = require("codediff.core.path").empty(),
      original_revision = revision,
      modified_revision = revision and "WORKING" or nil,
    }, "")
    -- create は新しいタブを開いた時点で戻ってくる。空の explorer では差分の
    -- 両側が埋まらないので、"Working tree is clean" の画面は自分で出す。
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.schedule(function()
      pcall(view.show_welcome, tabpage)
    end)
  end)
  if not ok then
    open_plain(tostring(err), revision)
  end
end

local function git_out(git_root, args)
  local r = vim.system(vim.list_extend({ "git", "-C", git_root }, args), { text = true }):wait()
  if r.code ~= 0 then
    return nil
  end
  local out = vim.trim(r.stdout or "")
  return out ~= "" and out or nil
end

-- 比べる相手の commit を決める。nil なら作業ツリーと HEAD を比べる。
local function resolve_base(git_root, arg)
  if arg == "HEAD" then
    return nil
  end
  local base = arg
  if not base or base == "" then
    -- origin/HEAD が無ければ (clone 後に set-head していない等) 諦めて HEAD と比べる。
    base = git_out(git_root, { "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
    if not base then
      return nil
    end
  end
  local mb = git_out(git_root, { "merge-base", base, "HEAD" })
  if not mb then
    vim.notify(
      "CodeDiffWatch: " .. base .. " との分岐点が見つかりません。HEAD と比べます",
      vim.log.levels.WARN
    )
    return nil
  end
  -- デフォルトブランチ上で作業しているなら分岐点 = HEAD。Status Mode のほうが
  -- staged / unstaged を分けて見せてくれるので、そちらにする。
  if mb == git_out(git_root, { "rev-parse", "HEAD" }) then
    return nil
  end
  return mb
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
  if
    not ok
    or not git.get_git_root
    or not git.get_status_with_line_stats
    or not git.get_diff_revision_with_line_stats
  then
    return open_plain "codediff の内部 API が見つかりません"
  end
  local arg = opts and opts.args or nil
  git.get_git_root(vim.fn.getcwd(), function(err_root, git_root)
    vim.schedule(function()
      if err_root or not git_root then
        vim.notify("CodeDiffWatch: git リポジトリではありません: " .. vim.fn.getcwd(), vim.log.levels.ERROR)
        return
      end
      local revision = resolve_base(git_root, arg)
      local function on_status(err_status, status_result)
        vim.schedule(function()
          if err_status or not status_result then
            return open_plain(err_status, revision)
          end
          local empty = #(status_result.unstaged or {}) == 0
            and #(status_result.staged or {}) == 0
            and #(status_result.conflicts or {}) == 0
          if empty then
            open_empty(git_root, status_result, revision)
          else
            open_plain(nil, revision)
          end
        end)
      end
      if revision then
        git.get_diff_revision_with_line_stats(revision, git_root, on_status)
      else
        git.get_status_with_line_stats(git_root, on_status)
      end
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
    nargs = "?",
    bang = true,
    desc = "Open codediff explorer even when the working tree is clean",
  })
end

return M
