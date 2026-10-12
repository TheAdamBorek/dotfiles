-- Helpers shared by the review keymaps in `plugins/ai-review.lua`.

local M = {}

---@param cs string
---@return string
local function norm(cs)
  return (vim.trim(cs):gsub("%s*%%s%s*", " %%s "))
end

--- Pick the commentstring for a comment inserted *above* `lnum`.
---
--- Reuses the per-node specs from ts-comments.nvim, but ignores nodes that
--- start on `lnum` itself: the comment goes on the line before, so it is not
--- inside them. That is what keeps `{/* %s */}` -- only valid between JSX
--- children -- off the line above a `<div>` that opens the element.
---@param lnum integer
---@return string
local function commentstring(lnum)
  local ok, Config = pcall(require, "ts-comments.config")
  local spec = ok and Config.options.lang[vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype]

  if type(spec) == "table" and not vim.islist(spec) then
    local row = lnum - 1
    local col = #vim.fn.getline(lnum):match("^%s*")
    local found, node = pcall(vim.treesitter.get_node, { ignore_injections = false, pos = { row, col } })
    while found and node do
      local cs = spec[node:type()]
      if cs and node:start() < row then
        return norm(type(cs) == "table" and cs[1] or cs)
      end
      node = node:parent()
    end
  end

  local fallback = (type(spec) == "table" and spec[1]) or (type(spec) == "string" and spec)
  return norm(fallback or (vim.bo.commentstring ~= "" and vim.bo.commentstring) or "# %s")
end

-- Block forms of line-comment leaders, for languages that have both.
local BLOCK = { ["//"] = "/* %s */", ["--"] = "--[[ %s ]]" }

--- Open a new `<keyword>: ` comment above the current line (or the selection)
--- and start insert mode in it.
---@param keyword string
---@param opts? { block?: boolean } use a block comment where the language has one
function M.insert(keyword, opts)
  local mode = vim.api.nvim_get_mode().mode
  local lnum = vim.fn.line(".")
  if mode == "v" or mode == "V" or mode == "\22" then
    lnum = math.min(lnum, vim.fn.line("v"))
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  end

  local cs = commentstring(lnum)
  if opts and opts.block then
    local leader = cs:match("^(.-)%s*%%s%s*$")
    cs = BLOCK[leader] or cs
  end
  local indent = vim.fn.getline(lnum):match("^%s*")

  -- Split around the `%s` so the cursor can sit between the two halves: at the
  -- end of `// AI_REVIEW: `, but *inside* `{/* AI_REVIEW:  */}`.
  local prefix, suffix = cs:match("^(.-)%%s(.*)$")
  prefix = indent .. (prefix or "") .. keyword .. ": "
  suffix = suffix or ""

  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, { prefix .. suffix })
  vim.api.nvim_win_set_cursor(0, { lnum, #prefix })
  vim.cmd(suffix == "" and "startinsert!" or "startinsert")
end

local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

--- Show `msg` with a spinner until the returned function is called.
---@param msg string
---@param title string
---@return fun()
function M.progress(msg, title)
  local id, frame, done = "review_progress", 0, false
  local timer = assert(vim.uv.new_timer())
  timer:start(0, 80, vim.schedule_wrap(function()
    -- A tick queued before `stop` would otherwise bring the notification back.
    if done then
      return
    end
    frame = frame % #SPINNER + 1
    vim.notify(msg, vim.log.levels.INFO, { id = id, title = title, icon = SPINNER[frame], timeout = false })
  end))
  return function()
    done = true
    timer:stop()
    timer:close()
    Snacks.notifier.hide(id)
  end
end

--- Load `path` into a buffer, let `edit` change it, and write it back.
---
--- Edits go through buffers rather than `sed`, so open files update in place
--- and each file's change is one undo step. `noautocmd` keeps format-on-save
--- from touching the rest of the file. A buffer that already had unsaved
--- changes is left modified instead of written, unless `force_write` is set.
---@param path string
---@param edit fun(buf: integer)
---@param force_write? boolean
---@return boolean written
function M.edit_file(path, edit, force_write)
  local buf = vim.fn.bufadd(path)
  local was_loaded = vim.api.nvim_buf_is_loaded(buf)
  vim.fn.bufload(buf)
  local was_modified = vim.bo[buf].modified

  edit(buf)

  if was_modified and not force_write then
    return false
  end
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent noautocmd write")
  end)
  if not was_loaded then
    vim.api.nvim_buf_delete(buf, {})
  end
  return true
end

return M
