function fish_prompt --description 'My prompt'
  set -l last_pipestatus $pipestatus
  set -l normal (set_color normal)

  # Color the prompt differently when we're root
  set -l color_cwd $fish_color_cwd
  set -l suffix (set_color red)❯(set_color yellow)❯(set_color green)❯$normal
  if contains -- $USER root toor
    if set -q fish_color_cwd_root
      set color_cwd $fish_color_cwd_root
    end
    set suffix '#'
  end

  # If we're running via SSH, change the host color.
  set -l color_host $fish_color_host
  if set -q SSH_TTY
    set color_host $fish_color_host_remote
  end

  # Write pipestatus
  set -l prompt_status (__fish_print_pipestatus " [" "]" "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)

  echo -n -s (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal $prompt_status $suffix " "
end
