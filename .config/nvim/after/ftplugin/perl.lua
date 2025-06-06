vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4

local f = require "f_meta"
local perl_fold_text = f.perl_fold_text
  or f {
    "perl_fold_text",
    function()
      local re = vim.regex [[\v^\s*subtest\s*(['"])\zs.{-}\ze\1]]
      local start, finish = re:match_line(0, vim.v.foldstart - 1)
      local cases_part = ""
      local test_name = ""
      if start then
        test_name = fn.getline(vim.v.foldstart):sub(start + 1, finish)
        local cases = 0
        for i = vim.v.foldstart, vim.v.foldend - 1 do
          if re:match_line(0, i) then
            cases = cases + 1
          end
        end
        if cases > 0 then
          cases_part = (" (+ %d case%s)"):format(cases, cases > 1 and "s" or "")
        end
      end

      local level = #vim.v.folddashes
      if level <= 12 then
        level = fn.nr2char(0x2170 + level - 1) .. " "
      end
      local lines = vim.v.foldend - vim.v.foldstart + 1
      return ("%s %3d 行: %s%s"):format(level, lines, test_name, cases_part)
    end,
  }

local found
for p in vim.gsplit(vim.o.path, ",", true) do
  if p == "lib" then
    found = true
    break
  end
end
if not found then
  vim.o.path = "lib," .. vim.o.path
end

vim.cmd.setlocal("foldtext=" .. perl_fold_text:vim() .. "()")

-- HACK: Command to launch `perl` should be changed in accordance with its root dir
do
  local lines = vim.fn.readfile(vim.uv.os_homedir() .. "/.1password-perl-env")
  local env = vim.iter(lines):fold({}, function(a, b)
    local key, value = b:match "^([^=]+)=(.*)$"
    if key and value then
      a[key] = value
    end
    return a
  end)

  local path = vim.api.nvim_buf_get_name(0)
  local use_carmel = 0 < #vim.fs.find(".carmel/MySetup.pm", { upward = true, type = "file", path = path })

  vim.lsp.config("perlnavigator", {
    settings = {
      perlnavigator = {
        perlEnv = env,
        perlPath = use_carmel and "carmel" or "perl",
        perlParams = use_carmel and { "exec", "perl" } or {},
        includePaths = { "./lib", "./local/lib/perl5", "./t/lib" },
      },
    },
  })
end
