local _, _, api = require("core.utils").globals()
local events = { "BufNewFile", "BufRead" }

local group = api.create_augroup("filetypedetect", { clear = false })
local function g(opts)
  opts.group = group
  return opts
end

-- from $PACKER/opt/moonscript-vim/ftdetect/moon.vim
api.create_autocmd(events, g { pattern = "*.moon", command = "set filetype=moon" })
api.create_autocmd(events, {
  callback = function()
    if vim.regex([[^#!.*\<moon\>]]):match_line(0, 0) then
      vim.opt.filetype = "moon"
    end
  end,
})

-- from $PACKER/opt/vim-fish/ftdetect/fish.vim
api.create_autocmd(events, g { pattern = "*.fish", command = "setfiletype fish" })
api.create_autocmd("BufRead", g { pattern = "fish_funced.*", command = "setfiletype fish" })
api.create_autocmd(events, g { pattern = "~/.config/fish/fish_{read_,}history", command = "setfiletype yaml" })
api.create_autocmd(
  "BufRead",
  g {
    callback = function()
      if vim.regex([[\v^#!%(\f*/|/usr/bin/env\s*<)fish>]]):match_line(0, 0) then
        vim.opt.filetype = "fish"
      end
    end,
  }
)

-- from $PACKER/opt/vim-gitignore/ftdetect/gitignore.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/plantuml-syntax/ftdetect/plantuml.vim
api.create_autocmd(
  events,
  g {
    callback = function()
      if vim.fn.did_filetype() ~= 1 and vim.regex([[@startuml\>]]):match_line(0, 0) then
        vim.cmd.setfiletype "plantuml"
      end
    end,
  }
)
api.create_autocmd(
  events,
  g { pattern = { "*.pu", "*.uml", "*.plantuml", "*.puml", "*.iuml" }, command = "set filetype=plantuml" }
)

-- from $PACKER/opt/rust.vim/ftdetect/rust.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/skkdict.vim/ftdetect/skkdict.vim
api.create_autocmd(
  { "BufReadPost", "BufNewFile" },
  g { pattern = { ".skk-jisyo", "SKK-JISYO.*" }, command = "set filetype=skkdict" }
)

-- from $PACKER/opt/vim-protobuf/ftdetect/proto.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-pug/ftdetect/pug.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/swift.vim/ftdetect/swift.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-scala/ftdetect/scala.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-perl/ftdetect/mason-in-html.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-perl/ftdetect/perl11.vim
api.create_autocmd(
  "BufReadPost",
  g {
    pattern = { "*.pl", "*.pm", "*.t" },
    callback = function()
      -- NOTE: The logic in the original script reads the whole lines. This reads up to 100 lines due to speed up.
      local in_pod = false
      local lines = api.buf_get_lines(0, 0, 100, false)
      for i = 1, #lines do
        local line = lines[i]
        if vim.regex([[^=\w]]):match_str(line) then
          in_pod = true
          goto continue
        elseif vim.regex([[^=\%(end\|cut\)]]):match_str(line) then
          in_pod = false
          goto continue
        end
        if in_pod then
          goto continue
        end
        local code = line:gsub([[#.*]], "")
        if vim.regex([[^\s*$]]):match_str(code) then
          goto continue
        end
        if vim.regex([[^\s*\%(use\s\+\)\=v6\%(\.\d\%(\.\d\)\=\)\=;]]):match_str(line) then
          vim.opt.filetype = "perl6"
        elseif vim.regex [[^\s*\%(\%(my\|our\)\s\+\)\=\%(unit\s\+\)\=\(module\|class\|role\|enum\|grammar\)]] then
          vim.opt.filetype = "perl6"
        end
        ::continue::
      end
    end,
  }
)
api.create_autocmd({ "BufNew", "BufNewFile", "BufRead" }, g { pattern = { "*.nqp" }, command = "setf perl6" })

-- from $PACKER/opt/vim-teal/ftdetect/teal.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/ejs-syntax/ftdetect/ejs.vim
api.create_autocmd(events, g { pattern = { "*.ejs", "*._ejs" }, command = "set filetype=ejs" })
api.create_autocmd(
  events,
  g {
    callback = function()
      if vim.regex([[^#!.*\<ejs\>]]):match_line(0, 0) then
        vim.opt.filetype = "ejs"
      end
    end,
  }
)

-- from $PACKER/opt/vim-terraform/ftdetect/hcl.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-tmux/ftdetect/tmux.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vader.vim/ftdetect/vader.vim
api.create_autocmd(events, g { pattern = "*.vader", command = "set filetype=vader" })

-- from $PACKER/opt/vifm.vim/ftdetect/vifm-rename.vim
api.create_autocmd(events, g { pattern = "vifm.rename*", command = "set filetype=vifm-rename" })

-- from $PACKER/opt/vifm.vim/ftdetect/vifm.vim
api.create_autocmd(events, g { pattern = { "vifmrc", "*vifm/colors/*", "*.vifm" }, command = "set filetype=vifm" })

-- from $PACKER/opt/vim-toml/ftdetect/toml.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-vue/ftdetect/vue.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-coffee-script/ftdetect/coffee.vim
api.create_autocmd(
  events,
  g {
    pattern = { "*.coffee", "*Cakefile", "*.coffeekup", "*.ck", "*._coffee", "*.cson" },
    command = "set filetype=coffee",
  }
)
api.create_autocmd(
  events,
  g {
    callback = function()
      if vim.regex([[^#!.*\<coffee\>]]):match_line(0, 0) then
        vim.opt.filetype = "coffee"
      end
    end,
  }
)

-- from $PACKER/opt/vim-coffee-script/ftdetect/vim-literate-coffeescript.vim
api.create_autocmd(events, g { pattern = { "*.litcoffee", "*.coffee.md" }, command = "set filetype=litcoffee" })

-- from $PACKER/opt/vim-cpanfile/ftdetect/cpanfile.vim
api.create_autocmd(
  events,
  g {
    pattern = "cpanfile",
    callback = function()
      vim.opt.filetype = "cpanfile"
      vim.opt.syntax = "perl.cpanfile"
    end,
  }
)

-- from $PACKER/opt/wordpress.vim/ftdetect/php.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/wordpress.vim/ftdetect/txt.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/xslate-vim/ftdetect/xslate.vim
api.create_autocmd(events, g { pattern = { "*.tx" }, command = "set filetype=xslate" })
api.create_autocmd(
  events,
  g {
    pattern = { "*.html" },
    callback = function()
      if vim.fn.search [[^: ]] > 0 then
        vim.opt.filetype = "xslate"
      end
    end,
  }
)

-- from $PACKER/opt/vim-firestore/ftdetect/firestore.vim

api.create_autocmd(events, g { pattern = { "*.rules" }, command = "set filetype=firestore" })

-- from $PACKER/opt/vim-jsonnet/ftdetect/jsonnet.vim
-- NOTE: RUNTIME has this

-- from $PACKER/opt/vim-mustache-handlebars/ftdetect/handlebars.vim
api.create_autocmd(
  events,
  g { pattern = { "*.handlebars", "*.hdbs", "*.hbs", "*.hb" }, command = "set filetype=html.handlebars" }
)

-- from $PACKER/opt/vim-mustache-handlebars/ftdetect/mustache.vim
api.create_autocmd(
  events,
  g { pattern = { "*.mustache", "*.hogan", "*.hulk", "*.hjs" }, command = "set filetype=html.mustache" }
)

-- from $PACKER/opt/Vim-Jinja2-Syntax/ftdetect/jinja.vim
api.create_autocmd(
  events,
  g {
    pattern = { "*.html", "*.htm", "*.nunjucks", "*.nunjs", "*.njk" },
    callback = function()
      local lines = api.buf_get_lines(0, 0, 50, false)
      for i = 1, #lines do
        local line = lines[i]
        if
          vim.regex([[{{.*}}\|{%-\?\s*\(end.*\|extends\|block\|macro\|set\|if\|for\|include\|trans\)\>]]):match_str(
            line
          )
        then
          vim.opt.filetype = "jinja.html"
          return
        end
      end
    end,
  }
)
api.create_autocmd(events, g { pattern = { "*.jinja2", "*.j2", "*.jinja", "*.tera" }, command = "set filetype=jinja" })

-- from $PACKER/opt/vim-caddyfile/ftdetect/caddyfile.vim

api.create_autocmd(
  events,
  g { pattern = { "Caddyfile", "*.Caddyfile", "Caddyfile.*" }, command = "set filetype=caddyfile" }
)

-- from $PACKER/opt/bats.vim/ftdetect/bats.vim

api.create_autocmd(events, g { pattern = { "*.bats" }, command = "set filetype=bats" })
api.create_autocmd(
  events,
  g {
    callback = function()
      if vim.regex([[^#!.*\<bats\>]]):match_line(0, 0) then
        vim.opt.filetype = "bats"
      end
    end,
  }
)

-- from $PACKER/opt/ansible-vim/ftdetect/ansible.vim
api.create_autocmd(
  events,
  g {
    callback = function()
      local filepath = vim.fn.expand "%:p"
      local filename = vim.fs.basename(filepath)
      local function is_ansible()
        if
          vim.regex([[\v/(tasks|roles|handlers)/.*\.ya?ml$]]):match_str(filepath)
          or vim.regex([[\v/(group|host)_vars/]]):match_str(filepath)
        then
          return true
        end
        local re = vim.g.ansible_ftdetect_filename_regex or [[\v(playbook|site|main|local|requirements)\.ya?ml$]]
        if vim.regex(re):match_str(filename) then
          return true
        end
        local shebang = api.buf_get_lines(0, 0, 1, false)[1]
        if
          vim.regex([[^#!.*/bin/env\s\+ansible-playbook\>]]):match_str(shebang)
          or vim.regex([[^#!.*/bin/ansible-playbook\>]]):match_str(shebang)
        then
          return true
        end
      end

      if is_ansible() then
        vim.opt.filetype = "yaml.ansible"
      end
    end,
  }
)
api.create_autocmd(events, {
  pattern = "*.j2",
  callback = function()
    if vim.g.ansible_template_syntaxes then
      local filepath = vim.fn.expand "%:p"
      for _, syntax_name in ipairs(vim.g.ansible_template_syntaxes) do
        local syntax_string = [[\v/]] .. syntax_name[1]
        if vim.regex(syntax_string):match_str(filepath) then
          vim.opt.filetype = syntax_name[2] .. ".jinja2"
          return
        end
      end
    end
    vim.opt.filetype = "jinja2"
  end,
})
api.create_autocmd(events, g { pattern = "hosts", command = "set filetype=ansible_hosts" })

-- from $PACKER/opt/jsonc.vim/ftdetect/jsonc.vim
-- NOTE: RUNTIME has this
