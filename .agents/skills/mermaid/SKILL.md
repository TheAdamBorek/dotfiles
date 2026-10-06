---
name: mermaid
description: Mermaid diagrams. Use when writing or editing a Mermaid diagram.
---

# Mermaid

Every Mermaid diagram you show ships with a mermaid.live link, so the user can open it in the editor in one click.

## Adding the link

1. Finish the diagram source first. The link encodes the source, so any later edit makes it stale.
2. Pipe the exact source (no ```` ```mermaid ```` fence) to the script:

   ```sh
   python3 ~/.agents/skills/mermaid/link.py <<'MERMAID'
   flowchart LR
     A --> B
   MERMAID
   ```

3. Put the printed URL on the line directly under the diagram's code block:

   ```markdown
   [Open in mermaid.live](https://mermaid.live/edit#pako:...)
   ```

When the diagram goes into a file, put the link in your reply under the file path, unless the user asks for it in the file.

Done when every Mermaid block in your reply has a link under it, generated from its final source.
