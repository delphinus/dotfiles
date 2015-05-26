setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

function! s:rspec_syntax_highlight()
  hi def link rubyRailsTestMethod Function
  syn keyword rubyRailsTestMethod describe context it its specify shared_context shared_examples shared_examples_for shared_context include_examples include_context it_should_behave_like it_behaves_like before after around subject fixtures controller_name helper_name scenario feature background given described_class
  syn match rubyRailsTestMethod '\<let\>!\='
  syn keyword rubyRailsTestMethod violated pending expect expect_any_instance_of allow allow_any_instance_of double instance_double mock mock_model stub_model xit
  syn match rubyRailsTestMethod '\.\@<!\<stub\>!\@!'
endfunction

autocmd Syntax ruby if ! RailsDetect() | call s:rspec_syntax_highlight() | endif
