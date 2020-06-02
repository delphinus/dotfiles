function fish_right_prompt
  set saved_status $status
  if test $saved_status != 0
    echo (set_color red) "✗ $saved_status "
  end
  set_color normal

  __git_info
end
