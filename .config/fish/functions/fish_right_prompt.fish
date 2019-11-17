function fish_right_prompt
  set saved_status $status
  if test $saved_status != 0
    echo (set_color red) "✗ $saved_status"
  end
  set_color normal

  #__prompt_git_info
  set_color --bold green
  __fish_git_prompt
  set_color normal
end
