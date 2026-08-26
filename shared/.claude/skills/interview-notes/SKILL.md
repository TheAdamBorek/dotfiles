---
name: interview-notes
description: Turn my raw account of an interview into scored notes with a signal matrix.
disable-model-invocation: true
---

# Interview notes

Rewrite my raw account of how an interview went into the format below. My notes arrive as this skill's argument, in the same message, or in the next one — if none arrived, ask for them and stop there.

Nothing gets censored or dropped: this is a reformat, so every signal I raised survives into the output.

## Output

Emit the block below in a fenced code block so I can copy the markdown source, and emit nothing around it except the one score line described under **Score**. The matrix signal should be a list, every item start with a new line
but without `-` or `1.` at the begining of each line.

````markdown
Score: 3+

Two sentences, informal. Says what actually decided it.

## Signal matrix:

drilled into the retry logic unprompted **+**
never named a tradeoff in their own design **-**
````

## Score

A number `1`–`4`, optionally carrying a trailing `+` or `-` (`2-`, `3+`). 1 is a strong no, 4 a strong yes, 3 clears the bar.

Use the score I state. When I state none, read it off the balance of signal, and add one line after the block naming what pushed it that way so I can overrule you.

## Summary

One or two sentences max, informal — how I'd put it to a colleague over coffee, not how a hiring report puts it. Name the concrete moment that decided it ("lost the thread once the schema got wide") over the verdict it implies ("showed limited depth"). Apply the `unslop` skill to these two sentences before emitting them.

## Signal matrix

One bullet per signal. Every bullet starts with `-` and ends with a bolded suffix: `**+**` on a positive, `**-**` on a negative.

Each bullet is one observed behaviour in my words, short enough to scan in a glance — the matrix is the record, the summary is the read.
