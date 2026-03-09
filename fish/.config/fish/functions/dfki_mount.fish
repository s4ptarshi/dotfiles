function dfki_mount --description 'Mount DFKI netscratch and home with performance caching'
    # Updated performance flags for better compatibility
    # cache=yes: enables general caching
    # kernel_cache: uses the VFS cache for file data
    # cache_timeout: how many seconds to cache attributes/entries
    set -l opts "allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,idmap=user,kernel_cache,cache=yes,cache_timeout=60,attr_timeout=60"

    echo "Mounting netscratch..."
    sshfs bhattach@login2.pegasus.kl.dfki.de:/netscratch/bhattach/ ~/mnt/netscratch_dir/ -o $opts

    if test $status -eq 0
        echo "Mounting home..."
        sshfs bhattach@login2.pegasus.kl.dfki.de:/home/bhattach/ ~/mnt/home_dir/ -o $opts $argv
        echo "Successfully mounted DFKI drives."
    else
        echo "Failed to mount netscratch. Check your connection or password."
    end
end
