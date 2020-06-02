function fish_right_prompt
  set saved_status $status
  if test $saved_status != 0
    echo (set_color red) "✗ $saved_status "
  end
  set_color normal

  echo (set_color --bold cyan) (gcloud config get-value project 2>/dev/null) (set_color normal)
  __git_info
end
