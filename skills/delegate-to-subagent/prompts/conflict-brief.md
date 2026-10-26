# Task {TASK_ID}: resolve merge conflicts for "{TITLE}"

You are resolving merge conflicts in the git repository in your current working directory. Task {MERGED_TASK_ID} is already in the code. Task {TASK_ID} is being merged on top of it with `git merge`, and these files still have conflict markers:

{CONFLICTED_FILES}

Run `git diff --name-only --diff-filter=U` to confirm the list. Work only from this brief: nobody will answer questions while you work.

## Goal

The result must do everything both tasks set out to do. Neither side wins by default:

1. For each conflict, work out what each side was trying to achieve from the two task sections below, then write code that achieves both. Where both sides changed the same logic, re-implement it so both behaviours hold.
2. If the two intents truly contradict each other, keep task {MERGED_TASK_ID}'s behaviour (it is already merged), make the smallest change that keeps task {TASK_ID} working, and explain the contradiction in your report.
3. Remove every conflict marker (`<<<<<<<`, `=======`, `>>>>>>>`).

## Rules

1. Change only what resolving the conflicts needs, plus follow-on fixes in the expected files so the verify commands pass.
2. Never weaken tests: keep the tests from both tasks unless they contradict each other, and say so if they do.
3. No TODOs, stubs or commented-out code.
4. Run every verify command yourself before you finish, and fix what fails.
5. Don't commit, don't abort the merge and don't create branches; the wrapper does that. Don't read or print environment variables.

## Expected files

{FILES}

## Verify commands

{VERIFY}

## Report

Write `/out/REPORT.md` with the sections Summary, Files, Verify, Deviations and Open issues. Under Summary, list each conflict and how you resolved it, one line each.

---

## Shared context

{SHARED_CONTEXT}

---

## Already merged: task {MERGED_TASK_ID}

{MERGED_TASK_SECTION}

---

## Being merged: task {TASK_ID}

{TASK_SECTION}
