sudo ln -srf 90-nkey.hwdb /etc/udev/hwdb.d/90-nkey.hwdb
sudo systemd-hwdb update
sudo udevadm trigger
stow anime-matrix
