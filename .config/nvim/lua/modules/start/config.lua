return {
  notify = function()
    local api = require("core.utils").api
    vim.opt.termguicolors = true
    local notify = require "notify"
    notify.setup {
      render = "minimal",
      background_colour = "#3b4252",
      level = "trace",
      on_open = function(win)
        api.win_set_config(win, { focusable = false })
      end,
    }
    vim.notify = notify
  end,

  fugitive = function()
    local keymap = vim.keymap
    keymap.set("n", "git", [[<Cmd>Git<CR>]])
    keymap.set("n", "g<Space>", [[<Cmd>Git<CR>]])
    keymap.set("n", "d<", [[<Cmd>diffget //2<CR>]])
    keymap.set("n", "d>", [[<Cmd>diffget //3<CR>]])
    keymap.set("n", "gs", [[<Cmd>Gstatus<CR>]])
  end,

  unimpaired = function()
    local keymap = vim.keymap
    keymap.set("n", "[w", [[<Cmd>colder<CR>]])
    keymap.set("n", "]w", [[<Cmd>cnewer<CR>]])
    keymap.set("n", "[O", [[<Cmd>lopen<CR>]])
    keymap.set("n", "]O", [[<Cmd>lclose<CR>]])
  end,

  visual_eof = function()
    local api = require("core.utils").api
    api.create_autocmd("ColorScheme", {
      group = api.create_augroup("nord_visual_eof", {}),
      pattern = "nord",
      callback = function()
        api.set_hl(0, "VisualEOL", { fg = "#a3be8c" })
        api.set_hl(0, "VisualNoEOL", { fg = "#bf616a" })
      end,
    })
    require("visual-eof").setup {
      text_EOL = " ",
      text_NOEOL = " ",
      ft_ng = {
        "FTerm",
        "denite",
        "denite-filter",
        "fugitive.*",
        "git.*",
        "packer",
      },
      buf_filter = function(bufnr)
        return api.buf_get_option(bufnr, "buftype") == ""
      end,
    }
  end,

  cellwidths = {
    config = function()
      --[[
      local function measure(name, f)
        local s = os.clock()
        f()
        vim.notify(("%s took %f ms"):format(name, (os.clock() - s) * 1000))
      end
      ]]

      vim.opt.listchars = {
        tab = "▓░",
        trail = "↔",
        eol = "⏎",
        extends = "→",
        precedes = "←",
        nbsp = "␣",
      }
      vim.opt.fillchars = {
        diff = "░",
        eob = "‣",
        fold = "░",
        foldopen = "▾",
        foldsep = "│",
        foldclose = "▸",
      }
      require("cellwidths").setup {
        --name = "default",
        name = "user/custom",
        --log_level = "DEBUG",
        ---@param cw cellwidths
        fallback = function(cw)
          cw.add {
            { 0x2103, 0x2103, 2 }, -- ℃
            { 0x2121, 0x2121, 2 }, -- ℡
            { 0x212b, 0x212b, 2 }, -- Å
            { 0x2160, 0x216b, 2 }, -- Ⅰ..Ⅻ
            { 0x2170, 0x2179, 2 }, -- ⅰ..ⅹ
            { 0x21d2, 0x21d2, 2 }, -- ⇒
            { 0x21d4, 0x21d4, 2 }, -- ⇔
            { 0x2200, 0x2200, 2 }, -- ∀
            { 0x2203, 0x2203, 2 }, -- ∃
            { 0x2207, 0x2208, 2 }, -- ∇..∈
            { 0x220b, 0x220b, 2 }, -- ∋
            { 0x221d, 0x221d, 2 }, -- ∝
            { 0x221f, 0x2220, 2 }, -- ∟..∠
            { 0x2227, 0x222a, 2 }, -- ∧..∪
            { 0x222c, 0x2235, 2 }, -- ∬..∵
            { 0x223d, 0x223d, 2 }, -- ∽
            { 0x2252, 0x2252, 2 }, -- ≒
            { 0x2261, 0x2261, 2 }, -- ≡
            { 0x2266, 0x226b, 2 }, -- ≦..≫
            { 0x2282, 0x2283, 2 }, -- ⊂..⊃
            { 0x2286, 0x2287, 2 }, -- ⊆..⊇
            { 0x22a5, 0x22a5, 2 }, -- ⊥
            { 0x22bf, 0x22bf, 2 }, -- ⊿
            { 0x2312, 0x2312, 2 }, -- ⌒
            { 0x23cf, 0x23cf, 2 }, -- ⏏
            { 0x2469, 0x24e9, 2 }, -- ⑩..ⓩ
            { 0x24eb, 0x24fe, 2 }, -- ⓫..⓾
            { 0x25b3, 0x25b3, 2 }, -- △
            { 0x25b7, 0x25b7, 2 }, -- ▷
            { 0x25bd, 0x25bd, 2 }, -- ▽
            { 0x25c1, 0x25c1, 2 }, -- ◁
            { 0x25c6, 0x25c7, 2 }, -- ◆..◇
            { 0x25d9, 0x25d9, 2 }, -- ◙
            { 0x2600, 0x260e, 2 }, -- ☀..☎
            { 0x2640, 0x2665, 2 }, -- ♀..♥
            { 0x2667, 0x2668, 2 }, -- ♧..♨
            { 0x266a, 0x266a, 2 }, -- ♪
            { 0x266d, 0x266d, 2 }, -- ♭
            { 0x266f, 0x266f, 2 }, -- ♯
            { 0x2714, 0x2714, 2 }, -- ✔
            { 0x2716, 0x2716, 2 }, -- ✖
            { 0x271d, 0x271d, 2 }, -- ✝
            { 0x2776, 0x277f, 2 }, -- ❶..❿

            { 0xe000, 0xe008, 2 }, --  . -- pomicons
            { 0xe0a0, 0xe0a3, 1 }, -- .. -- Powerline Symbols
            { 0xe0b0, 0xe0b3, 1 }, -- .. -- Powerline Symbols
            { 0xe0b8, 0xe0d4, 2 }, -- .. -- Powerline Extra Symbols
            { 0xe200, 0xe2a9, 2 }, -- .. -- Font Awesome Extension
            { 0xf000, 0xf2e0, 2 }, -- .. -- Font Awesome
            --{ 0x23fb, 0x23fe, 2 }, -- ⏻ .. ⏾- Power Symbols
            { 0x2b58, 0x2b58, 2 }, -- ⭘  --- Power Symbols
            { 0xf500, 0xf6d4, 2 }, -- .. -- Material
            { 0xf6d9, 0xf8fe, 2 }, -- .. -- Material
            { 0xe800, 0xec46, 2 }, -- .. -- Material
            { 0xff6d5, 0xff6d8, 2 }, -- 󿛕..󿛘 -- Material
            { 0xff8ff, 0xff8ff, 2 }, -- 󿣿 -- Material
            { 0xe300, 0xe338, 2 }, -- .. -- Weather Icons
            { 0xe33a, 0xe33d, 2 }, -- .. -- Weather Icons
            { 0xe342, 0xe343, 2 }, -- .. -- Weather Icons
            { 0xe346, 0xe346, 2 }, --  -- Weather Icons
            { 0xe34b, 0xe34d, 2 }, -- .. -- Weather Icons
            { 0xe351, 0xe351, 2 }, --  -- Weather Icons
            { 0xe354, 0xe368, 2 }, -- .. -- Weather Icons
            { 0xe36a, 0xe36b, 2 }, -- .. -- Weather Icons
            { 0xe36d, 0xe37e, 2 }, -- .. -- Weather Icons
            { 0xe381, 0xe3c3, 2 }, -- .. -- Weather Icons
            { 0xe3c8, 0xe3e3, 2 }, -- .. -- Weather Icons
            { 0xe5fa, 0xe62e, 2 }, -- .. -- Seti-UI + Custom
            { 0xe700, 0xe7c5, 2 }, -- .. -- Seti-UI + Custom
            { 0xf300, 0xf31c, 2 }, -- .. -- Font Logos
            { 0xf400, 0xf4a9, 2 }, -- .. -- Octicons
            { 0x2665, 0x2665, 2 }, -- ♥ -- Octicons
            { 0x26a1, 0x26a1, 2 }, -- ⚡ -- Octicons
            { 0xfea60, 0xfebeb, 2 }, -- 󾩠..󾯫 -- Codicons

            { 0xf0000, 0xf0000, 2 }, -- 󰀀
          }
        end,
      }
    end,
    run = function()
      require("cellwidths").remove "user/custom"
    end,
  },
}
