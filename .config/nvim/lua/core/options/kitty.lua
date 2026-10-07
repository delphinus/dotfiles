-- kitty のタブバーに、いま開いているバッファーのファイル名を出してもらう。
--
-- 'title' でウィンドウタイトルを書き換える手もあるが、noice.nvim と組み合わせると
-- タイトルがちらつくので切ってある (core.options.set 参照)。代わりに kitty の
-- user var で名前だけを渡し、~/.config/kitty/tab_bar.py の _title() が読む。
--
-- シェル統合 (OSC 133) には頼らないので、bin/kitty-open-file のように fish の
-- プロンプトを通らずに起動した nvim でも同じように出る。

if not vim.env.KITTY_WINDOW_ID then
  return
end

-- tab_bar.py の NVIM_FILE_VAR と揃えること。
local VAR = "nvim_file"

local last

---@param name string? nil なら user var を消す
local function send(name)
  if name == last then
    return
  end
  last = name
  if name then
    vim.api.nvim_ui_send(("\027]1337;SetUserVar=%s=%s\007"):format(VAR, vim.base64.encode(name)))
  else
    -- `=` を付けずに送ると kitty は user var を消す。
    vim.api.nvim_ui_send(("\027]1337;SetUserVar=%s\007"):format(VAR))
  end
end

local function update()
  -- 浮動ウィンドウ (telescope や noice) やファイルでないバッファーに入っただけで
  -- 名前を消すと、閉じて戻るまでタブ名がちらつく。直前のファイル名を出し続ける。
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return
  end
  local buftype = vim.bo.buftype
  if buftype ~= "" and buftype ~= "help" then
    return
  end
  local name = vim.fn.expand "%:t"
  -- [No Name] では普段のタブ名 (コマンド名) に戻す。
  send(name ~= "" and name or nil)
end

local group = vim.api.nvim_create_augroup("kitty_tab_title", {})
vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "VimResume" }, {
  group = group,
  callback = update,
  desc = "Tell kitty the current file name",
})
vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
  group = group,
  callback = function()
    send(nil)
  end,
  desc = "Clear the file name shown in kitty",
})
