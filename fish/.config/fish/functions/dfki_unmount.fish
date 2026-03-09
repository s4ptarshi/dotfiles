function dfki_unmount --description 'Forcefully unmount DFKI network drives'
    set -l mounts ~/mnt/netscratch_dir/ ~/mnt/home_dir/

    for dir in $mounts
        if mountpoint -q $dir
            echo "Attempting to unmount $dir..."
            # -f: Force unmount (useful for unreachable SSHFS)
            # -l: Lazy unmount (detaches the mount point immediately)
            sudo umount -fl $dir

            if test $status -eq 0
                echo "Successfully detached $dir"
            else
                echo "Failed to unmount $dir. Trying to kill hung sshfs processes..."
                # Kill any sshfs process specifically tied to this mount point
                set -l pid (pgrep -f "sshfs.*$dir")
                if test -n "$pid"
                    kill -9 $pid
                    echo "Killed process $pid"
                end
            end
        else
            echo "Directory $dir is not currently mounted."
        end
    end
end
