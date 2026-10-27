-- Shared eyeliner.nvim spec pieces reused by the main nvim config and the
-- nvim-dev/skkeleton sub-config (同じ作法は jab_shared.lua も参照)。
--
-- f/F/t/T を押したとき、その方向で f 一発で届く文字 (EyelinerPrimary) と
-- ; を何回か足せば届く文字 (EyelinerSecondary) に色を付ける。移動自体は
-- 組込みの f のままなので、; / , ・ドットリピート・カウントもそのまま使える。
-- 対象は既定の match = "[A-Za-z]" のみで、和字には目印が付かない。
--
-- eyeliner の setup() は呼ばず、require("eyeliner").highlight() だけを使う。
-- setup() は highlight_on_key のとき vim.on_key(cb, <バッファ番号>) を呼び、
-- 第 2 引数 (名前空間 ID) にバッファ番号を渡している。読み込んだ時点の
-- バッファ番号と同じ ID の名前空間で登録された別の on_key を上書きしてしまう。
-- 色付けの後片付け (次のキーで消す) は下の config で自前で行う。

local M = {}

-- highlight() で色を付けたバッファ。次に打鍵されたキーで消す。
local pending_buf

-- lazy.nvim の keys 用リスト。プラグインの default_keymaps は BufEnter ごとに
-- バッファローカルのマッピングを張るので遅延読み込みと噛み合わない。
-- 自前でグローバルに張る。
M.keys = vim
  .iter({ "f", "t", "F", "T" })
  :map(function(key)
    return {
      key,
      function()
        require("eyeliner").highlight { forward = key == "f" or key == "t" }
        pending_buf = vim.api.nvim_get_current_buf()
        return key
      end,
      mode = { "n", "x", "o" },
      expr = true,
    }
  end)
  :totable()

function M.config()
  require("eyeliner.config").opts.dim = true

  -- f の後の 1 キー (移動先の文字、または <Esc>) で色を消す。on_key は
  -- マッピングが返した f や lazy.nvim が打ち直す f でも呼ばれるが、そのときは
  -- typed が空なので、実際に打鍵されたキーだけを見る。
  local ns = vim.api.nvim_create_namespace "eyeliner"
  vim.on_key(function(_, typed)
    if pending_buf and typed and typed ~= "" then
      local buf = pending_buf
      pending_buf = nil
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        end
      end)
    end
  end, vim.api.nvim_create_namespace "eyeliner-shared")

  -- 配色ごとの色名に依存しないよう、既存の Diagnostic 系から色を借りる。
  local function set_hl()
    local function fg(name)
      return vim.api.nvim_get_hl(0, { name = name, link = false }).fg
    end
    vim.api.nvim_set_hl(0, "EyelinerPrimary", { fg = fg "DiagnosticWarn", bold = true, underline = true })
    vim.api.nvim_set_hl(0, "EyelinerSecondary", { fg = fg "DiagnosticInfo", underline = true })
    vim.api.nvim_set_hl(0, "EyelinerDimmed", { fg = fg "Comment" })
  end
  set_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("eyeliner-hl", {}),
    callback = set_hl,
  })
end

return M
