local windowFilter = hs.window.filter.default:setCurrentSpace(true)

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

hs.hotkey.bind({ "alt" }, "q", function()
  hs.eventtap.keyStroke({ "cmd" }, "w")
end)

hs.hotkey.bind({ "alt", "shift" }, "return", function()
  hs.task.new("/usr/bin/open", nil, { "-n", "-a", "/Applications/Ghostty.app" }):start()
end)
