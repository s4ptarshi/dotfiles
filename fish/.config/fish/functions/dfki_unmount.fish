function dfki_unmount --description 'Forcefully unmount DFKI network drives'
    # Removed trailing slashes to prevent regex/path mismatch
    set -l mounts ~/mnt/netscratch_dir ~/mnt/home_dir

    for dir in $mounts
        echo "Attempting to force-detach $dir..."

        # 1. Bypass mount checks. Just execute the lazy unmount.
        # -u: unmount, -z: lazy (detaches immediately, closes network later)
        # We redirect errors to /dev/null so it doesn't spam if already unmounted
        fusermount -uz $dir 2>/dev/null

        # Fallback to sudo if fusermount wasn't the owner
        sudo umount -fl $dir 2>/dev/null

        # 2. Aggressively hunt down and kill the process
        # Using basename (e.g., 'netscratch_dir') ensures a match regardless of path formatting
        set -l base_name (basename $dir)
        set -l pids (pgrep -f "sshfs.*$base_name")

        if test -n "$pids"
            echo "Found hung SSHFS process for $base_name. Terminating..."
            # Iterate through pids in case there are multiple
            for p in $pids
                kill -9 $p
                echo "Killed PID $p"
            end
        end

        echo "Cleaned up $dir"
    end
end
