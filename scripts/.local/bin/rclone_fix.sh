rclone bisync "gdrive:/" "$HOME/gdrive" \
    --filters-file "$HOME/.config/rclone/filters.txt" \
    --resync \
    --drive-skip-gdocs \
    --drive-skip-shortcuts \
    --drive-skip-dangling-shortcuts \
    --check-access \
    --fast-list \
    --verbose
