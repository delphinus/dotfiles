-- lazy-lock.json の新旧を突き合わせ、プラグインごとの更新内容を JSON で吐く。
--
-- 判断はしない。判断材料を揃えるところまでが仕事で、「この更新を取り込んで
-- いいか」は人間 (と Claude) が読んで決める。
--
-- `nvim -l` で走らせるので user config は読まれない。解析に config は要らない
-- うえ、lazy.setup() は 'runtimepath' を作り替えるので、読ませない方が副作用が
-- 無い。逆に言うと lazy.nvim の API はここでは使えないので、プラグインの
-- クローン先 (stdpath("data") .. "/lazy") を直接触る。
--
-- usage: nvim -l nvim-lazy-analyze.lua [--ref <git-ref>] [--repo <path>]
--
--   --ref   比較元。既定は HEAD (= 直近のコミット時点の lock)
--   --repo  dotfiles のパス。既定はこのスクリプトの 1 つ上の階層

local LOCK = ".config/nvim/lazy-lock.json"
-- レコード区切り / フィールド区切り。コミットメッセージに現れない制御文字を使う。
local RS, FS = "\30", "\31"
-- 1 プラグインあたりに列挙するコミット数の上限。upstream を長く放置した後の
-- sync では数百件になることがあり、そのまま出すと読む側が溺れる。
local MAX_COMMITS = 40

local function die(msg)
  io.stderr:write("nvim-lazy-analyze: " .. msg .. "\n")
  os.exit(1)
end

---@param cwd string
---@param args string[]
---@return boolean ok, string stdout, string stderr
local function git(cwd, args)
  local res = vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
  return res.code == 0, res.stdout or "", res.stderr or ""
end

---@return string?
local function git_line(cwd, args)
  local ok, out = git(cwd, args)
  if not ok then
    return nil
  end
  local line = vim.split(vim.trim(out), "\n")[1]
  return line ~= "" and line or nil
end

