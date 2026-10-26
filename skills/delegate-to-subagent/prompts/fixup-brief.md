# Task {TASK_ID}: {TITLE} (fix-up round {ROUND})

You are fixing specific defects in the git repository in your current working directory. An earlier attempt at the task below is already applied (staged as an uncommitted merge on top of the latest code), and a reviewer found the defects listed here. Work only from this brief: nobody will answer questions while you work.

## Defects to fix

{DEFECTS}

## Failing output

{FAILING_OUTPUT}

## Rules

1. Fix the listed defects and nothing else. Keep everything that already works as it is.
2. If `git status` shows unmerged files, resolve the conflict markers first, keeping the intent of both sides.
3. Change only the expected files listed below. If you truly must touch another file, keep the change minimal and explain why in your report.
4. Never weaken tests to make them pass: don't skip, delete or loosen tests or assertions unless a defect says to.
5. No TODOs, stubs, `not implemented` errors or commented-out code.
6. Run every verify command yourself before you finish, and fix what fails.
7. Don't commit and don't create branches; the wrapper does that. Don't read or print environment variables.

## Expected files

{FILES}

## Verify commands

{VERIFY}

## Report

Write `/out/REPORT.md` with the sections Summary, Files, Verify, Deviations and Open issues. Under Summary, list each defect and how you fixed it, one line each.

---

## Shared context

{SHARED_CONTEXT}

---

## Original task

{TASK_SECTION}
