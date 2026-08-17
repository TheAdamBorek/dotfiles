---
name: apply-pr-comments
description: Fetch UNRESOLVED review comments from a GitHub PR and apply the suggested fixes to the working tree. Use when the user asks to address, apply, or act on PR review comments/feedback. Skips resolved and outdated threads.
---

# Apply PR review comments

Fetch **unresolved** review-thread comments from a GitHub pull request and apply the requested changes to the working tree. Resolved threads are ignored — resolution state is only exposed via the GraphQL API, so REST endpoints (`gh pr view --comments`, `/pulls/{n}/comments`) must not be used for deciding what to act on.

## 1. Resolve the target PR

- If the user gave a PR number or URL, use it.
- Otherwise, detect the PR for the current branch:

```bash
gh pr view --json number,headRefName,url
```

If no PR is associated with the branch, stop and ask the user which PR to use.

## 2. Fetch unresolved review threads

Run the GraphQL query below. `-F` sends the PR number as an integer; `gh` fills in `owner`/`repo` from the current repo automatically via `{owner}/{repo}` templating, so pass them explicitly to be safe:

```bash
OWNER=$(gh repo view --json owner --jq .owner.login)
REPO=$(gh repo view --json name --jq .name)
PR=<number>

gh api graphql -f query='
query($owner:String!, $repo:String!, $pr:Int!) {
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$pr) {
      reviewThreads(first:100) {
        nodes {
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first:50) {
            nodes {
              databaseId
              author { login }
              body
              diffHunk
              url
            }
          }
        }
      }
    }
  }
}' -F owner="$OWNER" -F repo="$REPO" -F pr=$PR --jq '
  .data.repository.pullRequest.reviewThreads.nodes
  | map(select(.isResolved == false))
  | map({
      path,
      line: (.line // .originalLine),
      isOutdated,
      comments: [.comments.nodes[] | {author: .author.login, body, url}]
    })'
```

Key rules:
- **Only act on threads where `isResolved == false`** (the `--jq` filter above already drops resolved ones).
- Treat `isOutdated == true` threads with caution — the referenced line may have moved. Locate the code by content from `diffHunk`/comment body, not by the stored line number, and flag it to the user if you can't confidently find the spot.
- Pagination: if a PR could have >100 threads or a thread >50 comments, page with `after`/`endCursor`. Rare — only handle it if the node count hits the cap.

## 3. Apply the fixes

For each unresolved thread:

1. Read the file at `path` around `line`.
2. Understand what the comment asks for. A thread can have multiple comments (a discussion) — the latest comments may supersede earlier ones; read the whole thread.
3. Some comments contain GitHub **suggestion blocks** (```` ```suggestion ````). Apply those literally to the referenced lines unless later discussion in the thread overrides them.
4. Make the edit with the normal Edit/Write tools, following this repo's conventions (see CLAUDE.md — Effect.js backend, Polish UI strings, etc.).
5. If a comment is a question, is ambiguous, or you disagree, do **not** guess-edit. Collect it and ask the user.

## 4. Report

Summarize as a short table: file · what the comment asked · what you did (applied / skipped-needs-input / not-actionable). Do not resolve the threads or push commits unless the user explicitly asks — this skill only edits the working tree.

## Notes

- Requires `gh` authenticated (`gh auth status`). If unauthenticated, tell the user to run `! gh auth login`.
- Review-thread comments (inline, on code) are distinct from issue-level PR comments (`gh pr view --comments`). This skill targets inline review threads, which are the ones that carry resolve state and suggested fixes.
