function fish_mode_prompt --description "Display the mode for the prompt"
    set -l last_pipestatus $pipestatus
    set -l normal (set_color normal)

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd

    # for mode prompt
    set -l suffix
    if test "$fish_key_bindings" = fish_vi_key_bindings
        or test "$fish_key_bindings" = fish_hybrid_key_bindings
        switch $fish_bind_mode
            case default
                set suffix (set_color red)❮(set_color yellow)❮(set_color green)❮$normal
            case insert
                set suffix (set_color red)❯(set_color yellow)❯(set_color green)❯$normal
            case replace_one
                set suffix (set_color yellow)❮r❯$normal
            case replace
                set suffix (set_color magenta)❮R❯$normal
            case visual
                set suffix (set_color green)❮V❯$normal
        end
    else
        set suffix (set_color red)❯(set_color yellow)❯(set_color green)❯$normal
    end

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

    if type -q env-info
        set env_info (env-info)
    else
        set env_info ''
    end

    echo -n -s (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal $env_info $prompt_status " " $suffix " "
end
