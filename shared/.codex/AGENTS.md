## Code
When writing code, ask before you add tests. 

## Reports
When generating reports, by default use .html. Never create .xls or .docx formats on your own. Ask before doing so. You can also use .md for such reports.

IMPORTANT:You should keep your explanations super short and concise.
IMPORTANT: Minimize emoji use.

When appropriate, you can create visual diagrams using Mermaid syntax to help explain complex concepts, architecture, or workflows.

```
graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E

```

Common mermaid diagram types you can use:
- **Flowcharts**: `graph TD` or `graph LR` for decision flows and processes
- **Sequence diagrams**: `sequenceDiagram` for API calls and interactions
- **Class diagrams**: `classDiagram` for object relationships and database schemas
- **Entity relationship diagrams**: `erDiagram` for database design
- **User journey**: `journey` for user experience flows
- **Pie charts**: `pie` for data visualization
- **Gantt charts**: `gantt` for project timelines

Use mermaid diagrams when they would help clarify:
- Application architecture and component relationships
- API request/response flows
- Edge functions workflows
- Database schema design
- User workflows and decision trees
- System interactions and data flow
- Project timelines and dependencies

When you're explaining code, attach examples of the code, at least most crucial aspects and add some comments which are going to explain what this piece of code does. You don't need to quote the whole codebase but most important bits.

## Graphite Workflow
When you commit or push use `graphite` cli for that. The cli tool name is `gt`. For branch names take branch name from linear like `feature/CAT-3285` and add 2-3 words to describe what the branch is about. Use kebab case for the branch name.

Use Graphite CLI (`gt`) for branches that should be submitted as stacked PRs.

### Creating / Tracking Branches
If a branch already exists locally but Graphite says it is untracked, track it before submitting:

```bash
gt track <branch-name> --parent master --no-interactive
For Linear work, use the Linear issue ID in the branch name and add a short kebab-case suffix:
feature/cat-2489-fix-flag-defaults
Submitting Changes
Prefer Graphite submit over raw git push when creating/updating PRs:
gt submit --no-edit --no-ai
This pushes the branch and creates or updates the Graphite/GitHub PR. In non-interactive mode, new PRs are created as drafts by default.
Useful Checks
Check the current stack:
gt log
Check whether the current branch is tracked:
gt submit --dry-run --no-interactive
If Graphite reports:
Cannot perform this operation on untracked branch
run:
gt track <branch-name> --parent master --no-interactive
then retry:
gt submit --no-edit --no-ai
Notes for Codex
Use gt submit instead of git push when the user asks to push via Graphite.
If the branch was created with git switch -c, it may still need gt track.
Keep PR titles aligned with Linear requirements, e.g. [CAT-2489] Fix feature flag defaults