-- local dein_dir = vim.env.HOME .. '/.cache/dein'
local dein_dir = vim.env.HOME .. "/test/.cache/dein"
local dein_repo_dir = dein_dir .. "/repos/github.com/Shougo/dein.vim"

if vim.o.runtimepath:find("/dein.vim", 1, true) == nil then
  if fn.isdirectory(dein_repo_dir) == 0 then
    os.execute("git clone https://github.com/Shougo/dein.vim " .. dein_repo_dir)
  end
  vim.o.runtimepath = fn.fnamemodify(dein_repo_dir, ":p") .. "," .. vim.o.runtimepath
end

vim.g["dein#install_progress_type"] = "title"
vim.g["dein#enable_notification"] = 1

if fn["dein#load_state"](dein_dir) == 1 then
  local base = vim.env.HOME .. "/test/nvim/dein/"
  local toml = {
    { name = base .. "default.toml", lazy = 0 },
    -- {name = base .. 'nvim-lua.toml',    lazy = 0},
    -- {name = base .. 'lazy.toml',        lazy = 1},
    -- {name = base .. 'denite_lazy.toml', lazy = 1},
  }
  local names = {}
  local n = 0
  for _, v in pairs(toml) do
    n = n + 1
    names[n] = v.name
  end
  fn["dein#begin"](dein_dir, names)
  for _, v in pairs(toml) do
    fn["dein#load_toml"](v.name, v.lazy)
    fn["dein#end"]()
    fn["dein#save_state"]()
  end
end

if fn["dein#check_install"]() == 1 then
  fn["dein#install"]()
end

-- TODO: hack for filetype
vim.g.did_load_filetypes = 1
vim.cmd "filetype plugin indent on"
