-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Open clipboard history with SUPER+SHIFT+V instead of SUPER+CTRL+V.
hl.unbind("SUPER + CTRL + V")
o.bind("SUPER + SHIFT + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

-- Move push-to-talk dictation from F9 to Ctrl+F12.
if o.cmd_present("voxtype") then
  hl.unbind("F9")
  o.bind("CTRL + F12", "Start dictation (push-to-talk)", "voxtype record start")
  -- Stop on F12 release even if releasing Ctrl first shadows other F12 binds.
  o.bind("CTRL + F12", "Stop dictation (push-to-talk)", "voxtype record stop",
    { release = true, ignore_mods = true, non_consuming = true, transparent = true })
end

-- SUPER+BACKSPACE trashes the selection in Files; elsewhere it toggles transparency.
hl.unbind("SUPER + BACKSPACE")
o.bind("SUPER + BACKSPACE", "Files: move to trash / toggle window transparency", function()
  local window = hl.get_active_window()
  if window and window.class == "org.gnome.Nautilus" then
    -- Match Omarchy's clipboard workaround to avoid a stuck synthetic key.
    hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "Delete", state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "Delete", state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  else
    hl.exec_cmd("omarchy-hyprland-window-transparency-toggle")
  end
end)

-- Keep Brave tabs, address bar, and bookmarks visible in full screen.
local function toggle_brave_fullscreen()
  local window = hl.get_active_window()
  if window and window.class == "brave-browser" then
    local enabled = window.fullscreen ~= 0
    hl.dispatch(hl.dsp.window.fullscreen_state({
      action = "set",
      internal = enabled and 0 or 2,
      client = 0,
    }))
    return true
  end
  return false
end

-- SUPER+F was Omarchy's ordinary full-screen shortcut.
hl.unbind("SUPER + F")
o.bind("SUPER + F", "Full screen (keep Brave toolbar)", function()
  if not toggle_brave_fullscreen() then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen" }))
  end
end)

-- F11 normally goes to the application; forward it outside Brave.
o.bind("F11", "Full screen (keep Brave toolbar)", function()
  if not toggle_brave_fullscreen() then
    hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "F11", state = "down" }))
    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = "", key = "F11", state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end)

o.bind("SUPER + CTRL + ALT + SHIFT + M", "Switch monitor and peripherals to Mac", "monitor-input")
