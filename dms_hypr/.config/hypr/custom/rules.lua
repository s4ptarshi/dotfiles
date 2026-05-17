-- WINDOW RULES

hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, tile = true })

hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, rounding = 12 })

hl.window_rule({ match = { class = "^(gnome-control-center)$" }, tile = true })
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, tile = true })

hl.window_rule({ match = { class = "^(gnome-calculator)$" }, float = true })
hl.window_rule({ match = { class = "^(galculator)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })

hl.window_rule({ match = { class = "^(steam)$" }, float = true })
hl.window_rule({ match = { class = "^(xdg-desktop-portal)$" }, float = true })

hl.window_rule({ match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { class = "^(app\\.zen_browser\\.zen)$", title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { class = "^(zoom)$" }, float = true })

-- LAYER RULES

hl.layer_rule({
	match = { namespace = "dms.*" },
	blur = true,
	dim_around = false,
	ignore_alpha = 0,
})
