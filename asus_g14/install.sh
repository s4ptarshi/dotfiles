sudo sp 90-nkey.hwdb /etc/udev/hwdb.d/
sudo systemd-hwdb update
sudo udevadm trigger
sudo reinstall-kernels && sudo dracut --force
stow anime-matrix
