#!/usr/bin/env python3
"""Stop hook for Claude Code and Codex: blocks a reply that shows a Mermaid block without its mermaid.live link."""
import json
import re
import sys


def claude_turn(path):
    """Text the assistant wrote since the last prompt, read from a Claude Code transcript; empty for other formats."""
    texts = []
    try:
        with open(path) as transcript:
            for line in transcript:
                entry = json.loads(line)
                content = (entry.get("message") or {}).get("content")
                if entry.get("type") == "user":
                    # Tool results arrive as user entries too; only a prompt starts a new turn.
                    blocks = content if isinstance(content, list) else []
                    if isinstance(content, str) or not any(b.get("type") == "tool_result" for b in blocks):
                        texts = []
                elif entry.get("type") == "assistant" and isinstance(content, list):
                    texts += [b.get("text", "") for b in content if b.get("type") == "text"]
    except (OSError, ValueError, AttributeError):
        return ""
    return "\n".join(texts)


event = json.load(sys.stdin)
# The agent already had one chance after a block; letting it stop avoids a loop.
if event.get("stop_hook_active"):
    sys.exit(0)

reply = (event.get("transcript_path") and claude_turn(event["transcript_path"])) or event.get("last_assistant_message") or ""
missing = len(re.findall(r"^\s*```mermaid", reply, re.MULTILINE)) - reply.count("mermaid.live/edit#pako:")
if missing > 0:
    print(json.dumps({
        "decision": "block",
        "reason": f"{missing} Mermaid diagram(s) in this reply lack a mermaid.live link. "
        "Load the `mermaid` skill and put the link from ~/.agents/skills/mermaid/link.py under each diagram.",
    }))
