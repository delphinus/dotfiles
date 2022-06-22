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
