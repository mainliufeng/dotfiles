local windowFilter = hs.window.filter.default:setCurrentSpace(true)
local maximizedWindowFrames = {}

local function toggleMaximizeWindow()
  local window = hs.window.focusedWindow()
  if not window then
    return
  end

  local windowID = window:id()
  local previousFrame = maximizedWindowFrames[windowID]
  if previousFrame then
    window:setFrame(previousFrame, 0)
    maximizedWindowFrames[windowID] = nil
    return
  end

  maximizedWindowFrames[windowID] = window:frame()
  window:maximize(0)
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

hs.hotkey.bind({ "alt" }, "m", function()
  toggleMaximizeWindow()
end)

hs.hotkey.bind({ "alt" }, "q", function()
  hs.eventtap.keyStroke({ "cmd" }, "w")
end)

hs.hotkey.bind({ "alt", "shift" }, "return", function()
  local ghostty = hs.application.get("Ghostty")
  if ghostty then
    ghostty:activate()
    hs.timer.doAfter(0.05, function()
      hs.eventtap.keyStroke({ "cmd" }, "n")
    end)
    return
  end

  hs.application.launchOrFocus("Ghostty")
end)
