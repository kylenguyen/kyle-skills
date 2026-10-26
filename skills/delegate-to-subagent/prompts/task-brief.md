# Task {TASK_ID}: {TITLE}

You are implementing one task in the git repository in your current working directory. Work only from this brief: you have no other context, and nobody will answer questions while you work.

## How your work is checked

When you finish, a separate process commits your changes and runs the verify commands below in a clean container with the network off. It also checks your diff: edits to files outside the expected list, changes to tests, config or lockfiles that the task doesn't ask for, skipped or deleted tests, new TODOs or stubs, and diff size. A reviewer then reads the diff. What you write in your report does not count as evidence that something works; only the commands do.

## Rules

1. Implement exactly what the task section asks. Don't refactor, rename or reformat code the task doesn't need, because unrelated changes are flagged and slow review down.
2. Change only the expected files listed below. If you truly must touch another file, keep the change minimal and explain why in your report.
3. Never weaken tests to make them pass: don't skip, delete or loosen existing tests or assertions unless the task says to.
4. No placeholders. Don't leave TODOs, stubs, `not implemented` errors or commented-out code. If you can't finish something, say so in your report instead.
5. Don't add dependencies unless the task says to.
6. Follow the conventions in the shared context and in the code next to your change.
7. Run every verify command yourself before you finish, and fix what fails. If a command fails for reasons outside your task (for example, a broken test elsewhere), leave it and report it.
8. Don't commit and don't create branches; the wrapper does that. Don't read or print environment variables, and don't try to reach internal hosts.
9. Stop when the acceptance criteria are met. Don't keep polishing.

## Expected files

{FILES}

## Verify commands

{VERIFY}

## Report

When you are done, write `/out/REPORT.md` (outside the repository, so it is never committed) with these sections, briefly:

```markdown
## Summary
What you changed, in two or three lines.

## Files
- path: why it changed (one line each)

## Verify
- `command`: pass or fail, with the key line of output

## Deviations
Anything you did differently from the brief, and why. "None" if none.

## Open issues
Anything unfinished, uncertain or worth the reviewer's attention. "None" if none.
```

---

## Shared context

{SHARED_CONTEXT}

---

## Task

{TASK_SECTION}
