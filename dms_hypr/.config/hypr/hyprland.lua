---
local handle = io.popen("hostname")
local hostname = handle:read("*a"):gsub("%s+", "")
handle:close()
------------------
---- MONITORS ----
------------------
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
-- -- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- -- home
-- if hostname == "vivobook" then
-- 	hl.monitor({
-- 		output = "eDP-1",
-- 		mode = "2880x1800@90.00",
-- 		position = "0x0",
-- 		scale = "2",
-- 	})
-- 	hl.monitor({
-- 		output = "",
-- 		mode = "preferred",
-- 		position = "auto",
-- 		scale = "auto",
-- 	})
-- elseif hostname == "chadbook" then
-- 	hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60.000", position = "1920x214", vrr = 0, scale = "1.5" })
-- 	hl.monitor({ output = "eDP-1", mode = "1920x1080@120.003", position = "0x214", scale = "1", vrr = 1, bitdepth = 10 })
-- 	hl.monitor({ output = "DP-1", mode = "1680x1050@59.954", position = "4480x0", scale = "1", transform = 1, vrr = 0 })
-- 	hl.workspace_rule({ workspace = "m[DP-1]", layout_opts = { orientation = "top" } })
-- 	hl.workspace_rule({ workspace = "m[DP-1]", layout_opts = { direction = "down" } })
-- 	-- terminal room
-- 	-- hl.monitor({
-- 	-- 	output = "eDP-1",
-- 	-- 	mode = "1920x1080@120.003",
-- 	-- 	position = "auto-left",
-- 	-- 	scale = 1,
-- 	-- 	vrr = 1,
-- 	-- 	bitdepth = 10,
-- 	-- })
-- 	-- hl.monitor({ output = "DP-1", mode = "highres", position = "auto", scale = 1.25 })
-- 	--
-- 	hl.monitor({
-- 		output = "",
-- 		mode = "preferred",
-- 		position = "auto",
-- 		scale = "auto",
-- 	})
-- else
-- 	-- Fallback for any unknown devices
-- 	hl.monitor({
-- 		output = "",
-- 		mode = "preferred",
-- 		position = "auto",
-- 		scale = "auto",
-- 	})
-- end
-- terminal room
-- hl.monitor({
-- 	output = "eDP-1",
-- 	mode = "1920x1080@120.003",
-- 	position = "auto-left",
-- 	scale = 1,
-- 	vrr = 1,
-- 	bitdepth = 10,
-- })
-- hl.monitor({ output = "DP-1", mode = "highres", position = "auto", scale = 1.25 })

-- testing stdout
hl.config({
	debug = {
		-- enable_stdout_logs = true,
		disable_logs = false,
	},
})
local monitors = hl.get_monitors()
local has_dell = false

-- 1. Scan all connected monitors first to check for the Dell monitor
for _, monitor in ipairs(monitors) do
	-- Using just "U2724DE" is safer, as dots (.) have special meanings in Lua patterns
	if string.match(monitor.description, "U2724DE") then
		has_dell = true
		break -- Found it, we can stop looking
	end
end

-- 2. Apply the layout configuration ONCE based on the entire system state
if has_dell then
	-- Dell Layout (Not Rotated)
	hl.monitor({
		output = "eDP-1",
		mode = "1920x1080@120.003",
		position = "auto-left",
		scale = 1,
		vrr = 1,
		bitdepth = 10,
	})
	hl.monitor({ output = "DP-1", mode = "highres", position = "auto", scale = 1.25 })
	os.execute("dms ipc call wallpaper setFor eDP-1 ~/Pictures/goldy/goldy.png")
else
	-- Fallback Layout (Rotated Monitor Setup)
	hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60.000", position = "1920x214", vrr = 0, scale = "1.5" })
	hl.monitor({
		output = "eDP-1",
		mode = "1920x1080@120.003",
		position = "0x214",
		scale = "1",
		vrr = 1,
		bitdepth = 10,
	})
	hl.monitor({
		output = "DP-1",
		mode = "1680x1050@59.954",
		position = "4480x0",
		scale = "1",
		transform = 1,
		vrr = 0,
	})
	hl.workspace_rule({ workspace = "m[DP-1]", layout_opts = { orientation = "top" } })
	hl.workspace_rule({ workspace = "m[DP-1]", layout_opts = { direction = "down" } })
end

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 4,
		border_size = 2,

		col = {
			-- active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "scrolling",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 30,
			render_power = 5,
			offset = { 0.0, 5.0 },
			-- color = rgba(00000070),
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 3,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Fix xwayland blurring
hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slidefadevert" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slidefadevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "slidefadevert" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "master",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
		focus_fit_method = 1,
		column_width = 0.5, -- Default width of a column (0.1 to 1.0)
		direction = "right", -- Direction new windows appear (left/right/up/down)
	},
})

-- scrolling {
--         column_width = 0.5            # Default width of a column (0.1 to 1.0)
--         direction = right             # Direction new windows appear (left/right/up/down)
--         fullscreen_on_one_column = true # Single columns span the entire screen
--         focus_fit_method = 1          # 0 = center on focus, 1 = fit into view
-- }
----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
		disable_splash_rendering = true,
		vrr = 1,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "compose:ralt,caps:escape_shifted_capslock",
		kb_rules = "",
		repeat_rate = 50,
		repeat_delay = 240,

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
			drag_3fg = 1,
		},
	},

	cursor = {
		hide_on_key_press = true,
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.layer_rule({ match = { namespace = "^(quickshell)$" }, no_anim = true })

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- imports added at end to account for configs done above
require("custom.autostart")
require("custom.env")
require("custom.rules")
require("custom.general")
require("custom.workspaces")
require("custom.keybinds")
