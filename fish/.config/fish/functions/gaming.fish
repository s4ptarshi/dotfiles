function gaming --wraps='gamescope --backend drm -W 1920 -H 1080 -r 60 -e -- steam -gamepadui' --description 'alias gaming gamescope --backend drm -W 1920 -H 1080 -r 60 -e -- steam -gamepadui'
    gamescope --backend drm -W 1920 -H 1080 -r 60 -e -- steam -gamepadui $argv
end
