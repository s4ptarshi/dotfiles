#! /usr/bin/env runhaskell
-- IMPORTS

import XMonad
import Data.Monoid

import Graphics.X11.ExtraTypes.XF86 --multimedia key binds

import System.Exit
import System.IO
import System.IO.Unsafe

import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks --create space for xmobar

import XMonad.Util.Run -- to spawn xmobar in main (spawnPipe)
import XMonad.Util.SpawnOnce -- to use spawnOnce to autostart
import XMonad.Util.EZConfig -- for ez binds ;)

import XMonad.Layout.Gaps
import XMonad.Layout.Spacing

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

--pull colours from xresources
import Data.Maybe
import Data.Bifunctor
import Data.List as DL
import Data.Char as DC



getFromXres :: String -> IO String
getFromXres key = fromMaybe "" . findValue key <$> runProcessWithInput "xrdb" ["-query"] ""
  where
    findValue :: String -> String -> Maybe String
    findValue xresKey xres =
      snd <$> (
                DL.find ((== xresKey) . fst)
                $ catMaybes
                $ splitAtColon
                <$> lines xres
              )

    splitAtColon :: String -> Maybe (String, String)
    splitAtColon str = splitAtTrimming str <$> (DL.elemIndex ':' str)

    splitAtTrimming :: String -> Int -> (String, String)
    splitAtTrimming str idx = bimap trim trim . (second tail) $ splitAt idx str

    trim :: String -> String
    trim = DL.dropWhileEnd (DC.isSpace) . DL.dropWhile (DC.isSpace)

fromXres :: String -> String
fromXres = unsafePerformIO . getFromXres

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "kitty -e fish"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
-- myWorkspaces    = ["Workspace 1","Workspace 2","Workspace 3","Workspace 4","Workspace 5","Workspace 6","Workspace 7","Workspace 8","Workspace 9"]
myWorkspaces    = ["I","II","III","IV","V","VI","VII","VIII","IX"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = fromXres"*.color7"
myFocusedBorderColor = fromXres"*.color9"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

--Applications
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch rofi
    , ((modm,               xK_p     ), spawn "rofi -show drun")

    -- launch firefox
    , ((modm .|. mod1Mask, xK_b     ), spawn "firefox")

    -- launch clipmenu
    , ((modm .|. mod1Mask, xK_c     ), spawn "greencliprofi.sh")

    -- launch lockscreen
    , ((modm .|. mod1Mask, xK_l     ), spawn "i3lock-fancy")

    -- launch pavucontrol
    , ((modm .|. mod1Mask, xK_v     ), spawn "pavucontrol")

    -- launch pcmanfm
    , ((modm .|. mod1Mask, xK_f     ), spawn "thunar")

    -- maim
    , ((controlMask .|. shiftMask, xK_Print), spawn "maim -s -u | xclip -selection clipboard -t image/png") --copy selection to clipboard
    , ((shiftMask, xK_Print), spawn "maim -u | xclip -selection clipboard -t image/png") --copy to clipboard
    , ((controlMask, xK_Print), spawn "maim -u -s ~/Pictures/screenshots/$(date +%s).png") --take selection ss
    , ((0, xK_Print), spawn "maim -u ~/Pictures/screenshots/$(date +%s).png") --regular ss

--Multimedia keys

    -- Mute volume.
      , ((0, xF86XK_AudioMute),
         spawn "volume.sh mute")

      -- Decrease volume.
      , ((0, xF86XK_AudioLowerVolume),
         spawn "volume.sh down")

      -- Increase volume.
      , ((0, xF86XK_AudioRaiseVolume),
         spawn "volume.sh up")

      -- Audio previous.
      , ((0, xF86XK_AudioPrev),
         spawn "playerctl previous")

      -- Play/pause.
      , ((0, xF86XK_AudioPlay),
         spawn "playerctl play-pause")

      -- Audio next.
      , ((0, xF86XK_AudioNext),
         spawn "playerctl next")

      -- brightness up
      , ((0, xF86XK_MonBrightnessUp),
         spawn "brightness.sh up")
      
      -- brightness down
      , ((0, xF86XK_MonBrightnessDown),
         spawn "brightness.sh down")


--window manager keybinds

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    --monocle layout bind
    , ((modm, xK_z), sendMessage $ Toggle FULL)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
outerGaps    = 5
myGaps       = gaps [(U, outerGaps), (R, outerGaps), (L, outerGaps), (D, outerGaps)]
addSpace     = spacing 10

myLayout = smartBorders
        $ mkToggle (NOBORDERS ?? FULL ?? EOT)
        $ avoidStruts (tiled ||| Mirror tiled ||| noBorders Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = myGaps
                $ addSpace
                $ Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "MEGAsync"       --> doFloat
    , className =? "conky (chadbook)" --> doIgnore
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
        spawnOnce "nitrogen --restore &"
        spawnOnce "picom --experimental-backends &"
        spawnOnce "xfce4-power-manager &"
        spawnOnce "clipmenud &"
        spawnOnce "redshift-gtk &"
        --spawnOnce "stalonetray &"
        spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &"
        spawnOnce "thunar --daemon &"
        spawnOnce "megasync &"
        spawnOnce "volnoti &"
        --spawnOnce "/home/antimony2k/.config/polybar/launch.sh &"
        spawnOnce "nm-applet &"
        spawnOnce "blueman-applet &"
        spawnOnce "kdeconnect-indicator &"
        spawnOnce "/home/antimony2k/.config/polybar/launch.sh &"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
        --xmproc <- spawnPipe "xmobar -x 0 /home/antimony2k/.config/xmobar/xmobarrc"
        --xmproc <- spawnPipe "/home/antimony2k/.config/polybar/launch.sh"
        xmonad $ docks $ ewmh $ defaults{ handleEventHook =
           handleEventHook def <+> fullscreenEventHook }

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]


