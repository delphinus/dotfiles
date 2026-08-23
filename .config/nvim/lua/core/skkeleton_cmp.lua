local M = {}

local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

---@async
---@param cmds string[][]
---@return string[]
local function async_systems(cmds)
  local async = require "plenary.async"
  local async_system = async.wrap(vim.system, 3)
  local results = vim.tbl_map(
    function(v)
      return v[1]
    end,
    async.util.join(vim.tbl_map(function(cmd)
      return function()
        return async_system(cmd)
      end
    end, cmds))
  ) --[[@as vim.SystemCompleted[] ]]
  local stdouts = {}
  for j, job in ipairs(results) do
    if job.code ~= 0 then
      vim.notify(
        ("command execution failed => cmd: %s, err => %s"):format(cmds[j][1], job.stderr),
        vim.log.levels.ERROR
      )
    end
    table.insert(stdouts, job.stdout or "")
  end
  return stdouts
end

---@async
---@param val number
local function async_karabiner(val)
  async_systems { { karabiner_cli, "--set-variables", vim.json.encode { neovim_in_insert_mode = val } } }
end

---@param f async function
---@return function
local function void(f)
  return function(...)
    require("plenary.async").void(f)(...)
  end
end

---@param val number
---@return async fun()
local function set_karabiner(val)
  return function()
    void(async_karabiner)(val)
  end
end

---@async
local function async_mode_karabiner()
  local is_in_insert = not not require("plenary.async").api.nvim_get_mode().mode:match "[icrR]"
  async_karabiner(is_in_insert and 1 or 0)
end

---@async
---@return number? いま実際に見られている kitty のウィンドウ id
local function kitty_focused_window()
  -- kitty は OS ウィンドウにも各ペインにも is_focused を持っている。前者が
  -- 「kitty が最前面のアプリか」を含んでいるので、WezTerm 版で要った osascript
  -- でのフロントモスト判定 (500ms ごとに 1 プロセス) が丸ごと不要になる。
  local results = async_systems { { "kitten", "@", "ls" } }
  local ok, os_windows = pcall(vim.json.decode, results[1])
  if not ok or type(os_windows) ~= "table" then
    return nil
  end
  for _, os_window in ipairs(os_windows) do
    if os_window.is_focused then
      for _, tab in ipairs(os_window.tabs or {}) do
        for _, window in ipairs(tab.windows or {}) do
          if window.is_focused then
            return window.id
          end
        end
      end
    end
  end
  return nil
end

function M.setup()
  if not vim.uv.fs_stat(karabiner_cli) then
    return
  end

  local group = vim.api.nvim_create_augroup("skkeleton_callbacks", {})

  vim.api.nvim_create_autocmd("User", {
    desc = "Set up skkeleton settings with nvim-cmp",
    group = group,
    pattern = "skkeleton-enable-pre",
    callback = function()
      local compare = require "cmp.config.compare"
      local types = require "cmp.types"
      require("cmp").setup.buffer {
        formatting = { fields = { types.cmp.ItemField.Abbr } },
        sources = { { name = "skkeleton", keyword_pattern = [=[\V\[ーぁ-ゔァ-ヴｦ-ﾟ]]=] } },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.recently_used,
            compare.order,
          },
        },
      }
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    desc = "Restore the default settings for nvim-cmp",
    group = group,
    pattern = "skkeleton-disable-pre",
    callback = function()
      require("cmp").setup.buffer {}
    end,
  })

  vim.api.nvim_create_autocmd(
    { "InsertEnter", "CmdlineEnter" },
    { group = group, callback = set_karabiner(1), desc = "Enable Karabiner-Elements settings for skkeleton" }
  )
  vim.api.nvim_create_autocmd(
    { "InsertLeave", "CmdlineLeave", "FocusLost" },
    { group = group, callback = set_karabiner(0), desc = "Disable Karabiner-Elements settings for skkeleton" }
  )
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = void(async_mode_karabiner),
    desc = "Enable/Disable Karabiner-Elements settings for skkeleton",
  })

  local running = false
  assert(vim.uv.new_timer()):start(
    500,
    500,
    vim.schedule_wrap(void(function()
      if running then
        return
      end
      running = true
      local window_var = vim.uv.os_getenv "KITTY_WINDOW_ID"
      if not window_var then
        running = false
        return
      end
      local my_window = tonumber(window_var, 10)
      local focused = kitty_focused_window()
      if not focused then
        -- kitty が最前面でない。IME の設定は落としておく。
        async_karabiner(0)
      elseif focused == my_window then
        async_mode_karabiner()
      end
      running = false
    end))
  )
end

return M
