sudo ln -sf $HOME/git-repos/dotfiles/asus/90-nkey.hwdb /etc/udev/hwdb.d/90-nkey.hwdb
sudo systemd-hwdb update
sudo udevadm trigger
