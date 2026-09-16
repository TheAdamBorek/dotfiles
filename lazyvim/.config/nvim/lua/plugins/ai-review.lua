-- Reviewing LLM-generated code.
--
-- <leader>ad opens the diff in codediff.nvim. Against the working tree its
-- right-hand pane is the real, writable file buffer, so the comment binding
-- below works straight from the diff -- no jumping to the source first.
-- <leader>ac drops an `AI_REVIEW:` comment above the current line, using the
-- comment syntax of the language at that spot -- `// ...` in TS, `# ...` in
-- Ruby, `{/* ... */}` between JSX children.
-- <leader>af lists every `AI_REVIEW:` comment in the project in a Snacks picker.

local KEYWORD = "AI_REVIEW"

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

  -- Resolve up front: vim.ui.input is async and the cursor may move meanwhile.
  local cs = commentstring(lnum)
  local indent = vim.fn.getline(lnum):match("^%s*")

  vim.ui.input({ prompt = "AI review: " }, function(text)
    if not text or vim.trim(text) == "" then
      return
    end
    local comment = indent .. cs:format(("%s: %s"):format(KEYWORD, vim.trim(text)))
    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum - 1, false, { comment })
  end)
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
      },
      colors = {
        ai_review = { "#FF9E64" },
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
