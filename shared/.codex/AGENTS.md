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

## Agent config
The user switches between Claude Code and Codex, so every agent setup change must reach both. This file is the one instruction file for both: `shared/.claude/CLAUDE.md` is a symlink to it, so add global rules here only. Skills live once in `.agents/skills/`, which both agents read. For agent-specific config (Claude `settings.json`, hooks, permissions vs. Codex `config.toml`), make the matching change in the other agent too, or tell the user it has no equivalent there.

## Dotfiles
Config lives in `~/dotfiles` as Stow packages; files under `~/.config`, `~/.claude`, `~/.codex` and similar are often symlinks into it. Before editing one, resolve the link. A file in `shared/` is stowed on both macOS and Omarchy (Arch + Hyprland), so every change there must work on both: use keys, paths and options valid on each OS, or make OS-specific settings optional (e.g. Ghostty's `config-file = ?path`) and put them in the `macos/` or `omarchy/` package. Note in a comment which OS needs a setting when only one does.
