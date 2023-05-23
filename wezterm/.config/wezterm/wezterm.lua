local wezterm = require("wezterm")
local keybinds = require("keybinds")
-- local mux = wezterm.mux
-- local act = wezterm.action

return {
	default_prog = { "/usr/bin/fish", "-l" },
	window_decorations = "RESIZE",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	inactive_pane_hsb = {
		saturation = 0.8,
		brightness = 0.7,
	},
	color_scheme = "Catppuccin Mocha",
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 15,
	-- config. window_background_opacity = 0.7,
	line_height = 1.2,
	use_dead_keys = false,
	scrollback_lines = 5000,
	adjust_window_size_when_changing_font_size = false,
	hide_tab_bar_if_only_one_tab = true,
	window_frame = {
		font = wezterm.font({ family = "Noto Sans", weight = "Regular" }),
	},
	window_background_opacity = 0.7,
	window_close_confirmation = "NeverPrompt",
	disable_default_key_bindings = true,
	-- visual_bell = {
	-- 	fade_in_function = "EaseIn",
	-- 	fade_in_duration_ms = 150,
	-- 	fade_out_function = "EaseOut",
	-- 	fade_out_duration_ms = 150,
	-- },
	-- separate <Tab> <C-i>
	enable_csi_u_key_encoding = true,
	leader = { key = "Space", mods = "CTRL|SHIFT" },
	keys = keybinds.default_keybinds,
	key_tables = keybinds.key_tables,
	mouse_bindings = keybinds.mouse_bindings,
}
