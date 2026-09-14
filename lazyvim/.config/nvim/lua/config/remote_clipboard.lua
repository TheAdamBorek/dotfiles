-- Clipboard for sessions whose yanks may need to reach another machine:
-- every copy is emitted as OSC 52 (inside tmux this becomes a tmux buffer,
-- rebroadcast to every attached client, local or SSH). Paste prefers the
-- local system clipboard when one is available (Wayland via wl-paste, macOS
-- via pbpaste), so content copied in other apps remains pasteable; without
-- one, paste is an OSC 52 query that tmux (or the terminal) answers.
local M = {}

local function proc_lines(pid, file)
  local ok, lines = pcall(vim.fn.readfile, "/proc/" .. pid .. "/" .. file)
  return ok and lines or {}
end

local function proc_ppid(pid)
  for _, line in ipairs(proc_lines(pid, "status")) do
    local ppid = line:match("^PPid:%s+(%d+)")
    if ppid then
      return tonumber(ppid)
    end
  end
end

local function ancestor_process_named(name)
  local pid = vim.fn.getpid()

  for _ = 1, 16 do
    local ppid = proc_ppid(pid)
    if not ppid or ppid <= 1 then
      return false
    end

    local comm = proc_lines(ppid, "comm")[1] or ""
    if comm:find(name, 1, true) then
      return true
    end

    pid = ppid
  end

  return false
end

local function executables(...)
  for _, name in ipairs({ ... }) do
    if vim.fn.executable(name) ~= 1 then
      return false
    end
  end
  return true
end

local function run(cmd, lines)
  vim.fn.system(cmd, lines)
end

local function read(cmd)
  local lines = vim.fn.systemlist(cmd, "", 1)
  return vim.v.shell_error == 0 and lines or {}
end

-- The clipboard of the display this session is attached to, if there is one.
-- Returns { copy = fn(register, lines), paste = fn(register) -> lines } or nil.
function M.local_clipboard(in_ssh)
  if vim.env.WAYLAND_DISPLAY ~= nil and executables("wl-copy", "wl-paste") then
    return {
      copy = function(register, lines)
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        run(cmd, lines)
      end,
      paste = function(register)
        local cmd = { "wl-paste", "--no-newline" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        return read(cmd)
      end,
    }
  end

  -- Over SSH into a Mac, pbcopy/pbpaste would hit the remote Mac's pasteboard
  -- rather than the one in front of the user, so only use them locally.
  -- macOS has a single pasteboard: "*" and "+" are the same thing.
  if vim.fn.has("mac") == 1 and not in_ssh and executables("pbcopy", "pbpaste") then
    return {
      copy = function(_, lines)
        run({ "pbcopy" }, lines)
      end,
      paste = function()
        return read({ "pbpaste" })
      end,
    }
  end
end

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local in_herdr = vim.env.HERDR_PANE_ID ~= nil or ancestor_process_named("herdr")

  if not (in_tmux or in_ssh or in_herdr) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local system = M.local_clipboard(in_ssh)

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines)
      if system then
        system.copy(register, lines)
      end

      if vim.g.omarchy_remote_clipboard_osc52 ~= false then
        emit(lines)
      end
    end
  end

  local function paste(register)
    if not system then
      return osc52.paste(register)
    end

    return function()
      return system.paste(register)
    end
  end

  vim.g.clipboard = {
    name = "OmarchyRemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }
end

return M
