-- Reviewing code: LLM-generated changes, and other people's PRs.
--
-- <leader>ad opens the diff in codediff.nvim. Against the working tree its
-- right-hand pane is the real, writable file buffer, so the comment binding
-- below works straight from the diff -- no jumping to the source first.
-- <leader>ab diffs the whole branch: the working tree against the point where
-- the branch left its base, as GitHub sees it when the branch has a PR.
-- <leader>ac opens a new `AI_REVIEW:` comment line above the current line and
-- drops you into insert mode there, so the comment is edited in the buffer
-- rather than a popup. It uses the comment syntax of the language at that spot
-- -- `// ...` in TS, `# ...` in Ruby, `{/* ... */}` between JSX children.
-- <leader>af lists every `AI_REVIEW:` comment in the project in a Snacks picker.
-- The `ai-review` agent skill answers them in place with `AI_REPLY:` lines.
-- <leader>ax deletes every `AI_REVIEW:` and `AI_REPLY:` line in the project.
-- <leader>ap opens a `PR_REVIEW:` comment the same way, as a block comment where
-- the language has one, and <leader>aP pushes them all into your pending GitHub
-- review and deletes them (see `review/pr.lua`).

local review = require("review")
local pr = require("review.pr")

local KEYWORD = "AI_REVIEW"
local REPLY = "AI_REPLY"

---@param line string
local function is_review_line(line)
  return line:find(KEYWORD .. ":", 1, true) or line:find(REPLY .. ":", 1, true)
end

--- Delete every `AI_REVIEW:` and `AI_REPLY:` line in the project. A buffer that
--- already had unsaved changes is left unsaved, so those changes are not saved
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
    local written = review.edit_file(path, function(buf)
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for i = #lines, 1, -1 do
        if is_review_line(lines[i]) then
          vim.api.nvim_buf_set_lines(buf, i - 1, i, false, {})
        end
      end
    end)
    if not written then
      unsaved = unsaved + 1
    end
  end

  local msg = ("Deleted %d review lines in %d files"):format(total, #files)
  if unsaved > 0 then
    msg = msg .. (", %d left unsaved (they had other changes)"):format(unsaved)
  end
  vim.notify(msg, vim.log.levels.INFO)
end

---@param cmd string[]
---@param on_exit fun(out: vim.SystemCompleted)
local function run(cmd, on_exit)
  vim.system(cmd, { text = true }, vim.schedule_wrap(on_exit))
end

--- Diff against the merge base with the remote's default branch, or a local
--- `main`/`master` when `origin/HEAD` is unset. Only right while that ref is
--- fresh: one older than the branch's start pulls other people's commits in.
local function diff_against_default_branch()
  local base
  local head = vim.system({ "git", "rev-parse", "--abbrev-ref", "origin/HEAD" }, { text = true }):wait()
  if head.code == 0 then
    base = vim.trim(head.stdout)
  else
    for _, name in ipairs({ "main", "master" }) do
      if vim.system({ "git", "rev-parse", "--verify", "--quiet", name }):wait().code == 0 then
        base = name
        break
      end
    end
  end
  if not base then
    return vim.notify("No base branch: origin/HEAD, main and master are all missing", vim.log.levels.ERROR)
  end
  -- `<base>...` compares the merge base of `<base>` and HEAD with the working tree.
  vim.cmd("CodeDiff " .. base .. "...")
end

--- Diff the whole branch. For a branch with a PR, GitHub computes the merge base
--- against the PR's own base, so a stale local master is never involved and a
--- stacked PR shows only its own changes. The merge base is an ancestor of the
--- checked-out head, so it exists locally without a fetch.
local function diff_branch()
  local stop = review.progress("Finding where the branch started…", "Branch diff")
  local jq = '.baseRefName + " " + .headRefOid'
  run({ "gh", "pr", "view", "--json", "baseRefName,headRefOid", "--jq", jq }, function(pr)
    if pr.code ~= 0 then
      stop()
      return diff_against_default_branch()
    end
    local base, head = pr.stdout:match("^(%S+) (%S+)")
    local compare = ("repos/{owner}/{repo}/compare/%s...%s"):format(base, head)
    run({ "gh", "api", compare, "--jq", ".merge_base_commit.sha" }, function(cmp)
      stop()
      local sha = vim.trim(cmp.stdout)
      if cmp.code ~= 0 or vim.system({ "git", "cat-file", "-e", sha .. "^{commit}" }):wait().code ~= 0 then
        vim.notify("GitHub merge base unavailable, falling back to the local default branch", vim.log.levels.WARN)
        return diff_against_default_branch()
      end
      vim.cmd("CodeDiff " .. sha)
    end)
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
      { "<leader>ab", diff_branch, desc = "Review diff (whole branch)" },
    },
  },
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        [KEYWORD] = { icon = "󰚩 ", color = "ai_review" },
        [REPLY] = { icon = "󰚩 ", color = "ai_reply" },
        [pr.KEYWORD] = { icon = " ", color = "pr_review" },
      },
      colors = {
        ai_review = { "#FF9E64" },
        ai_reply = { "#7DCFFF" },
        pr_review = { "#9ECE6A" },
      },
    },
    keys = {
      {
        "<leader>ac",
        function()
          review.insert(KEYWORD)
        end,
        mode = { "n", "x" },
        desc = "Add review comment",
      },
      {
        "<leader>ap",
        function()
          review.insert(pr.KEYWORD, { block = true })
        end,
        mode = { "n", "x" },
        desc = "Add PR comment",
      },
      { "<leader>aP", pr.push, desc = "Push PR comments to GitHub" },
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
        { "<leader>a", group = "review", icon = { icon = "󰚩 ", color = "orange" } },
      },
    },
  },
}
