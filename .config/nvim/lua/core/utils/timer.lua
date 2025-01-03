---@class core.utils.timer.Time
---@field event string
---@field t integer

---@class core.utils.timer.Timer
---@field _start integer
---@field times core.utils.timer.Time[]
local M = { times = {} }

function M.start()
  M._start = vim.uv.hrtime()
  local group = vim.api.nvim_create_augroup("core-utils-timer", {})
  for _, event in ipairs {
    { "User", "DashboardLoaded" },
    { "User", "LazyDone" },
    { "User", "LazyVimStarted" },
    { "User", "SnacksDashboardOpened" },
    { "UIEnter" },
    { "User", "VeryLazy" },
    { "VimEnter" },
  } do
    vim.api.nvim_create_autocmd(event[1], {
      group = group,
      pattern = event[2],
      callback = function()
        M.track(event[2] or event[1])
      end,
    })
  end
end

function M.track(event)
  table.insert(M.times, { event = event, t = vim.uv.hrtime() - M._start })
end

function M.pp()
  local max_length = vim.iter(M.times):fold(0, function(a, b)
    return a > #b.event and a or #b.event
  end)
  local fmt = ("%%-%ds %%6.2f ms"):format(max_length)
  table.sort(M.times, function(a, b)
    return a.t < b.t
  end)
  vim.print(table.concat(
    vim
      .iter(M.times)
      :map(function(v)
        return fmt:format(v.event, v.t / 1e6)
      end)
      :totable(),
    "\n"
  ))
end

return setmetatable(M, { __call = M.start })
