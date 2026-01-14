local utils = require "core.utils"
local lazy_require = require "lazy_require"

return {
  { "uga-rosa/cmp-skkeleton", event = { "InsertEnter", "CmdlineEnter" } },

  {
    "willelz/skk-tutorial.vim",
    cmd = { "SKKTutorialStart" },
    dependencies = { "denops.vim", "skkeleton" },
    config = function()
      utils.load_denops_plugin "skk-tutorial.vim"
      vim.wait(1000, function()
        return not not vim.api.nvim_get_commands({}).SKKTutorialStart
      end)
    end,
  },

  {
    "vim-skk/skkeleton",
    lazy = false,
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
      { "<C-x><C-o>", lazy_require("cmp").complete(), mode = { "i" }, desc = "Complete by nvim-cmp" },
    },
    dependencies = {
      "denops.vim",
    },

    init = function()
      local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
      local karabiner_exists = not not vim.uv.fs_stat(karabiner_cli)
      if karabiner_exists then
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

        ---@async
        ---@return number?
        local function wezterm_frontmost_pane()
          local results = async_systems {
            {
              "osascript",
              "-e",
              'tell application "System Events" to get the unix id of first process whose frontmost is true',
            },
            { "wezterm", "cli", "list-clients", "--format", "json" },
          }
          local frontmost_pid = tonumber(results[1], 10)
          local wezterms = vim.json.decode(results[2])
          for _, wezterm in ipairs(wezterms) do
            if wezterm.pid == frontmost_pid then
              return wezterm.focused_pane_id
            end
          end
        end

        assert(vim.uv.new_timer()):start(
          500,
          500,
          void(function()
            local pane_var = assert(vim.uv.os_getenv "WEZTERM_PANE")
            local wezterm_pane = tonumber(pane_var, 10)
            local pane = wezterm_frontmost_pane()
            if not pane then
              async_karabiner(0)
            elseif pane == wezterm_pane then
              async_mode_karabiner()
            end
          end)
        )
      end
    end,

    config = function()
      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/Documents/skk-jisyo.utf8",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "skk_server" }, -- use yaskkserv2
        skkServerResEnc = "utf-8",
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
        -- markerHenkan = "󰇆",
        -- markerHenkanSelect = "󱨉",
        -- markerHenkan = "󰽤",
        -- markerHenkanSelect = "󰽢",
        -- markerHenkan = "󰜌",
        -- markerHenkanSelect = "󰜋",
        -- markerHenkan = "󰝣",
        -- markerHenkanSelect = "󰄮",
      }
      vim.fn["skkeleton#register_kanatable"]("rom", {
        ["("] = { "（", "" },
        [")"] = { "）", "" },
        ["z "] = { "　", "" },
        ["z1"] = { "①", "" },
        ["z2"] = { "②", "" },
        ["z3"] = { "③", "" },
        ["z4"] = { "④", "" },
        ["z5"] = { "⑤", "" },
        ["z6"] = { "⑥", "" },
        ["z7"] = { "⑦", "" },
        ["z8"] = { "⑧", "" },
        ["z9"] = { "⑨", "" },
        ["<s-q>"] = "henkanPoint",
      })
    end,
  },
}
