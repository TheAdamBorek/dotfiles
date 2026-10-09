---
name: ai-review
description: Resolve the AI_REVIEW comments in the code, replying in place.
disable-model-invocation: true
---

# AI review

The user reviews code by leaving `AI_REVIEW:` comments in it, each one a question or a change request, in whatever comment syntax fits that spot (`//`, `#`, `{/* */}` between JSX children). Resolve every one where it sits. The code carries the conversation; the chat gets one line.

## 1. Find the threads

```sh
rg -n 'AI_(REVIEW|REPLY):'
```

A **thread** is an `AI_REVIEW:` line, the comment lines that continue it, and the `AI_REPLY:` and later `AI_REVIEW:` lines stacked directly below it from earlier rounds. Read each thread whole, together with the code it sits above.

A thread is **open** when its last entry is the user's `AI_REVIEW:`, and **waiting** when it ends in an `AI_REPLY:`: the user has not answered yet, so leave it untouched.

Done when every thread is classified as open or waiting.

## 2. Resolve each open thread

- **Change request you fully agree with**: make the change, then delete the whole thread. The user reads the diff; the comment has done its job.
- **Question**, or **change request with a reservation** (a risk, a better option, an ambiguity, a call that is the user's to make): reply in the thread and leave the code as it is. Delete nothing; the user removes the thread once they have read it.

A reply goes directly below the thread's last line, with the same indentation and comment syntax as its `AI_REVIEW:` line. Every reply line starts with `AI_REPLY: `, so a line-based script can strip all review traffic at once:

```ts
// AI_REVIEW: why a Map instead of a plain object?
// AI_REPLY: Keys are numeric user IDs; a plain object would turn them into
// AI_REPLY: strings and lose the insertion order the render loop relies on.
```

```tsx
{/* AI_REVIEW: can this be its own component? */}
{/* AI_REPLY: Yes, but it reads `draft` from the parent's closure, so it needs */}
{/* AI_REPLY: `draft` and `onChange` as props. Want me to extract it? */}
```

Write the reply in the language of the comment, as tersely as a good code review. Name code by symbol, since line numbers shift.

Done when every open thread is either deleted with its change made, or ends in an `AI_REPLY:` line.

## 3. Report

One line in chat: how many threads were applied and removed, how many answered in place. The answers live in the code, so leave them there.
