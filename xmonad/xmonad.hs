import XMonad
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Config.Desktop
import XMonad.Actions.GroupNavigation
import Data.Monoid
import System.Exit
import DBus.Client
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.FuzzyMatch
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.WorkspaceHistory
import XMonad.ManageHook
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import XMonad.Util.NamedScratchpad
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle 
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.StackTile
import XMonad.Layout.Tabbed
import XMonad.Layout.Master
import XMonad.Actions.DynamicProjects
import XMonad.Actions.GroupNavigation
import XMonad.Actions.GridSelect
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import qualified Data.Text       as T

------------------------------------------------------------------------
-- Prompt
--
myXPConfig :: XPConfig
myXPConfig = def 
    { font                = "xft:Hack Nerd Font:size=12:bold:antialias=true"
    , position            = Top
    , height              = 60 
    -- 500ms
    , autoComplete        = Just 500000
    --, promptKeymap        = vimLikeXPKeymap
    }

------------------------------------------------------------------------
-- Projects
--
projects :: [Project]
projects =
  [ Project { projectName      = "Gpt"
            , projectDirectory = "~/"
            , projectStartHook = Just $ do spawn "google-chrome-unstable --new-window 'https://google.com' 'https://chat.openai.com/chat' && /usr/bin/microsoft-edge-dev https://www.bing.com/new"
            }
    , Project { projectName      = "dotfiles"
            , projectDirectory = "~/dotfiles"
            , projectStartHook = Just $ do spawn "st -e nvim"
            }
  ]

------------------------------------------------------------------------
-- Scratchpads
-- 
scratchpads = 
    [
    NS "terminal" "st -t scratchpad-st" (title =? "scratchpad-st") (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    ] where role = stringProperty "WM_WINDOW_ROLE"

------------------------------------------------------------------------
-- Terminal
--
myTerminal      = "st"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Mod key
myModMask       = mod4Mask

-- Workspaces
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

------------------------------------------------------------------------
-- Key bindings
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch app
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modm,               xK_r     ), spawn "dwm-rofi")
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    , ((0,                  xK_F11   ), spawn "flameshot gui")
    , ((modm .|. shiftMask, xK_l     ), spawn "slock")

    -- prompts
    , ((modm,               xK_slash ), switchProjectPrompt myXPConfig)
    , ((modm .|. shiftMask, xK_slash ), shiftToProjectPrompt myXPConfig)

    -- scratchpads
    , ((modm,               xK_minus ), namedScratchpadAction scratchpads "terminal")

    -- move backward
    ,((mod1Mask,            xK_Tab   ), toggleWS)


    -- close focused window
    , ((modm,               xK_q     ), kill)

    -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- GridSelect
    -- , ((modm,               xK_g     ), goToSelected defaultGSConfig { gs_cellheight = 90, gs_cellwidth = 300})

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    --, ((modm,               xK_m     ), windows W.focusMaster  )
    , ((modm,               xK_m     ), sendMessage $ Toggle FULL)

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
    --, ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    , ((modm              , xK_i), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    --, ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    , ((modm              , xK_d), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Copy to all workspaces
    , ((modm .|. shiftMask, xK_0     ), windows copyToAll)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    --, ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    , ((modm .|. shiftMask, xK_r     ), spawn "xmonad --recompile; xmonad --restart")
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
    -- mod-{w,e}, Switch to physical/Xinerama screens 1, 2
    -- mod-shift-{w,e}, Move client to screen 1, 2
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm,               button1), (\w -> focus w >> mouseMoveWindow w
                                                     >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm,               button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm,               button3), (\w -> focus w >> mouseResizeWindow w
                                                     >> windows W.shiftMaster))
    , ((modm .|. shiftMask, button1), (\w -> focus w >> mouseResizeWindow w
                                                     >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:
--
myLayout 
  = smartBorders 
  $ avoidStruts 
  $ mkToggle (NOBORDERS ?? FULL ?? EOT) 
  $ tiled ||| masterAndTabbed
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio

    masterAndTabbed = mastered (3/100) (1/2) $ simpleTabbed

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

------------------------------------------------------------------------
-- Manage hook
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "ding"           --> doFloat
    , className =? "Ding"           --> doFloat
    , className =? "钉钉"           --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]
    <+> namedScratchpadManageHook scratchpads

------------------------------------------------------------------------
-- Event handling
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging
--
--myLogHook = dynamicLogWithPP $ defaultPP { ppOutput = hPutStrLn xmproc0 }

------------------------------------------------------------------------
-- Startup hook
--
myStartupHook = do
    spawnOnce "picom --experimental-backend &"
    setWMName "LG3D"

------------------------------------------------------------------------
-- Main
-- 
main = do
    -- xmproc <- spawnPipe "sh $HOME/.config/polybar/material/launch.sh"
    -- xmproc <- spawnPipe "xmobar $HOME/.config/xmobar/xmobarrc"
    xmproc <- spawnPipe "tint2 -c $HOME/.config/tint2/vertical.tint2rc"
    -- xmproc <- spawnPipe "echo ''"
    xmonad $ dynamicProjects projects $ ewmh $ docks def {
    --xmonad $ dynamicProjects projects defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = 2,
        modMask            = myModMask,
        -- numlockMask deprecated in 0.9.1
        -- numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = "#252525",
        focusedBorderColor = "#0099CC",

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = dynamicLogWithPP xmobarPP
            { ppOutput          = hPutStrLn xmproc
            , ppCurrent         = replaceString ".xpm" "_current.xpm" . myWorkspaceIcon -- 当前工作区
            , ppVisible         = myWorkspaceIcon -- 可见工作区
            , ppHidden          = myWorkspaceIcon -- 隐藏工作区
            , ppHiddenNoWindows = replaceString ".xpm" "_empty.xpm" . myWorkspaceIcon -- 没有窗口的隐藏工作区
            , ppTitle           = xmobarColor "#b3afc2" "" . shorten 100 -- 窗口标题
            , ppSep             = "|" -- 分隔符
            , ppWsSep           = ""
            },
        startupHook        = myStartupHook
    }

myWorkspaceIcon :: String -> String
myWorkspaceIcon ws = case ws of
    "1"       -> "<icon=1.xpm/>" 
    "2"       -> "<icon=2.xpm/>" 
    "3"       -> "<icon=3.xpm/>" 
    "4"       -> "<icon=4.xpm/>" 
    "5"       -> "<icon=5.xpm/>" 
    "6"       -> "<icon=6.xpm/>" 
    "7"       -> "<icon=7.xpm/>" 
    "8"       -> "<icon=8.xpm/>" 
    "9"       -> "<icon=9.xpm/>" 
    otherwise -> "|" ++ ws


-- 定义一个函数，用于替换字符串中的子字符串
replaceString :: String -> String -> String -> String
replaceString old new str = T.unpack $ T.replace (T.pack old) (T.pack new) (T.pack str)
