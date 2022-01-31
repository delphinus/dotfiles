return {
  { "LumaKernel/ddc-registers-words" },
  { "delphinus/ddc-tmux" },
  { "delphinus/ddc-ctags" },
  { "delphinus/ddc-shell-history" },
  { "delphinus/ddc-treesitter" },
  { "Shougo/ddc-around" },
  { "Shougo/ddc-cmdline-history" },
  { "Shougo/ddc-converter_remove_overlap" },
  { "Shougo/ddc-line" },
  { "Shougo/ddc-matcher_head" },
  --{'Shougo/ddc-nextword'},
  { "Shougo/ddc-nvim-lsp" },
  { "Shougo/ddc-rg" },
  { "Shougo/ddc-sorter_rank" },
  { "matsui54/ddc-buffer" },
  { "matsui54/ddc-converter_truncate" },
  --{'matsui54/ddc-filter_editdistance'},
  { "tani/ddc-fuzzy" },
  { "tani/ddc-git" },
  { "tani/ddc-oldfiles" },
  { "tani/ddc-path" },

  {
    "Shougo/pum.vim",
    config = function()
      fn["pum#set_option"] {
        winblend = 10,
      }
    end,
  },

  { "Shougo/neco-vim", opt = true },
  { "octaltree/cmp-look", opt = true },

  {
    "matsui54/denops-popup-preview.vim",
    opt = true,
    wants = { "denops.vim" },
    setup = function()
      vim.g.popup_preview_config = {
        winblend = 10,
      }
    end,
    config = function()
      fn["popup_preview#enable"]()
    end,
  },

  {
    "matsui54/denops-signature_help",
    opt = true,
    wants = { "denops.vim" },
    config = function()
      fn["signature_help#enable"]()
    end,
  },

  {
    --'vim-skk/skkeleton',
    "delphinus/skkeleton",
    branch = "feature/inform-mode-change-immediately",
    opt = true,
    requires = {
      {
        "delphinus/skkeleton_indicator.nvim",
        opt = true,
        config = function()
          vim.cmd [[
            hi SkkeletonIndicatorEiji guifg=#88c0d0 guibg=#2e3440 gui=bold
            hi SkkeletonIndicatorHira guifg=#2e3440 guibg=#a3be8c gui=bold
            hi SkkeletonIndicatorKata guifg=#2e3440 guibg=#ebcb8b gui=bold
            hi SkkeletonIndicatorHankata guifg=#2e3440 guibg=#b48ead gui=bold
            hi SkkeletonIndicatorZenkaku guifg=#2e3440 guibg=#88c0d0 gui=bold
          ]]
          require("skkeleton_indicator").setup()
        end,
      },
    },
    config = function()
      fn["skkeleton#config"] {
        globalJisyo = "~/Library/Application Support/AquaSKK/SKK-JISYO.L",
        userJisyo = "~/Library/Application Support/AquaSKK/skk-jisyo.utf8",
        markerHenkan = "□",
        eggLikeNewline = true,
        useSkkServer = true,
        immediatelyCancel = false,
        registerConvertResult = true,
      }
      fn["skkeleton#register_kanatable"]("rom", {
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
        ["/"] = { "・", "" },
        ["<s-q>"] = "henkanPoint",
      })
      -- Use these mappings in Karabiner-Elements
      vim.keymap.set({ "i", "c", "l" }, "<F10>", "<Plug>(skkeleton-disable)")
      vim.keymap.set({ "i", "c", "l" }, "<F13>", "<Plug>(skkeleton-enable)")
      vim.keymap.set({ "i", "c", "l" }, "<C-j>", "<Plug>(skkeleton-enable)")

      local Job = require "plenary.job"
      local karabiner_cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
      local function set_karabiner(val)
        return function()
          Job
            :new({
              command = karabiner_cli,
              args = {
                "--set-variables",
                ('{"neovim_in_insert_mode":%d}'):format(val),
              },
            })
            :start()
        end
      end

      local prev_buffer_config
      require("agrp").set {
        skkeleton_callbacks = {
          {
            "User",
            "skkeleton-enable-pre",
            function()
              prev_buffer_config = fn["ddc#custom#get_buffer"]()
              -- TODO: ddc-skkeleton does not support pum.vim now.
              fn["ddc#custom#patch_buffer"] {
                completionMenu = "native",
                sources = { "skkeleton" },
              }
            end,
          },
          {
            "User",
            "skkeleton-disable-pre",
            function()
              fn["ddc#custom#set_buffer"](prev_buffer_config)
            end,
          },
        },
        skkeleton_karabiner_elements = {
          { "InsertEnter,CmdlineEnter", "*", set_karabiner(1) },
          { "InsertLeave,CmdlineLeave,FocusLost", "*", set_karabiner(0) },
          {
            "FocusGained",
            "*",
            function()
              local val = fn.mode():match "[icrR]" and 1 or 0
              set_karabiner(val)()
            end,
          },
        },
      }
    end,
  },

  {
    "Shougo/ddc.vim",
    event = { "InsertEnter" },
    --keys = {{'n', ':'}},
    fn = {
      "ddc#custom#get_buffer",
      "ddc#custom#patch_global",
    },
    -- TODO: disable cmdline completion temporarily
    --[=[
    setup = function()
      -- TODO: rewrite with using Lua
      vim.cmd[[
        "nnoremap :       <Cmd>lua __enable_ddc_cmdline()<CR>:
        nnoremap :       <Cmd>call CommandlinePre()<CR>:

        function! CommandlinePre() abort
          " Overwrite sources
          let g:prev_buffer_config = ddc#custom#get_buffer()
          echo g:prev_buffer_config
          call ddc#custom#patch_buffer('sources', ['cmdline-history', 'necovim', 'around'])

          autocmd CmdlineLeave * ++once call CommandlinePost()

          " Enable command line completion
          call ddc#enable_cmdline_completion()
        endfunction
        function! CommandlinePost() abort
          " Restore sources
          call ddc#custom#set_buffer(g:prev_buffer_config)
        endfunction
      ]]
    end,
    ]=]

    wants = {
      "cmp-look",
      "denops-popup-preview.vim",
      "denops-signature_help",
      "denops.vim",
      "neco-vim",
      "skkeleton",
      "skkeleton_indicator.nvim",
    },

    config = function()
      fn["ddc#custom#patch_global"] {
        autoCompleteEvents = {
          "InsertEnter",
          "TextChangedI",
          "TextChangedP",
          "CmdlineChanged",
        },
        backspaceCompletion = true,
        completionMenu = "pum.vim",
        --keywordPattern = [[[_\w\d][-_\w\d]*]],
        --keywordPattern = [=[[-_\s\w\d]*]=],
        sources = {
          "nvim-lsp",
          "tmux",
          "shell-history",
          "ctags",
          "rg",
          "around",
          "buffer",
          --'line',
          "treesitter",
          "registers-words",
          --'nextword',
          "look",
        },
        sourceOptions = {
          _ = {
            ignoreCase = true,
            matchers = { "matcher_fuzzy" },
            sorters = { "sorter_fuzzy" },
            converters = {
              "converter_remove_overlap",
              "converter_truncate",
              "converter_fuzzy",
            },
          },
          around = { mark = "A" },
          buffer = { mark = "B" },
          ["cmdline-history"] = { mark = "H" },
          ctags = { mark = "C" },
          file = {
            mark = "F",
            isVolatile = true,
            forceCompletionPattern = [[\S/\S*]],
          },
          git = { mark = "G" },
          line = { mark = "LN" },
          look = {
            converters = { "loud" },
            isVolatile = true,
            matchers = {},
            mark = "LK",
            maxCandidates = 20,
          },
          necovim = { mark = "V" },
          --nextword = {mark = 'X'},
          ["nvim-lsp"] = {
            mark = "L",
            forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
          },
          oldfiles = { mark = "O" },
          path = { mark = "P", cmd = { "fd", "--max-depth", "5" } },
          ["registers-words"] = { mark = "R" },
          rg = { mark = "RG", minAutoCompleteLength = 4 },
          ["shell-history"] = {
            mark = "S",
            minKeywordLength = 4,
            maxKeywordLength = 50,
            maxCandidates = 20,
          },
          skkeleton = {
            mark = "SKK",
            matchers = { "skkeleton" },
            sorters = {},
            minAutoCompleteLength = 2,
          },
          treesitter = { mark = "TS" },
          tmux = { mark = "T" },
        },
        sourceParams = {
          around = { maxSize = 500 },
          buffer = { requireSameFiletype = false },
          look = { convertCase = true },
          ["nvim-lsp"] = { maxSize = 500 },
        },
        filterParams = {
          converter_fuzzy = { hlGroup = "Question" },
          converter_truncate = {
            maxAbbrWidth = 80,
            maxInfoWidth = 80,
            maxKindWidth = 10,
            maxMenuWidth = 40,
            ellipsis = "……",
          },
        },
      }
      fn["ddc#custom#patch_filetype"]({ "lua", "vim" }, {
        sources = {
          "nvim-lsp",
          "tmux",
          "ctags",
          "rg",
          "necovim",
          "around",
          "buffer",
          --'line',
          "treesitter",
          "registers-words",
          --'nextword',
          "look",
        },
        filterParams = {
          converter_truncate = {
            maxAbbrWidth = 80,
          },
        },
      })
      vim.keymap.set("i", "<Tab>", function()
        if fn["pum#visible"]() == 1 then
          fn["pum#map#insert_relative"](1)
          return ""
        end
        local col = fn.col "."
        if col <= 1 or fn.getline("."):sub(col - 1):match "%s" then
          return "<Tab>"
        end
        fn["ddc#manual_complete"]()
        return ""
      end, { expr = true })

      local function pum_insert(key, line)
        return function()
          if fn["pum#visible"]() then
            fn["pum#map#insert_relative"](line)
            return ""
          end
          return key
        end
      end

      vim.keymap.set("i", "<S-Tab>", pum_insert("<S-Tab>", -1), { expr = true })
      vim.keymap.set("i", "<C-n>", pum_insert("<C-n>", 1), { expr = true })
      vim.keymap.set("i", "<C-p>", pum_insert("<C-p>", -1), { expr = true })
      vim.keymap.set("i", "<C-y>", fn["pum#map#confirm"])
      vim.keymap.set("i", "<C-e>", fn["pum#map#cancel"])
      --vim.g['denops#debug'] = 1

      fn["ddc#enable"]()
    end,
  },
}