---@return string[]
local function git_lines(cwd, args)
  local ok, out = git(cwd, args)
  if not ok then
    return {}
  end
  local list = {}
  for _, l in ipairs(vim.split(vim.trim(out), "\n")) do
    if l ~= "" then
      list[#list + 1] = l
    end
  end
  return list
end

--------------------------------------------------------------------- 引数

local ref, repo = "HEAD", nil
do
  local args = _G.arg or {}
  local i = 1
  while i <= #args do
    local a = args[i]
    if a == "--ref" then
      i = i + 1
      ref = args[i] or die "--ref needs a value"
    elseif a == "--repo" then
      i = i + 1
      repo = args[i] or die "--repo needs a value"
    else
      die("unknown argument: " .. tostring(a))
    end
    i = i + 1
  end
end

if not repo then
  local script = debug.getinfo(1, "S").source:sub(2)
  local real = vim.uv.fs_realpath(script) or script
  repo = vim.fs.dirname(vim.fs.dirname(real))
end

local ROOT = vim.fn.stdpath "data" .. "/lazy"
local SITE = vim.fn.stdpath "data" .. "/site"

--------------------------------------------------------------- lock の読み込み

local function read_lock_at(rev)
  local ok, out = git(repo, { "show", rev .. ":" .. LOCK })
  if not ok then
    die(("cannot read %s at %s"):format(LOCK, rev))
  end
  local ok2, decoded = pcall(vim.json.decode, out)
  if not ok2 then
    die(("cannot parse %s at %s: %s"):format(LOCK, rev, decoded))
  end
  return decoded
end

local function read_lock_worktree()
  local path = repo .. "/" .. LOCK
  local fh = io.open(path, "r") or die("cannot open " .. path)
  local raw = fh:read "*a"
  fh:close()
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok then
    die(("cannot parse %s: %s"):format(path, decoded))
  end
  return decoded
end

local old_lock = read_lock_at(ref)
local new_lock = read_lock_worktree()

------------------------------------------------------------------ 解析の部品

---@param tag string?
---@return { major: integer, minor: integer, patch: integer }?
local function semver(tag)
  if not tag then
    return nil
  end
  local maj, min, pat = tag:match "^v?(%d+)%.(%d+)%.(%d+)"
  if not maj then
    return nil
  end
  return { major = tonumber(maj), minor = tonumber(min), patch = tonumber(pat) }
end

-- そのコミットを指すタグ。version = "*" 指定のプラグインは commit hash しか
-- lock に載らないので、タグを引き直さないとメジャーバージョンの跳ねが見えない。
---@return { name: string, exact: boolean }?
local function tag_of(dir, sha)
  local exact = git_line(dir, { "tag", "--points-at", sha })
  if exact then
    return { name = exact, exact = true }
  end
  local near = git_line(dir, { "describe", "--tags", "--abbrev=0", sha })
  if near then
    return { name = near, exact = false }
  end
  return nil
end

-- semver 的に「壊れうる」上げ方か。0.x は minor がメジャー相当なのでそこも見る。
local function breaking_bump(old_tag, new_tag)
  local o, n = semver(old_tag), semver(new_tag)
  if not o or not n then
    return false
  end
  if o.major ~= n.major then
    return true
  end
  return o.major == 0 and o.minor ~= n.minor
end

-- 新旧コミットの位置関係。fork 追従や upstream の force push で巻き戻ることが
-- あるので、素直に進んだのかどうかを必ず確認する。
---@return "forward"|"downgrade"|"diverged"|"unknown", table
local function direction(dir, old_sha, new_sha)
  local have_old = git(dir, { "cat-file", "-e", old_sha .. "^{commit}" })
  local have_new = git(dir, { "cat-file", "-e", new_sha .. "^{commit}" })
  if not have_old or not have_new then
    return "unknown", { old_missing = not have_old, new_missing = not have_new }
  end
  if git(dir, { "merge-base", "--is-ancestor", old_sha, new_sha }) then
    return "forward", {}
  end
  if git(dir, { "merge-base", "--is-ancestor", new_sha, old_sha }) then
    return "downgrade", {}
  end
  return "diverged", {}
end

-- Conventional Commits の `!` と本文の BREAKING CHANGE を拾う。慣習に従って
-- いないプラグインは取りこぼすが、それは Claude 側が本文を読んで補う。
local function is_breaking(subject, body)
  if subject:match "^[%w][%w%-%.]*%b()!:" or subject:match "^[%w][%w%-%.]*!:" then
    return true
  end
  return body:find("BREAKING CHANGE", 1, true) ~= nil or body:find("BREAKING-CHANGE", 1, true) ~= nil
end

---@return table[]? commits, integer total
local function commits_between(dir, from, to)
  local ok, out = git(dir, {
    "log",
    "--no-merges",
    "--format=%H" .. FS .. "%s" .. FS .. "%b" .. RS,
    from .. ".." .. to,
  })
  if not ok then
    return nil, 0
  end
  local all = {}
  for rec in out:gmatch("[^" .. RS .. "]+") do
    local sha, subject, body = rec:match("^%s*([^" .. FS .. "]*)" .. FS .. "([^" .. FS .. "]*)" .. FS .. "(.*)$")
    if sha and sha ~= "" then
      body = vim.trim(body or "")
      local breaking = is_breaking(subject, body)
      all[#all + 1] = {
        sha = sha:sub(1, 7),
        subject = subject,
        breaking = breaking or nil,
        -- 本文は breaking のときだけ載せる。全部載せると出力が膨らむわりに
        -- 読まれない。
        body = breaking and body ~= "" and body or nil,
      }
    end
  end
  local total = #all
  if total <= MAX_COMMITS then
    return all, total
  end
  -- 溢れる場合は breaking を優先して残す。件数の情報は total で伝わる。
  local kept, seen = {}, {}
  for _, c in ipairs(all) do
    if c.breaking then
      kept[#kept + 1] = c
      seen[c.sha] = true
    end
  end
  for _, c in ipairs(all) do
    if #kept >= MAX_COMMITS then
      break
    end
    if not seen[c.sha] then
      kept[#kept + 1] = c
    end
  end
  return kept, total
end

---@return string? slug, string? url
local function origin(dir)
  local url = git_line(dir, { "remote", "get-url", "origin" })
  if not url then
    return nil, nil
  end
  local slug = url:match "github%.com[:/](.+)$"
  if slug then
    slug = slug:gsub("%.git$", "")
  end
  return slug, url
end

-- そのプラグインに言及している設定ファイル。破壊的変更が自分の設定に刺さるかを
-- 判断するとき、まずここを読めばいい。
local function config_refs(slug, name)
  -- 生成物・辞書は設定ではないので最初から外す。lock 自身も当然外す。
  local pathspec = { "--", ".config/nvim", ":!" .. LOCK, ":!.config/nvim/dict" }
  local function grep(pattern, word)
    local args = { "grep", "-l", "-F" }
    if word then
      args[#args + 1] = "-w"
    end
    vim.list_extend(args, { "-e", pattern })
    return git_lines(repo, vim.list_extend(args, pathspec))
  end

  -- "owner/repo" は誤爆しないので最優先。これで当たれば名前では引かない。
  if slug then
    local hits = grep(slug, false)
    if #hits > 0 then
      return hits
    end
  end
  -- slug で当たらないときだけ名前で引く。-w が無いと "ale" が "palette" に
  -- 当たる類の誤爆を大量に拾う (実際に 24 ファイル拾った)。
  return grep(name, true)
end

------------------------------------------------------------------ 差分を取る

local added, removed, changed = {}, {}, {}

for name, entry in pairs(new_lock) do
  local prev = old_lock[name]
  if not prev then
    added[#added + 1] = { name = name, commit = entry.commit, branch = entry.branch }
  elseif prev.commit ~= entry.commit or prev.branch ~= entry.branch then
    changed[#changed + 1] = { name = name, prev = prev, curr = entry }
  end
end

for name, entry in pairs(old_lock) do
  if not new_lock[name] then
    removed[#removed + 1] = { name = name, commit = entry.commit, branch = entry.branch }
  end
end

local function by_name(a, b)
  return a.name:lower() < b.name:lower()
end
table.sort(added, by_name)
table.sort(removed, by_name)
table.sort(changed, by_name)

------------------------------------------------------- プラグインごとに詳しく見る

local report = {}

for _, c in ipairs(changed) do
  local dir = ROOT .. "/" .. c.name
  local item = {
    name = c.name,
    old = c.prev.commit:sub(1, 7),
    new = c.curr.commit:sub(1, 7),
    old_full = c.prev.commit,
    new_full = c.curr.commit,
    branch = c.curr.branch,
  }

  if c.prev.branch ~= c.curr.branch then
    item.branch_changed = { from = c.prev.branch, to = c.curr.branch }
  end
  -- 既定ブランチ以外を追いかけているものは、upstream の force push や
  -- ブランチ削除で静かに壊れる。目立たせておく。
  if c.curr.branch ~= "main" and c.curr.branch ~= "master" then
    item.tracking_branch = true
  end

  if not vim.uv.fs_stat(dir) then
    item.error = "clone not found: " .. dir
  else
    local slug, url = origin(dir)
    item.slug = slug
    item.url = url

    local dir_kind, detail = direction(dir, c.prev.commit, c.curr.commit)
    item.direction = dir_kind
    if next(detail) then
      item.direction_detail = detail
    end

    local old_tag = tag_of(dir, c.prev.commit)
    local new_tag = tag_of(dir, c.curr.commit)
    -- 新旧とも「近傍タグが同じ」= タグは動いていない。version 追従ではない
    -- プラグインで毎回出ると邪魔なだけなので落とす。
    local tag_moved = (old_tag and old_tag.name) ~= (new_tag and new_tag.name)
    local tag_exact = (old_tag and old_tag.exact) or (new_tag and new_tag.exact)
    if (old_tag or new_tag) and (tag_moved or tag_exact) then
      item.tag = {
        from = old_tag and old_tag.name or nil,
        to = new_tag and new_tag.name or nil,
        from_exact = old_tag and old_tag.exact or nil,
        to_exact = new_tag and new_tag.exact or nil,
      }
      if breaking_bump(old_tag and old_tag.name, new_tag and new_tag.name) then
        item.major_bump = true
      end
    end

    if dir_kind == "forward" or dir_kind == "diverged" then
      local list, total = commits_between(dir, c.prev.commit, c.curr.commit)
      if list then
        item.commits = list
        item.commit_count = total
        item.truncated = total > #list or nil
        local breaking = 0
        for _, x in ipairs(list) do
          if x.breaking then
            breaking = breaking + 1
          end
        end
        item.breaking_count = breaking > 0 and breaking or nil
      end
    end

    item.config_refs = config_refs(slug, c.name)
  end

  report[#report + 1] = item
end

-------------------------------------------------------------- treesitter の状態

-- パーサは lazy-lock.json に一切載らない。grammar の revision は
-- nvim-treesitter 側の parsers.lua にピン留めされ、入っているものは
-- site/parser-info/<lang>.revision に記録される。この 2 つがずれている
-- = 再コンパイルが要る、という状態。
local function treesitter_state()
  local pfile = ROOT .. "/nvim-treesitter/lua/nvim-treesitter/parsers.lua"
  if not vim.uv.fs_stat(pfile) then
    return { error = "parsers.lua not found: " .. pfile }
  end
  local ok, parsers = pcall(dofile, pfile)
  if not ok then
    return { error = "cannot load parsers.lua: " .. tostring(parsers) }
  end

  local info = SITE .. "/parser-info"
  if not vim.uv.fs_stat(info) then
    return { installed = 0, stale = {}, note = "parser-info not found: " .. info }
  end

  local stale, unpinned, installed = {}, {}, 0
  for name, kind in vim.fs.dir(info) do
    local lang = name:match "^(.+)%.revision$"
    if lang and kind == "file" then
      installed = installed + 1
      local cur = vim.trim(table.concat(vim.fn.readfile(info .. "/" .. name), ""))
      local spec = parsers[lang]
      local pinned = spec and spec.install_info and spec.install_info.revision
      if not pinned then
        unpinned[#unpinned + 1] = lang
      elseif pinned ~= cur then
        stale[#stale + 1] = lang
      end
    end
  end
  table.sort(stale)
  table.sort(unpinned)

  -- site/queries/<lang> は「プラグインの runtime/queries/<lang> への symlink」
  -- として張られる。upstream が言語をレジストリから外すとき queries も一緒に
  -- 消すので、リンクだけが残って切れる。パーサ (.so) は無事なままなので
  -- 「読み込めるのにハイライトが出ない」という分かりにくい壊れ方をする。
  -- 実例: 2026-07-15 に tmux / hlsplaylist / muttrc / zathurarc がこうなった。
  local dangling = {}
  local qdir = SITE .. "/queries"
  if vim.uv.fs_stat(qdir) then
    for name, kind in vim.fs.dir(qdir) do
      if kind == "link" and not vim.uv.fs_stat(qdir .. "/" .. name) then
        dangling[#dangling + 1] = name
      end
    end
  end
  table.sort(dangling)

  return {
    installed = installed,
    stale = stale,
    stale_count = #stale,
    -- parsers.lua から消えた言語。放っておくと古い .so が残り続ける。
    unpinned = #unpinned > 0 and unpinned or nil,
    -- クエリのリンクが切れている言語。ハイライトが死んでいる。
    dangling_queries = #dangling > 0 and dangling or nil,
  }
end

--------------------------------------------------------------------- 出力

local ts_changed = false
for _, item in ipairs(report) do
  if item.name == "nvim-treesitter" then
    ts_changed = true
  end
end

local out = {
  ref = ref,
  repo = repo,
  summary = {
    changed = #report,
    added = #added,
    removed = #removed,
  },
  changed = report,
  added = added,
  removed = removed,
  treesitter = vim.tbl_extend("force", treesitter_state(), { plugin_changed = ts_changed }),
}

io.write(vim.json.encode(out), "\n")
