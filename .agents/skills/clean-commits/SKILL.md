---
name: clean-commits
description: Organize local Git commits for commit-by-commit review. Use when the user asks for clean commits, plans a reviewable commit sequence during implementation, or wants existing branch or PR history reorganized locally while preserving its final contents.
---

# Clean commits

Arrange history so a reviewer can understand and assess one coherent change at a time. Choose commit boundaries by the meaning and dependencies of the changes. A commit may span many files; one file may appear in several commits.

Create or rewrite commits locally and finish after verification. Keep remote branches and PRs unchanged. Never run `git push` as part of this skill; publishing belongs to a separate workflow.

## Commit boundaries

- Isolate mechanical changes: file moves, renames, formatting, and generated churn unrelated to behavior. Include the imports, references, routes, and configuration needed to keep that mechanical change working. Put new behavior in subsequent commits.
- Give each behavior a coherent commit with its prerequisites. Keep dependency declarations, lockfile changes, runtime configuration, and packaging changes with the functionality that requires them.
- Separate business rules from views or administration when each stage is useful and verifiable independently. Keep a thin adapter with its view when splitting them would leave an unusable intermediate state.
- Include tests with the behavior they verify. Preserve the project's agreed test boundaries. During history cleanup, use existing tests rather than adding new features or expanding test scope.
- Fold implementation corrections into the commit they belong to. Preserve a separate fix when it corrects pre-existing behavior or represents a distinct change a reviewer should assess.
- Aim for intermediate commits that boot or build and pass appropriate checks. Adjust the boundaries when a proposed split leaves missing constants, actions, schema, assets, or runtime dependencies.
- Write subjects that name the actual change. Use the body for motivation or dependency choices that the diff does not explain. Choose the number of commits that fits the changes.

## Plan the sequence

Inspect the complete intended diff, its base, and any dependent branches. Identify mechanical changes, behavior, interfaces, tests, packaging, and documentation before staging files.

Propose an ordered list of subjects with a short scope for each commit. Account for every intended change, including hunks that need to be split within a file. Order prerequisites before their consumers.

If the user requested approval of the proposed sequence, obtain it before rewriting history. Otherwise, proceed within the existing authorization.

For example:

```text
Rename User to WebUser and update references
Add independent FieldUser accounts
Enforce account permissions
Add account administration
Document account management
```

The rename includes compatible references and routing. New permissions and administration belong to later commits.

## During implementation

Implement and verify one coherent slice, then commit it with its tests. A local TDD red phase can remain uncommitted; the review commit contains the completed behavior. Fold later corrections into the relevant commit when rewriting that history is authorized.

Revise the sequence when implementation reveals a dependency. Describe the final changes rather than preserving the chronology of experiments.

## Reorganize existing history

Steps 1, 4, and 5 run through `scripts/git-guard` in this skill's directory; `git-guard --help` lists every subcommand.

1. **Freeze the source.** Snapshot every branch to be rewritten in one call, naming each branch's base; a base that is another guarded branch makes the pair a stack:

   ```bash
   scripts/git-guard snapshot --name <name> --base origin/main <branch> <child>=<branch>
   ```

   The snapshot records base, tip, tree, and the patch hash, and creates backup refs under `refs/backups/<name>/`. Preserve unrelated working changes and use an isolated worktree when appropriate. The snapshot defines the contents to retain.
2. **Reconstruct the sequence.** Build the planned commits from the frozen changes. Split hunks as needed to make intermediate states coherent, even when the final file belongs to several commits. Preserve the existing final implementation.
3. **Check the stages.** Verify boot or build and relevant existing tests at the intermediate commits affected by the split. Check that the sequence has no accidental empty commits or merge commits. Repair grouping problems before completing the local history.
4. **Verify the final result.** For a stack, rewrite parents before children and move children onto the new parent tips. Then run `git-guard verify <name>` until every branch reports `ok`: the final tree matches the snapshot (identical tracked paths, contents, and modes), the aggregate diff from the base matches, each child sits on its current parent, and the new commits contain no merge or empty commits. Changed parent commit IDs are expected; equivalent parent trees preserve the layer's diff. Pass `--allow-rebase` only when the user authorized moving the branch to a newer base. On `FAIL`, run the printed `inspect` or `fix` command and move each missing or extra hunk into the commit it belongs to; a catch-all commit that restores the tree hides the grouping error.
5. **Confirm local state.** Verify the final local branch heads and stack bases. Preserve work added by another task; reconcile the source snapshot within the authorized scope, or leave that branch untouched and report the conflict. Repeat `git-guard verify` after any reconciliation. Respect changes to the requested PR scope, including withdrawals. Retain the snapshot through completion; `git-guard restore <name> [branch...]` returns branches to their saved tips, and `git-guard drop` belongs to the user.

## Completion

Report the ordered commit subjects and hashes, `git-guard verify` result, checks performed, and any remaining validation. Identify branches deliberately left unchanged and state that the commits are local and have not been pushed.
