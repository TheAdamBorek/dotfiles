---
name: code-comments
description: Code comments and doc comments, when to write, keep or delete one. Use when writing or editing code.
---

# Code comments

A useful comment tells a future reader something they couldn't get by reading the code itself. Everything else is noise.

The default is no inline comment. Write one only when a reader who knows the language and the module would get something wrong without it.

## What earns a comment

- Code that looks wrong, or easy to simplify, but has to stay that way. Say why, so the next editor doesn't "fix" it.
- An alternative a reader would likely propose, and why it was rejected.
- Hidden coupling or ordering: what else must change along with this, what must run before or after it.
- The outside source of a fact: a spec section, the library version behind a workaround, where a magic constant comes from.
- A construct the reader won't recognize, like a regex or a bit trick. Common idioms of the language need none.
- Dense code: name the algorithm. When a long function would need a note per step, split it into helpers whose names say the steps (only in code your change touches).
- A suppression, unchecked cast, `unsafe` block or lint override: why it's safe here.
- A rule the code can't enforce. When a check, assertion or type can enforce it, write that instead.

## Doc comments

Write a doc comment only when the signature leaves something out. State the contract, not the implementation. Each fact lives once, on the declaration: not at call sites, not again on overrides.

Doc comments on the fields of a larger object (a JSDoc block, a docstring, a struct field comment) are fine when the field types aren't obvious from the names, or when a few fields look alike and a reader could mix them up (`timeout`, `idleTimeout`, `connectTimeout`).

## Writing one

- Describe the code as it stands, for a future reader who never saw the change, the task or this conversation. History goes in the commit message.
- Concise over grammatical. Fragments are fine. Usually one line; let the content set the length.
- Plain words and the module's own terms. Name the actual limit or condition instead of an intensifier.
- A one-line summary above a block, not a note on every line.
- Follow the file's comment style, doc format and placement, including whether it uses end-of-line comments.
- When you can't confirm why code is the way it is, ask. A guessed reason reads as fact.
- Write the code, not a placeholder for it. A TODO is only for a limitation you leave on purpose, and names the condition that resolves it.

## Existing comments

- When your change makes a comment false, fix or delete it in the same change.
- In code your change touches, delete a comment that is outdated and that you would never write under these rules.
- Leave other existing comments alone. One that looks pointless may record a past bug.
- Code your change doesn't touch keeps its comments as they are.

## Before finishing

Reread every comment in your diff against the opening test. Delete the noise:

- the next line restated
- the change narrated: "now", "previously", "added", "fixed", "refactored"
- messages to the user or reviewer: what you did, why the change is right, the task, the prompt, who calls this
- commented-out code and "removed X" markers
- author names, dates, changelogs
- banners, closing-brace labels, "Step 1 / Step 2"

## Examples

Restates the code. Delete it.

```ts
// Increment the retry count
retries++;
```

Narrates the change. Before:

```ts
// Changed timeout from 30s to 5s to fix hanging requests
const TIMEOUT_MS = 5_000;
```

After, the constraint a future reader needs:

```ts
// gateway drops idle connections at 6s
const TIMEOUT_MS = 5_000;
```

Code that looks easy to simplify. The comment stops someone swapping in `Promise.all`:

```ts
// sequential on purpose, API rejects concurrent writes per account
for (const id of ids) await sync(id);
```

Doc comment that repeats the signature. Before:

```ts
/**
 * Gets a user by id.
 * @param id the user id
 * @returns the user
 */
function getUser(id: string): Promise<User>;
```

After, only what the signature leaves out:

```ts
/** Reads from the replica, may lag writes by a few seconds. */
function getUser(id: string): Promise<User>;
```
