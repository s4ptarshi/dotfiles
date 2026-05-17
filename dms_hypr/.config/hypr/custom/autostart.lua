-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Autostart necessary processes
hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")
	-- hl.exec_cmd("hyprpm reload -n")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user start hyprland-session.target")
end)
