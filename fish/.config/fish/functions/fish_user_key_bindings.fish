function fish_user_key_bindings
    # 1. Initialize the default Vi bindings first
    fish_vi_key_bindings

    # 2. Visual Mode: Copy selection, stop highlighting, drop back to normal mode
    bind -M visual -m default y 'fish_clipboard_copy; commandline -f end-selection'

    # 3. Normal Mode: 'yy' and 'Y' copy the current entire command line
    bind -M default yy fish_clipboard_copy
    bind -M default Y fish_clipboard_copy

    # 4. Normal Mode: 'p' to paste from system clipboard
    bind -M default p fish_clipboard_paste

    # 5. Global: Ctrl+F to move cursor forward
    for mode in insert default visual
        bind -M $mode \cf forward-char
    end
end

# Apply the bindings immediately
fish_user_key_bindings
