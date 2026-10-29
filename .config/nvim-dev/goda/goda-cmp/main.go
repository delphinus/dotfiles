// Command goda-cmp-config is the goda-cmp configuration of nvim-dev/goda.
// goda_cmp#build() builds it into stdpath('cache')/goda-cmp.
package main

import (
	"github.com/Shougo/goda-cmp.vim/cmp"
	"github.com/Shougo/goda-cmp.vim/ext/filter/converterremoveoverlap"
	"github.com/Shougo/goda-cmp.vim/ext/filter/convertertruncateabbr"
	"github.com/Shougo/goda-cmp.vim/ext/filter/matcherhead"
	"github.com/Shougo/goda-cmp.vim/ext/filter/sorterlength"
	"github.com/Shougo/goda-cmp.vim/ext/filter/sorterrank"
	"github.com/Shougo/goda-cmp.vim/ext/filter/sortertext"
	"github.com/Shougo/goda-cmp.vim/ext/source/around"
	"github.com/Shougo/goda-cmp.vim/ext/source/buffer"
	"github.com/Shougo/goda-cmp.vim/ext/source/cmdline"
	"github.com/Shougo/goda-cmp.vim/ext/source/cmdlinehistory"
	"github.com/Shougo/goda-cmp.vim/ext/source/file"
	"github.com/Shougo/goda-cmp.vim/ext/source/lsp"
	"github.com/Shougo/goda-cmp.vim/ext/ui/native"
	"github.com/Shougo/goda-cmp.vim/ext/ui/pum"
)

func main() {
	b := cmp.New()

	b.AddUI(pum.New())
	b.AddUI(native.New())

	b.AddSource(around.New(around.Params{MinLength: 2}))
	b.AddSource(buffer.New(buffer.Params{}))
	b.AddSource(file.New(file.Params{}))
	b.AddSource(cmdline.New())
	b.AddSource(cmdlinehistory.New(cmdlinehistory.Params{}))
	b.AddSource(lsp.New(lsp.Params{
		Name:        "gopls",
		Command:     []string{"gopls"},
		Filetypes:   []string{"go", "gomod"},
		RootMarkers: []string{"go.work", "go.mod", ".git"},
	}))

	b.AddFilter(matcherhead.New(matcherhead.Params{}))
	b.AddFilter(sorterrank.New())
	b.AddFilter(sorterlength.New())
	b.AddFilter(sortertext.New())
	b.AddFilter(converterremoveoverlap.New())
	b.AddFilter(convertertruncateabbr.New(convertertruncateabbr.Params{MaxWidth: 40}))

	configure(b)
	b.Main()
}
