---@class core.lazy.Helptags
---@field after_doc string
---@field cache? table<string, string>
local M = {
  after_doc = vim.fs.joinpath(vim.fn.stdpath "config", "after", "doc"),
}

function M.generate_tags()
  vim.notify "Generating doc tags……"
  vim.system({ vim.fs.normalize "~/git/dotfiles/bin/merge-help-tags" }, {
    stdin = vim
      .iter(require("lazy").plugins())
      :map(function(v)
        return v.dir
      end)
      :totable(),
  }, function(obj)
    if obj.code ~= 0 then
      vim.notify(obj.stderr, vim.log.levels.ERROR)
      vim.notify("Failed to generate doc tags", vim.log.levels.ERROR)
    else
      vim.notify(obj.stdout, vim.log.levels.DEBUG)
      vim.notify "Done generating doc tags"
    end
  end)
end

---@param tag string
---@param lang? string
---@return string?
function M.filename_from_tag(tag, lang)
  if not M.cache then
    M.cache = vim.iter(vim.fs.dir(M.after_doc)):fold({}, function(a, name, _)
      vim.print(name)
      local lang_name = name == "tags" and "en" or name:match "^tags%-(..)$"
      local Path = require "plenary.path"
      vim.iter(Path:new(M.after_doc, name):readlines()):each(function(line)
        local fields = vim.split(line, "\t")
        a[fields[1] .. "@" .. lang_name] = fields[2]
      end)
      return a
    end)
  end
  return lang and M.cache[tag .. "@" .. lang] or M.cache[tag .. "@" .. vim.o.helplang] or M.cache[tag .. "@en"]
end

return M
