-- HACK: Command to launch `perl` should be changed in accordance with its root dir
--
-- OFFICE_ENVRC は ~/.env (1Password Environments) を読むプロセスにしか入らない。
-- 素のシェルから起動した nvim では未設定なので、そのまま vim.fs.normalize に
-- 渡すと "path: expected string, got nil" で mason-lspconfig の setup ごと落ちる。
-- 未設定・ファイル無しのときは perlEnv 無しで動かす。
local envrc = vim.env.OFFICE_ENVRC and vim.fs.normalize(vim.env.OFFICE_ENVRC)
local lines = envrc and vim.uv.fs_stat(envrc) and vim.fn.readfile(envrc) or {}
local env = vim.iter(lines):fold({}, function(a, b)
  local key, value = b:match "^export ([^=]+)='(.*)'$"
  if key and value then
    a[key] = value
  end
  return a
end)

-- Check if current buffer's project uses carmel
local bufpath = vim.api.nvim_buf_get_name(0)
local use_carmel = false
if bufpath ~= "" then
  local carmel_files = vim.fs.find(".carmel/MySetup.pm", { upward = true, type = "file", path = bufpath })
  use_carmel = #carmel_files > 0
end

-- Check for shebang in the first line
local top = vim.api.nvim_buf_get_lines(0, 0, 1, false)
local shebang = top[1] and top[1]:match "^#!%s*(.-)%s*$"

-- Determine perlPath and perlParams
local perlPath = shebang or (use_carmel and "carmel" or "perl")
local perlParams = (not shebang and use_carmel) and { "exec", "perl" } or {}

return {
  settings = {
    perlnavigator = {
      perlEnv = env,
      perlPath = perlPath,
      perlParams = perlParams,
      includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
    },
  },
}
