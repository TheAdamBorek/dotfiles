-- Review a checked-out PR by writing `PR_REVIEW:` comments in the code, then
-- push them into your pending GitHub review and delete them from the code.
--
-- A comment refers to the line below it. It spans lines either as a block
-- comment (`/* ... */`, `{/* ... */}`) or, for a line comment, through
-- continuation lines indented past the leader:
--
--   # PR_REVIEW: This name clashes with X.
--   #   Maybe `fetch_user`?

local review = require("review")

local M = {}

M.KEYWORD = "PR_REVIEW"

local TITLE = "PR review"

-- Block-comment openers and their closers.
local CLOSERS = { ["/*"] = "*/", ["{/*"] = "*/}", ["<!--"] = "-->", ["--[["] = "]]" }

---@class review.PrComment
---@field first integer first buffer line of the comment
---@field last integer last buffer line of the comment
---@field line integer the commented line, numbered as in the file without comments
---@field body string

--- Find the comments in `lines`. Only a comment on a line of its own counts,
--- so a keyword trailing code is never mistaken for one (and never deleted).
---@param lines string[]
---@return review.PrComment[] comments
---@return string[] stripped `lines` without the comments
function M.parse(lines)
  local found, stripped = {}, {}
  local i = 1
  while i <= #lines do
    local s, e = lines[i]:find(M.KEYWORD .. ":", 1, true)
    local prefix = s and lines[i]:sub(1, s - 1)
    if not (prefix and prefix:match("^%s*%p+%s*$")) then
      stripped[#stripped + 1] = lines[i]
      i = i + 1
    else
      local body, last = { lines[i]:sub(e + 1) }, i
      local closer = CLOSERS[vim.trim(prefix)]
      if closer then
        while not body[#body]:find(closer, 1, true) and last < #lines do
          last = last + 1
          local text = lines[last]:gsub("^%s*", "")
          -- Drop the ` * ` leader Neovim adds when you press Enter in `/* */`.
          body[#body + 1] = text == "*" and "" or text:gsub("^%* ", "")
        end
        local at = body[#body]:find(closer, 1, true)
        body[#body] = at and body[#body]:sub(1, at - 1) or body[#body]
      else
        local cont = prefix:gsub("%s*$", "") .. "  "
        while lines[last + 1] and vim.startswith(lines[last + 1], cont) and lines[last + 1]:find("%S", #cont) do
          last = last + 1
          body[#body + 1] = lines[last]:sub(#cont + 1)
        end
      end
      for k, text in ipairs(body) do
        body[k] = vim.trim(text)
      end
      found[#found + 1] = { first = i, last = last, line = #stripped + 1, body = vim.trim(table.concat(body, "\n")) }
      i = last + 1
    end
  end
  return found, stripped
end

--- Line ranges GitHub accepts line comments on: the new side of every hunk.
---@param diff string unified diff of the PR
---@return table<string, integer[][]>
local function commentable(diff)
  local ranges, path = {}, nil
  for line in vim.gsplit(diff, "\n", { plain = true }) do
    local start, count = line:match("^@@ %-%S+ %+(%d+),?(%d*) @@")
    if start and path then
      local first = tonumber(start)
      table.insert(ranges[path], { first, first + (count == "" and 1 or tonumber(count)) - 1 })
    elseif line:match("^%+%+%+ ") then
      path = line:match("^%+%+%+ b/(.*)$")
      if path then
        ranges[path] = ranges[path] or {}
      end
    end
  end
  return ranges
end

--- Run `cmd` from inside a coroutine and wait for it without blocking Neovim.
---@param cmd string[]
---@param opts? vim.SystemOpts
---@return vim.SystemCompleted
local function system(cmd, opts)
  local co = coroutine.running()
  vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {}), function(out)
    vim.schedule(function()
      coroutine.resume(co, out)
    end)
  end)
  return coroutine.yield()
end

---@param cmd string[]
---@param opts? vim.SystemOpts
---@return string
local function check(cmd, opts)
  local out = system(cmd, opts)
  if out.code ~= 0 then
    error(vim.trim(out.stderr ~= "" and out.stderr or out.stdout), 0)
  end
  return out.stdout
end

---@param query string
---@param variables table
---@return table data
local function graphql(query, variables)
  local out = system({ "gh", "api", "graphql", "--input", "-" }, {
    stdin = vim.json.encode({ query = query, variables = variables }),
  })
  local ok, res = pcall(vim.json.decode, out.stdout, { luanil = { object = true } })
  if not ok then
    error(vim.trim(out.stderr), 0)
  end
  return res
end

--- Your pending review on the PR, created at `head` when there is none. A
--- pending review on an older commit is refused: line numbers would not match.
---@return string review id
local function pending_review(pr_id, head)
  local res = graphql(
    [[query($id: ID!) { node(id: $id) { ... on PullRequest {
      reviews(states: PENDING, first: 1) { nodes { id commit { oid } } } } } }]],
    { id = pr_id }
  )
  if res.errors then
    error(res.errors[1].message, 0)
  end
  local existing = res.data.node.reviews.nodes[1]
  if existing then
    if existing.commit.oid ~= head then
      error("Your pending review is on an older commit. Submit or discard it on GitHub first.", 0)
    end
    return existing.id
  end
  res = graphql(
    [[mutation($pr: ID!, $oid: GitObjectID!) {
      addPullRequestReview(input: { pullRequestId: $pr, commitOID: $oid }) { pullRequestReview { id } } }]],
    { pr = pr_id, oid = head }
  )
  if res.errors then
    error(res.errors[1].message, 0)
  end
  return res.data.addPullRequestReview.pullRequestReview.id
end

---@return string summary
local function push()
  local root = vim.trim(check({ "git", "rev-parse", "--show-toplevel" }))
  local rg = system({ "rg", "--files-with-matches", "--fixed-strings", "--", M.KEYWORD .. ":" }, { cwd = root })
  if rg.code == 1 then
    error("No " .. M.KEYWORD .. " comments", 0)
  end

  local pr = vim.json.decode(check({ "gh", "pr", "view", "--json", "id,url,headRefOid" }, { cwd = root }))
  local head = vim.trim(check({ "git", "rev-parse", "HEAD" }, { cwd = root }))
  if head ~= pr.headRefOid then
    error("Local HEAD is not the PR head. Pull (or push) the branch first.", 0)
  end
  local ranges = commentable(check({ "gh", "pr", "diff", "--color=never" }, { cwd = root }))
  local blob = pr.url:gsub("/pull/%d+$", "") .. "/blob/" .. head .. "/"

  local threads, skipped, opened = {}, {}, {}
  for rel in vim.gsplit(vim.trim(rg.stdout), "\n", { plain = true }) do
    local path = vim.fs.joinpath(root, rel)
    local buf = vim.fn.bufadd(path)
    if not vim.api.nvim_buf_is_loaded(buf) then
      opened[#opened + 1] = buf
    end
    vim.fn.bufload(buf)
    local found, stripped = M.parse(vim.api.nvim_buf_get_lines(buf, 0, -1, false))

    -- Line numbers are only right when the comments are the sole change.
    local shown = system({ "git", "show", head .. ":" .. rel }, { cwd = root })
    local original = shown.stdout:gsub("\n$", "")
    if #found == 0 then
      -- Only trailing keywords, which are not comments.
    elseif shown.code ~= 0 then
      skipped[#skipped + 1] = rel .. ": not in the PR"
    elseif original ~= table.concat(stripped, "\n") then
      skipped[#skipped + 1] = rel .. ": has changes besides the comments"
    else
      for _, c in ipairs(found) do
        local line = math.min(c.line, #stripped)
        local in_diff = vim.iter(ranges[rel] or {}):any(function(r)
          return r[1] <= line and line <= r[2]
        end)
        local input = in_diff and { path = rel, body = c.body, line = line, side = "RIGHT" }
          or { path = rel, body = ("%s%s#L%d\n\n%s"):format(blob, rel, line, c.body), subjectType = "FILE" }
        threads[#threads + 1] = { path = path, comment = c, input = input }
      end
    end
  end
  if #threads == 0 then
    error("Nothing to push.\n" .. table.concat(skipped, "\n"), 0)
  end

  local review_id = pending_review(pr.id, head)
  local params, fields, variables = {}, {}, {}
  for k, t in ipairs(threads) do
    t.input.pullRequestReviewId = review_id
    params[k] = ("$t%d: AddPullRequestReviewThreadInput!"):format(k)
    fields[k] = ("t%d: addPullRequestReviewThread(input: $t%d) { thread { id } }"):format(k, k)
    variables["t" .. k] = t.input
  end
  local res = graphql(
    ("mutation(%s) { %s }"):format(table.concat(params, ", "), table.concat(fields, " ")),
    variables
  )

  -- Delete only what GitHub took, bottom-up so earlier line numbers hold.
  local posted, by_path, failed = 0, {}, {}
  for k, t in ipairs(threads) do
    if res.data and res.data["t" .. k] then
      posted = posted + 1
      by_path[t.path] = by_path[t.path] or {}
      table.insert(by_path[t.path], t.comment)
    else
      failed[#failed + 1] = ("%s:%d"):format(t.input.path, t.comment.first)
    end
  end
  for path, posted_comments in pairs(by_path) do
    table.sort(posted_comments, function(a, b)
      return a.first > b.first
    end)
    -- The file was checked to match the PR head plus comments, so writing it
    -- saves nothing but the deletions.
    review.edit_file(path, function(buf)
      for _, c in ipairs(posted_comments) do
        vim.api.nvim_buf_set_lines(buf, c.first - 1, c.last, false, {})
      end
    end, true)
  end

  for _, buf in ipairs(opened) do
    if not vim.bo[buf].modified then
      vim.api.nvim_buf_delete(buf, {})
    end
  end

  local lines = { ("Added %d comments to your pending review: %s/files"):format(posted, pr.url) }
  if #failed > 0 then
    local reason = res.errors and res.errors[1].message or "unknown error"
    lines[#lines + 1] = ("Failed, left in the code (%s): %s"):format(reason, table.concat(failed, ", "))
  end
  vim.list_extend(lines, skipped)
  return table.concat(lines, "\n")
end

--- Push every `PR_REVIEW:` comment in the repo to your pending review on the
--- current branch's PR and delete the pushed ones from the code.
function M.push()
  local stop = review.progress("Pushing comments to the PR…", TITLE)
  coroutine.wrap(function()
    local ok, msg = pcall(push)
    stop()
    vim.notify(msg, ok and vim.log.levels.INFO or vim.log.levels.ERROR, { title = TITLE })
  end)()
end

return M
