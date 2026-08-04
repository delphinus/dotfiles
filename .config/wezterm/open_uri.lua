---@type Wezterm
local wezterm = require "wezterm"
local const = require "const"

-- fish の単一引用符の中で意味を持つのはバックスラッシュと単一引用符だけ。
local function quote(s)
  local escaped = s:gsub("\\", "\\\\")
  escaped = escaped:gsub("'", "\\'")
  return "'" .. escaped .. "'"
end

-- Claude Code 等が OSC 8 で出す file:// リンクを、macOS の既定アプリではなく
-- 新しいタブの nvim で開く。fragment が `L42` / `42` の形ならその行に飛ぶ。
--
-- nvim を直接 spawn すると GUI から起動した WezTerm の貧弱な PATH をそのまま
-- 継承してしまい、deno (denops) や direnv が見つからず nvim が起動時に警告を
-- 出す。通常のタブと同じく fish 経由で起動して PATH を揃える。
--
-- 絶対パスではなく `nvim` を呼ぶことで、CSI u を有効にする nvim 関数
-- (~/.config/fish/functions/nvim.fish) も通常のタブと同じように通す。
--
-- file:// 以外 (https 等) は何も返さずに既定動作 (ブラウザ) へ委ねる。
return function(_)
  wezterm.on("open-uri", function(window, pane, uri)
    local url = wezterm.url.parse(uri)
    if not url or url.scheme ~= "file" then
      return
    end

    local cmd = { "nvim" }
    local line = url.fragment and url.fragment:match "^L?(%d+)$"
    if line then
      table.insert(cmd, "+" .. line)
    end
    table.insert(cmd, quote(url.file_path))

    window:perform_action(
      wezterm.action.SpawnCommandInNewTab { args = { const.fish, "-l", "-c", table.concat(cmd, " ") } },
      pane
    )
    -- 既定動作 (ブラウザ / 既定アプリで開く) を抑止する
    return false
  end)
end
