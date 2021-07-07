local data_dir = vim.fn.stdpath'data'

for _, p in ipairs{
  {'delphinus/agrp.nvim'},
  {'delphinus/mappy.nvim'},
  {'wbthomason/packer.nvim', opt = true},
} do
  local dir = p.opt and 'opt' or 'start'
  local package = p[1]
  local name = package:match'[^/]+$'
  os.execute(
    ('git clone https://github.com/%s %s/site/pack/packer/%s/%s'):format(
      package, data_dir, dir, name
    )
  )
end
