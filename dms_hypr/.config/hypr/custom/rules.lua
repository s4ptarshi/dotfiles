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
-- Browser extension popups report initial_title as "_crx_<extension_id>" (Bitwarden and every other
-- Chromium extension popup)
hl.window_rule({ match = { initial_title = "^_crx_" }, float = true })
hl.window_rule({ match = { class = "^(zoom)$" }, float = true })

-- Floating
hl.window_rule({ match = { title = "^(Open File)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(Open File)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^(Select a File)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(Select a File)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^(Choose wallpaper)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(Choose wallpaper)(.*)$" }, float = true })
hl.window_rule({
	match = { title = "^(Choose wallpaper)(.*)$" },
	size = { "(monitor_w*0.60)", "(monitor_h*0.65)" },
})
hl.window_rule({ match = { title = "^(Open Folder)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(Open Folder)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^(Save As)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(Save As)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^(Library)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(Library)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^(File Upload)(.*)$" }, center = true })
hl.window_rule({ match = { title = "^(File Upload)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^(.*)(wants to save)$" }, center = true })
hl.window_rule({ match = { title = "^(.*)(wants to save)$" }, float = true })
hl.window_rule({ match = { title = "^(.*)(wants to open)$" }, center = true })
hl.window_rule({ match = { title = "^(.*)(wants to open)$" }, float = true })
hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
hl.window_rule({ match = { class = "^(guifetch)$" }, float = true }) -- FlafyDev/guifetch
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({
	match = { class = "^(pavucontrol)$" },
	size = { "(monitor_w*0.45)", "(monitor_h*0.45)" },
})
hl.window_rule({ match = { class = "^(pavucontrol)$" }, center = true })
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({
	match = { class = "^(org.pulseaudio.pavucontrol)$" },
	size = { "(monitor_w*0.45)", "(monitor_h*0.45)" },
})
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({
	match = { class = "^(nm-connection-editor)$" },
	size = { "(monitor_w*0.45)", "(monitor_h*0.45)" },
})
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, center = true })
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = ".*Shell conflicts.*" }, float = true })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true })
hl.window_rule({
	match = { class = "org.freedesktop.impl.portal.desktop.kde" },
	float = true,
	center = true,
	size = { "(monitor_w*0.60)", "(monitor_h*0.65)" },
})
hl.window_rule({ match = { title = "^(Copying — Dolphin)$" }, move = { 40, 80 } })

-- Screen sharing
hl.window_rule({ match = { title = ".*is sharing (a window|your screen).*" }, float = true })
hl.window_rule({ match = { title = ".*is sharing (a window|your screen).*" }, pin = true })
hl.window_rule({
	match = { title = ".*is sharing (a window|your screen).*" },
	move = { "(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)" },
})

-- Picture-in-Picture
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, keep_aspect_ratio = true })
hl.window_rule({
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
})
hl.window_rule({
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
})
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true })
-- Disable blur for xwayland context menus
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })
-- LAYER RULES

hl.layer_rule({
	match = { namespace = "dms.*" },
	blur = true,
	dim_around = false,
	ignore_alpha = 0,
})

-- BRAVE POPUPS
-- Chromium gives every one of its windows the same class ("brave-browser"), does not mark a popup as
-- a child of the window that opened it, and titles popups just like the main window ("Sign in –
-- Google accounts - Brave"). What separates them is size: a Chromium popup is a fixed-size window
-- and keeps the size it asked for, the main window is resizable and takes whatever the layout gives
-- it. That size only survives while the window is floating — tiled, a popup is 948px wide like the
-- main window — so every Brave window is floated as it maps, and tiled again if it turns out to be
-- main-window sized.
local window_width = function(w)
	local size = w.size
	if type(size) == "table" then
		return size[1] or size.x
	end
	return size
end

-- Windows that must not be tiled back even if they open large
local known_popup = function(w)
	local title, initial = w.title or "", w.initial_title or ""
	return initial:find("^_crx_") ~= nil -- extension popup
		or title:find("DevTools") ~= nil
		or title:find("^[Pp]icture[%-%s]?[Ii]n[%-%s]?[Pp]icture") ~= nil
end

-- no_anim: the float -> tile above would otherwise show as a slide while the window opens
hl.window_rule({ match = { class = "^brave-browser$" }, float = true, no_anim = true })

hl.on("window.open", function(w)
	if w == nil or w.class ~= "brave-browser" or known_popup(w) then
		return
	end

	local monitor = w.monitor or hl.get_active_monitor()
	local width = window_width(w)
	-- The main window maps at the full width of its monitor, a popup stays far below that
	if type(width) ~= "number" or monitor == nil or width < monitor.width * 0.5 then
		return
	end
	hl.dispatch(hl.dsp.window.float({ window = "address:" .. w.address, action = "off" }))
end)
