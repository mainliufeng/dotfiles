local windowFilter = hs.window.filter
  .new({ "Google Chrome", "Codex", "Ghostty" })
  :setCurrentSpace(true)

local spaces = hs.spaces

local function userSpacesForFocusedScreen()
  local focusedWindow = hs.window.focusedWindow()
  local screen = focusedWindow and focusedWindow:screen() or hs.screen.mainScreen()
  local screenSpaces = spaces.spacesForScreen(screen)
  local userSpaces = {}

  if not screenSpaces then
    return userSpaces
  end

  for _, spaceID in ipairs(screenSpaces) do
    if spaces.spaceType(spaceID) == "user" then
      table.insert(userSpaces, spaceID)
    end
  end

  return userSpaces
end

local function gotoWorkspace(index)
  local userSpaces = userSpacesForFocusedScreen()
  local spaceID = userSpaces[index]
  if spaceID then
    spaces.gotoSpace(spaceID)
  end
end

local function focusWindow(offset)
  local windows = windowFilter:getWindows(hs.window.filter.sortByCreated)
  if #windows == 0 then
    return
  end

  local focusedWindow = hs.window.focusedWindow()
  local focusedIndex = 0

  for index, window in ipairs(windows) do
    if focusedWindow and window:id() == focusedWindow:id() then
      focusedIndex = index
      break
    end
  end

  local nextIndex = ((focusedIndex - 1 + offset) % #windows) + 1
  windows[nextIndex]:focus()
end

hs.hotkey.bind({ "alt" }, "j", function()
  focusWindow(1)
end)

hs.hotkey.bind({ "alt" }, "k", function()
  focusWindow(-1)
end)

hs.hotkey.bind({ "alt" }, "1", function()
  gotoWorkspace(1)
end)

hs.hotkey.bind({ "alt" }, "2", function()
  gotoWorkspace(2)
end)

hs.hotkey.bind({ "alt" }, "3", function()
  gotoWorkspace(3)
end)

hs.hotkey.bind({ "alt", "shift" }, "return", function()
  local ghostty = hs.application.get("Ghostty")
  local windowCount = ghostty and #ghostty:allWindows() or 0

  hs.application.launchOrFocus("Ghostty")

  hs.timer.doAfter(0.2, function()
    local focusedGhostty = hs.application.get("Ghostty")
    local focusedWindowCount = focusedGhostty and #focusedGhostty:allWindows() or 0
    if windowCount > 0 and focusedWindowCount <= windowCount then
      hs.eventtap.keyStroke({ "cmd" }, "n")
    end
  end)
end)
