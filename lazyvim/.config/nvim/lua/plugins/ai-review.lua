-- Reviewing LLM-generated code.
--
-- <leader>ad opens the diff in codediff.nvim. Against the working tree its
-- right-hand pane is the real, writable file buffer, so the comment binding
-- below works straight from the diff -- no jumping to the source first.
-- <leader>ac opens a new `AI_REVIEW:` comment line above the current line and
-- drops you into insert mode there, so the comment is edited in the buffer
-- rather than a popup. It uses the comment syntax of the language at that spot
-- -- `// ...` in TS, `# ...` in Ruby, `{/* ... */}` between JSX children.
-- <leader>af lists every `AI_REVIEW:` comment in the project in a Snacks picker.
-- The `ai-review` agent skill answers them in place with `AI_REPLY:` lines.
-- <leader>ax deletes every `AI_REVIEW:` and `AI_REPLY:` line in the project.

local KEYWORD = "AI_REVIEW"
local REPLY = "AI_REPLY"

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

local function add_comment()
  local mode = vim.api.nvim_get_mode().mode
  local lnum = vim.fn.line(".")
  if mode == "v" or mode == "V" or mode == "\22" then
    lnum = math.min(lnum, vim.fn.line("v"))
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  end

  local cs = commentstring(lnum)
  local indent = vim.fn.getline(lnum):match("^%s*")

  -- Split around the `%s` so the cursor can sit between the two halves: at the
  -- end of `// AI_REVIEW: `, but *inside* `{/* AI_REVIEW:  */}`.
  local prefix, suffix = cs:match("^(.-)%%s(.*)$")
  prefix = indent .. (prefix or "") .. KEYWORD .. ": "
  suffix = suffix or ""

  vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, { prefix .. suffix })
  vim.api.nvim_win_set_cursor(0, { lnum, #prefix })
  vim.cmd(suffix == "" and "startinsert!" or "startinsert")
end

---@param line string
local function is_review_line(line)
  return line:find(KEYWORD .. ":", 1, true) or line:find(REPLY .. ":", 1, true)
end

--- Delete every `AI_REVIEW:` and `AI_REPLY:` line in the project.
---
--- Edits go through buffers rather than `sed`, so open files update in place
--- and each file's deletion is one undo step. A buffer that already had unsaved
--- changes is left modified instead of written, so those changes are not saved
--- behind your back.
local function clear_comments()
  local root = LazyVim.root()
  local pattern = ("%s:|%s:"):format(KEYWORD, REPLY)
  local rg = vim.system({ "rg", "--count", "--", pattern }, { cwd = root, text = true }):wait()
  if rg.code == 1 then
    return vim.notify("No review comments", vim.log.levels.INFO)
  elseif rg.code ~= 0 then
    return vim.notify(rg.stderr, vim.log.levels.ERROR)
  end

  local files, total = {}, 0
  for entry in rg.stdout:gmatch("[^\n]+") do
    local path, count = entry:match("^(.*):(%d+)$")
    files[#files + 1] = vim.fs.joinpath(root, path)
    total = total + tonumber(count)
  end
  if vim.fn.confirm(("Delete %d review lines in %d files?"):format(total, #files), "&Yes\n&No", 2) ~= 1 then
    return
  end

  local unsaved = 0
  for _, path in ipairs(files) do
    local buf = vim.fn.bufadd(path)
    local was_loaded = vim.api.nvim_buf_is_loaded(buf)
    vim.fn.bufload(buf)
    local was_modified = vim.bo[buf].modified

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i = #lines, 1, -1 do
      if is_review_line(lines[i]) then
        vim.api.nvim_buf_set_lines(buf, i - 1, i, false, {})
      end
    end

    if was_modified then
      unsaved = unsaved + 1
    else
      -- `noautocmd` keeps format-on-save from touching the rest of the file.
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent noautocmd write")
      end)
      if not was_loaded then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end

  local msg = ("Deleted %d review lines in %d files"):format(total, #files)
  if unsaved > 0 then
    msg = msg .. (", %d left unsaved (they had other changes)"):format(unsaved)
  end
  vim.notify(msg, vim.log.levels.INFO)
end

return {
  {
    -- Binaries are fetched from GitHub releases on first use; no compiler needed.
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>ad", "<cmd>CodeDiff<cr>", desc = "Review diff (working tree)" },
      {
        "<leader>aD",
        function()
          vim.ui.input({ prompt = "Diff against revision: " }, function(rev)
            if rev and vim.trim(rev) ~= "" then
              vim.cmd("CodeDiff " .. vim.trim(rev))
            end
          end)
        end,
        desc = "Review diff (against revision)",
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        [KEYWORD] = { icon = "󰚩 ", color = "ai_review" },
        [REPLY] = { icon = "󰚩 ", color = "ai_reply" },
      },
      colors = {
        ai_review = { "#FF9E64" },
        ai_reply = { "#7DCFFF" },
      },
    },
    keys = {
      { "<leader>ac", add_comment, mode = { "n", "x" }, desc = "Add review comment" },
      {
        "<leader>af",
        function()
          Snacks.picker.todo_comments({ keywords = { KEYWORD } })
        end,
        desc = "Find review comments",
      },
      { "<leader>ax", clear_comments, desc = "Delete all review comments" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai review", icon = { icon = "󰚩 ", color = "orange" } },
      },
    },
  },
}
