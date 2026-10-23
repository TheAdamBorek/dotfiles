## Code

Before writing implementation or test code, agree with the user whether tests are needed and, if so, which behaviors and public interfaces they should cover. Reuse any agreement already made in the session.

Before planning, writing, modifying, or reviewing tests, load the `tdd` skill. It defines how to write tests, what makes a good test, and which anti-patterns to avoid. Apply it even when the user hasn't explicitly requested TDD.

## Reports

When generating reports, by default use .html. Never create .xls or .docx formats on your own. Ask before doing so. You can also use .md for such reports.

IMPORTANT:You should keep your explanations super short and concise.
IMPORTANT: Minimize emoji use.

**Mermaid**: before writing a diagram anywhere, load the `mermaid` skill.

**GitHub media**: `gh` uploads images and videos itself. Use `--attach ./shot.png` (alt text: `'./shot.png#Login error'`, repeatable, max 50) on `gh pr create|edit|comment` and `gh issue create|edit|comment`. A body reference like `![alt](./shot.png)` is rewritten to the uploaded URL. Don't claim gh can't upload media or look for workarounds. Not supported on `gh pr review` or `gh release create`.

When you're explaining code, attach examples of the code, at least most crucial aspects and add some comments which are going to explain what this piece of code does. You don't need to quote the whole codebase but most important bits.

## Agent config

The user switches between Claude Code and Codex, so every agent setup change must reach both. This file is the one instruction file for both: `shared/.claude/CLAUDE.md` is a symlink to it, so add global rules here only. Skills live once in `.agents/skills/`, which both agents read. For agent-specific config (Claude `settings.json`, hooks, permissions vs. Codex `config.toml`), make the matching change in the other agent too, or tell the user it has no equivalent there.

## Dotfiles

Config lives in `~/dotfiles` as Stow packages; files under `~/.config`, `~/.claude`, `~/.codex` and similar are often symlinks into it. Before editing one, resolve the link. A file in `shared/` is stowed on both macOS and Omarchy (Arch + Hyprland), so every change there must work on both: use keys, paths and options valid on each OS, or make OS-specific settings optional (e.g. Ghostty's `config-file = ?path`) and put them in the `macos/` or `omarchy/` package. Note in a comment which OS needs a setting when only one does.
