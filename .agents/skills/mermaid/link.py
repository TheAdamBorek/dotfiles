#!/usr/bin/env python3
"""Read Mermaid source on stdin, print its mermaid.live edit link."""
import base64
import json
import sys
import zlib

code = sys.stdin.read().strip("\n")
if not code.strip():
    sys.exit("link.py: no diagram on stdin")

# Matches the editor's serde.ts: pako.deflate of the JSON state, URL-safe base64.
state = json.dumps({
    "code": code,
    "mermaid": json.dumps({"theme": "default"}),
    "autoSync": True,
    "updateDiagram": True,
})
payload = base64.urlsafe_b64encode(zlib.compress(state.encode(), 9)).decode().rstrip("=")
print(f"https://mermaid.live/edit#pako:{payload}")
