local data_dir = fn.stdpath "data"

for _, p in ipairs {
  { "delphinus/agrp.nvim" },
  { "wbthomason/packer.nvim", opt = true },
} do
  local dir = p.opt and "opt" or "start"
  local package = p[1]
  local name = package:match "[^/]+$"
  local path = ("%s/site/pack/packer/%s/%s"):format(data_dir, dir, name)
  local st = loop.fs_stat(path)
  if not st or st.type ~= "directory" then
    os.execute(("git clone https://github.com/%s %s"):format(package, path))
  end
end
