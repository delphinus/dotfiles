-- Minimal config for md-render.nvim screencast (telescope + snacks)
-- Usage: NVIM_APPNAME=nvim-dev/md-render nvim

local shared = vim.env.HOME .. "/.local/share/nvim/lazy"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- skkeleton (Japanese SKK input) — borrowed from nvim-dev/skkeleton
  {
    "vim-denops/denops.vim",
    dir = shared .. "/denops.vim",
    init = function()
      vim.g["denops#server#deno_args"] = { "-q", "--no-lock", "--unstable-kv", "-A" }
    end,
  },
  {
    "vim-skk/skkeleton",
    dir = shared .. "/skkeleton",
    dependencies = {
      "vim-denops/denops.vim",
      { "delphinus/skkeleton_indicator.nvim", dir = shared .. "/skkeleton_indicator.nvim", opts = { fadeOutMs = 0 } },
    },
    lazy = false,
    keys = {
      -- Use these mappings in Karabiner-Elements
      { "<A-j>", "<Plug>(skkeleton-disable)", mode = { "i", "c", "l" } },
      { "<A-J>", "<Plug>(skkeleton-enable)", mode = { "i", "c", "l" } },
      { "<C-j>", "<Plug>(skkeleton-toggle)", mode = { "i", "c", "l" } },
    },
    config = function()
      -- skkeleton#map sets a buffer-local <nowait> <CR> that shadows blink's
      -- global mapping. Re-override after enable to delegate to blink when
      -- its menu is visible. Falls back to skkeleton's own handler when
      -- blink.cmp is not installed (as in this minimal config).
      local cr_group = vim.api.nvim_create_augroup("skkeleton_blink_cr", {})
      vim.api.nvim_create_autocmd("User", {
        group = cr_group,
        pattern = "skkeleton-enable-post",
        callback = function()
          vim.keymap.set("i", "<CR>", function()
            local ok, blink = pcall(require, "blink.cmp")
            if ok and blink.is_visible() then
              blink.select_and_accept()
              return
            end
            vim.fn["skkeleton#handle"]("handleKey", { key = vim.keycode "<CR>" })
          end, { buffer = true, nowait = true, desc = "blink + skkeleton <CR>" })
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = cr_group,
        pattern = "skkeleton-disable-pre",
        callback = function()
          pcall(vim.keymap.del, "i", "<CR>", { buffer = true })
        end,
      })

      vim.fn["skkeleton#config"] {
        userDictionary = vim.fs.normalize "~/Documents/skk-jisyo.utf8",
        eggLikeNewline = true,
        immediatelyCancel = false,
        registerConvertResult = true,
        sources = { "skk_server" },
        skkServerResEnc = "utf-8",
        databasePath = vim.fn.stdpath "data" .. "/skkeleton.db",
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

  -- telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", dir = vim.fn.expand "~/.local/share/nvim/lazy/plenary.nvim" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope md_render find_files<cr>", desc = "Find files (md-render)" },
      { "<leader>fg", "<cmd>Telescope md_render live_grep<cr>", desc = "Live grep (md-render)" },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
        layout_config = {
          preview_cutoff = 1,
          preview_height = 0.5,
        },
      },
    },
  },

  -- snacks.nvim
  {
    "folke/snacks.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/snacks.nvim",
    lazy = false,
    keys = {
      {
        "<leader>sf",
        function()
          Snacks.picker.files()
        end,
        desc = "Find files (snacks)",
      },
      {
        "<leader>sg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Grep (snacks)",
      },
    },
    opts = function()
      local preview = require("md-render.snacks").preview()
      return {
        picker = {
          sources = {
            files = { preview = preview },
            grep = { preview = preview },
          },
        },
      }
    end,
  },

  -- nvim-treesitter (parsers for code block highlighting in md-render)
  {
    "nvim-treesitter/nvim-treesitter",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      require("nvim-treesitter").install { "python", "lua", "bash", "ruby" }
    end,
  },

  -- md-render.nvim (local dev copy)
  {
    "delphinus/md-render.nvim",
    dir = vim.fn.expand "~/.local/share/nvim/lazy/md-render.nvim",
    dependencies = {
      { "delphinus/budoux.lua", dir = vim.fn.expand "~/.local/share/nvim/lazy/budoux.lua" },
    },
    cmd = { "MdRender", "MdRenderTab", "MdRenderToggle", "MdRenderAuto", "MdRenderPager", "MdRenderDemo" },
  },
}, {
  install = { missing = false },
  change_detection = { enabled = false },
})

vim.cmd.colorscheme "catppuccin"
