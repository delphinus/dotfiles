local Tokyonight = {}

---@param colors table<string, string>
---@return nil
Tokyonight.set = function(colors)
  for k, v in pairs(colors) do
    if k == "set" then
      vim.notify "Colors has `set` in key. It is renamed to `_set`."
      Tokyonight._set = v
    else
      Tokyonight[k] = v
    end
  end
end

return Tokyonight
