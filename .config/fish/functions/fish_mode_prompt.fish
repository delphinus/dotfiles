function fish_mode_prompt --description "Display the mode for the prompt"
    # Do nothing if not in vi mode
    if test "$fish_key_bindings" = fish_vi_key_bindings
        or test "$fish_key_bindings" = fish_hybrid_key_bindings
        switch $fish_bind_mode
            case default
                set_color --bold cyan
                echo '[N]'
            case insert
                set_color --bold white
                echo '[I]'
            case replace_one
                set_color --bold yellow
                echo '[r]'
            case replace
                set_color --bold yellow
                echo '[R]'
            case visual
                set_color --bold green
                echo '[V]'
        end
        set_color normal
        echo -n ' '
    end
end
