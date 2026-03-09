function fish_user_key_bindings
    # Initialize the default Vi bindings
    fish_vi_key_bindings
    # Visual Mode: press 'y' to copy selection
    bind -M visual y fish_clipboard_copy
    # Normal Mode: 'yy' to copy line, 'Y' to copy to end of line
    bind -M default yy fish_clipboard_copy
    bind -M default Y fish_clipboard_copy

    # Normal Mode: 'p' to paste
    bind -M default p fish_clipboard_paste
    for mode in insert default visual
        bind -M $mode \cf forward-char
    end
end
