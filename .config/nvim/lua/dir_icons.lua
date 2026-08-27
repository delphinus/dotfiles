-- nvim.dir (runtime の plugin/dir.lua) のディレクトリ一覧にアイコンを出す。
--
-- 0.13 の組み込みディレクトリビューアは filetype=directory のバッファに名前を
-- 並べるだけなので、nvim-web-devicons のアイコンを行頭に添える。inline の
-- virt_text なのでバッファのテキストは変えない。<CR> (<Plug>(nvim-dir-open)) は
-- 行のテキストをそのままエントリ名として解決するため、行を書き換える方式にすると
-- 存在しないパスを開いてしまう。
--
-- |dir-decorate| は decoration provider を勧めているが、ephemeral な extmark では
-- inline の virt_text が描画されない (実測: overlay と eol は出るが inline は無視
-- される。ヘルプの例が overlay と eol しか使っていないのはこのため)。アイコンは
-- 名前の前に置きたいので、代わりに |DirReadPost| で通常の extmark を張る。一覧の
-- 描画・再読み込みのたびに発火するので、ディレクトリを移動しても R で更新しても
-- 貼り直される。
--
-- 副次的に、行ごとではなく一覧ごとの処理になるぶん安い。
--
-- NOTE: DirReadPost のハンドラは登録順に走る。並べ替えや間引きを足すなら、行を
-- 書き換える処理はこれより先に登録すること (後から nvim_buf_set_lines で全行を
-- 差し替えると extmark がずれる)。

local M = {}

-- アイコン用の自前 namespace
local ns = vim.api.nvim_create_namespace "dir-icons"

-- ディレクトリのアイコン。get_icon は名前を拡張子として解釈するので、末尾の "/"
-- を落として渡すと lua/ が Lua ファイルのアイコンになってしまう。自前で分ける。
local dir_chunks = { { "󰉋 ", "Directory" } }

-- 行のテキスト -> virt_text のチャンク。テーブルの生成を一覧ごとに繰り返さない
-- ためのキャッシュで、エントリ名をキーにするので並べ替えにも効く。
---@type table<string, [string, string][]>
local cache = {}

-- nvim-web-devicons は最初にディレクトリを開くまで触らない。
---@type table?
local devicons

---@param name string 一覧の 1 行。ディレクトリは末尾が "/"
---@return [string, string][]
local function chunks(name)
  if name:sub(-1) == "/" then
    return dir_chunks
  end
  local cached = cache[name]
  if cached then
    return cached
  end
  devicons = devicons or require "nvim-web-devicons"
  local icon, hl = devicons.get_icon(name, nil, { default = true })
  local new = { { icon .. " ", hl } }
  cache[name] = new
  return new
end

---@return nil
function M.setup()
  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("dir-icons", {}),
    pattern = "DirReadPost",
    callback = function(args)
      local buf = args.buf
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      for row, name in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if name ~= "" then
          vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {
            virt_text = chunks(name),
            virt_text_pos = "inline",
          })
        end
      end
    end,
  })
end

return M
