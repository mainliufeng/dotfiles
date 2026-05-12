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
  local focusedWindowID = focusedWindow and focusedWindow:id()
  local focusedIndex = offset > 0 and 0 or (#windows + 1)

  for index, window in ipairs(windows) do
    if focusedWindowID and window:id() == focusedWindowID then
      focusedIndex = index
      break
    end
  end

  for step = 1, #windows do
    local nextIndex = ((focusedIndex - 1 + (offset * step)) % #windows) + 1
    local nextWindow = windows[nextIndex]

    if not focusedWindowID or nextWindow:id() ~= focusedWindowID then
      nextWindow:focus()

      local newFocusedWindow = hs.window.focusedWindow()
      if newFocusedWindow and newFocusedWindow:id() == nextWindow:id() then
        return
      end
    end
  end
end

local function openGhosttyWindow()
  hs.task.new("/usr/bin/open", nil, { "-n", "-a", "/Applications/Ghostty.app" }):start()
end

local function openNeovideWindow()
  hs.task.new("/usr/bin/open", nil, { "-n", "-a", "/Applications/Neovide.app" }):start()
end

local function closeFocusedWindow()
  local app = hs.application.frontmostApplication()
  if app and app:name() == "Neovide" then
    local window = hs.window.focusedWindow()
    if window then
      window:close()
    end
    return
  end

  hs.eventtap.keyStroke({ "cmd" }, "w")
end

local function lockScreen()
  hs.caffeinate.lockScreen()
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
  closeFocusedWindow()
end)

hs.hotkey.bind({ "alt", "shift" }, "return", function()
  openGhosttyWindow()
end)

hs.hotkey.bind({ "alt", "shift" }, "n", function()
  openNeovideWindow()
end)

hs.hotkey.bind({ "alt", "shift" }, "l", function()
  lockScreen()
end)
