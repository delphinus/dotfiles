package main

import "github.com/Shougo/goda-cmp.vim/cmp"

// configure holds the settings, like the patchGlobal calls of a ddc.ts.
// goda_cmp#patch_global() can change them from Vim script at run time.
func configure(b *cmp.Builder) {
	b.PatchGlobal(cmp.Config{
		UI:      "pum",
		Sources: []string{"around", "buffer", "file"},
		SourceOptions: map[string]cmp.SourceOption{
			"_": {
				Matchers:   []string{"matcherhead"},
				Sorters:    []string{"sorterrank"},
				Converters: []string{"converterremoveoverlap", "convertertruncateabbr"},
			},
			"around": {Mark: "A"},
			"buffer": {Mark: "B"},
			"file": {
				Mark:                   "F",
				IsVolatile:             new(true),
				ForceCompletionPattern: `\S/\S*`,
			},
			"cmdline":        {Mark: "cmd"},
			"cmdlinehistory": {Mark: "hist"},
		},
		CmdlineSources: map[string][]string{
			":": {"cmdline", "cmdlinehistory", "around"},
		},
		AutoCompleteDelay: new(10),
	})

	b.PatchFiletypes([]string{"go", "gomod"}, cmp.Config{
		Sources: []string{"gopls", "around", "buffer", "file"},
		SourceOptions: map[string]cmp.SourceOption{
			"gopls": {
				Mark:                   "LSP",
				ForceCompletionPattern: `\.\w*`,
				Matchers:               []string{},
				Sorters:                []string{"sortertext"},
			},
		},
	})
}
