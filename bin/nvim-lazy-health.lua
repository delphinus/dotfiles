-- 更新後の Neovim が正気かを、実際に起動して確かめる。
-- lock の差分をいくら読んでも「起動しなくなった」「パーサが壊れた」は
-- 分からないので、ここだけは動かして見る。
--
-- 呼ぶのは nvim-lazy-sync health。結果は $NVIM_LAZY_OUT に JSON で書く。
--
-- 中身を VimEnter に載せているのは、`-c` が VimEnter より前に走るため
-- (:help startup の 19 番が -c、22 番が VimEnter)。denops は VimEnter で
-- サーバを起こすので、-c の中で待っても必ず "stopped" になる。
--
-- ファイルは開かない。BufReadPost で nvim-lspconfig が起き、その config が
-- mason-tool-installer の check_install() を呼ぶため、開いた瞬間に LSP の
-- インストールが走り出す。すぐ落とすプロセスでそれを始めると中途半端な
-- 状態を残しかねない。
--
-- env:
--   NVIM_LAZY_OUT             結果 JSON の書き出し先 (必須)
--   NVIM_LAZY_DENOPS_TIMEOUT  denops の起動待ち ms (既定 60000)

local out_path = vim.env.NVIM_LAZY_OUT
if not out_path or out_path == "" then
  io.stderr:write "nvim-lazy-health: NVIM_LAZY_OUT is required\n"
  vim.cmd "cquit 2"
end

local PARSER_DIR = vim.fn.stdpath "data" .. "/site/parser"

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local result = {}

    -- 1. denops。skkeleton がこの上に乗っているので、死んでいると SKK が
    --    丸ごと使えない。wait() は -2 (未起動) / -1 (timeout) を返す。
    do
      local timeout = tonumber(vim.env.NVIM_LAZY_DENOPS_TIMEOUT) or 60000
      local ok, ret = pcall(vim.fn["denops#server#wait"], { timeout = timeout, silent = 1 })
      local status = "unavailable"
      local sok, s = pcall(vim.fn["denops#server#status"])
      if sok then
        status = s
      end
      result.denops = {
        ok = status == "running",
        status = status,
        wait_result = ok and ret or nil,
        error = not ok and tostring(ret) or nil,
      }
    end

    -- 2. パーサを 1 つずつ dlopen する。TSUpdate が途中で殺されたときに
    --    残る「中途半端な .so」は、読み込んで初めて分かる。
    do
      local langs = {}
      if vim.uv.fs_stat(PARSER_DIR) then
        for name, kind in vim.fs.dir(PARSER_DIR) do
          local lang = name:match "^(.+)%.so$"
          if lang and kind == "file" then
            langs[#langs + 1] = lang
          end
        end
      end
      table.sort(langs)

      local broken, no_highlights = {}, {}
      for _, lang in ipairs(langs) do
        local ok, res, err = pcall(vim.treesitter.language.add, lang)
        if not ok then
          broken[#broken + 1] = { lang = lang, error = tostring(res) }
        elseif res == false then
          broken[#broken + 1] = { lang = lang, error = tostring(err or "add() returned false") }
        else
          -- パーサが読めても highlights クエリが無ければ色は付かない。
          -- upstream が言語を落とすとき queries を道連れにするので、
          -- .so だけ残って静かにハイライトが死ぬ。'runtimepath' 込みで
          -- 解決するここでしか正確に判定できない。
          local okq, q = pcall(vim.treesitter.query.get, lang, "highlights")
          if not okq or not q then
            no_highlights[#no_highlights + 1] = lang
          end
        end
      end
      result.parsers = {
        ok = #broken == 0 and #no_highlights == 0,
        checked = #langs,
        broken = broken,
        no_highlights = no_highlights,
      }
    end

    -- 3. 起動中に notify されたエラー。lazy の読み込み失敗はここに出る。
    do
      local errs = {}
      local ok, Config = pcall(require, "lazy.core.config")
      if ok then
        for name, plugin in pairs(Config.plugins) do
          if plugin._.failed then
            errs[#errs + 1] = { plugin = name, error = tostring(plugin._.failed) }
          end
        end
      end
      table.sort(errs, function(a, b)
        return a.plugin < b.plugin
      end)
      result.plugins = { ok = #errs == 0, failed = errs }
    end

    vim.fn.writefile({ vim.json.encode(result) }, out_path)
    vim.cmd "qall!"
  end,
})
