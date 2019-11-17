function fish_mode_prompt
	test $SSH_TTY
    and printf (set_color red)$USER(set_color brwhite)'@'(set_color yellow)(prompt_hostname)' '
  test "$USER" = 'root'
    and echo (set_color red)"#"

  # Main
  echo -n (set_color cyan)(prompt_pwd)
  echo ' '

  switch $fish_bind_mode
  case default
    echo (set_color red)'❮'(set_color yellow)'❮'(set_color green)'❮ '
  case insert
    echo (set_color green)'❯'(set_color yellow)'❯'(set_color red)'❯ '
  case replace_one
    echo (set_color yellow)'❯❯❯ '
  case visual
    echo (set_color brmagenta)'❯❯❯ '
  end

  set_color white
end
