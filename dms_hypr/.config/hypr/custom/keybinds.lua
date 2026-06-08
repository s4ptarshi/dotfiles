-- =========================================================================
-- Hyprland Lua Keybinds Configuration
-- See: https://wiki.hypr.land/Configuring/Basics/Binds/
-- =========================================================================

local mainMod = "SUPER"
local browser = "uwsm app flatpak run app.zen_browser.zen"
local file_manager = "uwsm app dolphin"
local hs = require("../hyprsplit")

-- ==============================
-- Gestures Configuration
-- ==============================
hl.config({
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
})

-- ==============================
-- Applications
-- ==============================
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser)) -- Zen Browser
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser)) -- Zen Browser
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(file_manager)) -- Dolphin
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("uwsm app kitty")) -- Terminal
hl.bind("XF86Launch1", hl.dsp.exec_cmd("uwsm app rog-control-center"))

-- ==============================
-- Monitor / Focus Swapping
-- ==============================
-- 'focusmonitor' doesn't have a native hl.dsp wrapper, so we dispatch it manually
hl.bind("F2", hl.dsp.focus({ monitor = "r" }))
hl.bind("F1", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + " .. "right", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "r" }))
hl.bind("SUPER + " .. "left", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "l" }))
hl.bind("SUPER + " .. "up", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "u" }))
hl.bind("SUPER + " .. "down", hs.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "d" }))
-- ==============================
-- Workspaces & hyprsplit
-- ==============================
hs.config({ num_workspaces = 10 })
-- Using Lua loops drastically reduces boilerplate for workspace assignments!
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	-- [hidden] move current workspace
	hl.bind(mainMod .. " + " .. key, hs.dsp.focus({ workspace = tostring(key) }))
	-- [hidden] move current workspace silent
	hl.bind(mainMod .. " + SHIFT + " .. key, hs.dsp.window.move({ workspace = tostring(key), follow = false }))
end
-- Note: Unbinds (unbind = Super, 1) from the old config aren't necessary in Lua.
-- You simply overwrite the binding by defining a new one or omitting defaults.
hl.bind("SUPER + " .. "g", hs.dsp.grab_rogue_windows())
-- ==============================
-- Window & Layout Management
-- ==============================
if hl.get_config("general.layout") == "scrolling" then
	hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
	hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
	hl.bind(mainMod .. " + R", hl.dsp.layout("colresize +conf"))
	hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("consume_or_expel prev"))
	hl.bind(mainMod .. " + bracketright", hl.dsp.layout("consume_or_expel next"))
	hl.bind(mainMod .. " + P", hl.dsp.layout("promote"))
end

hl.bind(mainMod .. " + L", hl.dsp.layout("focus right"))
hl.bind(mainMod .. " + H", hl.dsp.layout("focus left"))
hl.bind(mainMod .. " + J", hl.dsp.layout("focus down"))
hl.bind(mainMod .. " + K", hl.dsp.layout("focus up"))

-- hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/toggle_fullscreen.sh"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
-- hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind("F4", hl.dsp.window.close())

-- Move and Resize
-- hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
-- hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
-- hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
-- hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))

-- Repeating binds (formerly binde).
-- (Using ["repeat"] syntax since 'repeat' is a reserved lua keyword)
-- hl.bind(mainMod .. " + SHIFT + right", hl.dsp.layout("colresize +0.05"), { ["repeat"] = true })
-- hl.bind(mainMod .. " + SHIFT + left", hl.dsp.layout("colresize -0.05"), { ["repeat"] = true })
-- move window to left or right monitor
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ monitor = "l", follow = true }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ monitor = "r", follow = true }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ monitor = "u", follow = true }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ monitor = "d", follow = true }))
-- ==============================
-- Mouse Binds (formerly bindm)
-- ==============================
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true }) -- Move Window
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- Resize Window

-- ==============================
-- DMS IPC & System
-- ==============================
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("dms ipc call lock lock"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notepad toggle"))
hl.bind(mainMod .. " + Slash", hl.dsp.exec_cmd("dms ipc call keybinds toggle hyprland"))
hl.bind(mainMod .. " + Super_L", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { release = true }) -- formerly bindr
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("dms ipc call powermenu toggle"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
hl.bind(mainMod .. " + ALT + Return", hl.dsp.exec_cmd("dms ipc call keybinds toggle kitty"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("dms screenshot window"))
hl.bind(mainMod .. " + ALT + T", hl.dsp.exec_cmd("dms ipc call keybinds toggle tmux"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("dms screenshot full"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("dms screenshot"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("app2unit pavucontrol"))

-- ==============================
-- Audio & Brightness Controls
-- ==============================
-- Formerly bindl (locked) and bindel (locked + repeating)
local locked_opts = { locked = true }
local locked_repeat_opts = { locked = true, ["repeat"] = true }

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), locked_opts)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), locked_opts)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), locked_opts)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("dms ipc call mpris playPause"), locked_opts)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), locked_opts)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("dms ipc call mpris previous"), locked_opts)

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3"), locked_repeat_opts)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3"), locked_repeat_opts)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5 ''"), locked_repeat_opts)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("dms ipc call brightness increment 5 ''"), locked_repeat_opts)
hl.bind(mainMod .. " + P", hl.dsp.dpms())
