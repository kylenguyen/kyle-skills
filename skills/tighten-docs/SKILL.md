---
name: tighten-docs
description: Simplify and tighten the wording of docs and instructions across a repo or directory, including READMEs, AGENTS.md, CLAUDE.md, SKILL.md and skill prompts, docs folders, issue and PR templates and code comments. Cuts filler, repetition, historical trails and explanation the reader does not need, rewrites the rest in plain, direct English, then checks that no command, path, number, placeholder, trigger phrase or instruction was lost. Use when the user says "simplify the wording", "tighten the docs", "make this concise", "trim AGENTS.md", "clean up the comments", "remove unnecessary explanation", "review all text and guidance in this skill so it is concise and relevant", or asks to remove unnecessary references or history from docs or a skill, even if they don't say "tighten". Scope follows the path in the prompt, otherwise the current directory. Not for writing new docs, translating, or refactoring code.
---

# Tighten docs

Cut what the reader does not need from docs, agent instructions and comments, rewrite the rest in plain, direct English, then show that nothing that matters was lost. Files are edited in place and never committed: `git diff` is the review and git is the undo.

The main risk is not text left too long but a cut that silently changes behaviour, because in agent instruction files the wording is the program. Stages 2 and 5 exist to catch that.

Out of scope: writing new docs, translating, refactoring code, rewriting git history, and checking that docs are true (only that the files they reference exist).

## Inputs and defaults

| Input | Default | Changed by |
|---|---|---|
| Scope | Path named in the prompt, else the current directory | See Scope |
| Categories | `agent`, `doc`, `template`; plus `comments` when the scope is a code directory | "only the READMEs", "also the comments", "include the OpenAPI descriptions", "also the help text" |
| Style | `plain` | "terse", "caveman": `terse` for the `agent` category only; other files stay `plain` |
| Mode | `apply`: edit in place | "report only", "dry run", "just suggest": `report-only` |

Categories, and what each may change, are in `references/file-types.md`.

## Scope

| Prompt or location | Scope |
|---|---|
| Names a path (`@skills/dr-report/`, "the docs folder") | That path |
| No path; current directory is below the repo root | Current directory |
| No path; at the repo root | Whole repo. Say so when confirming, because it can be many files. |
| Names file types ("just the READMEs", "only comments") | Narrow the categories, or the file list, to match |

Treat the scope as a code directory, and include `comments`, when the inventory shows more `comments` files than `agent` and `doc` files together, or the user points at a source folder.

## Run directory and scripts

Each run writes to `<repo root>/.tighten-docs/<YYYY-MM-DD>-<scope-slug>/` (`{RUN_DIR}`), which the snapshot step adds to `.git/info/exclude`:

| Path | Written in |
|---|---|
| `inventory.txt` | Stage 1 |
| `files.txt`, `baseline/` | Stage 2: the file list and copies of the originals |
| `proposed/` | Stage 3, `report-only` mode |
| `notes/<batch>.md` | Stage 3 |
| `invariants.txt`, `review/<batch>.md` | Stage 5 |
| `report.md` | Stage 6 |

Run the scripts by absolute path (`<this skill's directory>/scripts/`) from anywhere in the target repo. Paths they print and accept are relative to the repo root. `inventory.sh --help` and `check-invariants.sh --help` list the options.

## Stages

### Stage 1 — Scope and inventory

1. Resolve the scope and categories, then run `inventory.sh [--include <cats>] <path>` and save its output to `{RUN_DIR}/inventory.txt`.
2. If the repo root line says "not a git repo", switch to `report-only` and tell the user why: there is no undo.
3. Show the user the included files (group by folder if there are more than 30), the totals, the categories available on request, the excluded files, the style, the mode, and whether sub-agents will be used and how many.
4. If the inventory warns of uncommitted changes in scope, ask the user to commit or stash first, because `git diff` would mix their edits with yours. If they continue, the baseline still captures the current text.
5. Wait for confirmation.

### Stage 2 — Snapshot

```bash
inventory.sh --paths-only [--include <cats>] <path> | check-invariants.sh snapshot {RUN_DIR} -
```

### Stage 3 — Cut, then tighten

Read `references/rules.md`, `references/file-types.md` and `references/never-compress.md` before starting.

- Up to 15 files and 10,000 words: do it yourself, following the steps in `prompts/stage-3-rewriter.md`.
- Larger: split into batches and run one sub-agent per batch, in parallel, with `prompts/stage-3-rewriter.md`. Batch by folder (one skill, `docs/`) so files that reference each other share a batch, with at most about 8,000 words per batch.

### Stage 4 — Cross-file consistency

1. Read every `notes/` file. For each removed heading or renamed term, `grep -rn` the whole repo, not just the scope, and update or restore every reference.
2. Remove duplicates across batches: keep the copy where the reader looks first (AGENTS.md for repo rules, SKILL.md for a skill's flow, a reference file for detail) and point to it from the others.
3. Check that stage, step and criterion numbers match everywhere they are cited.

### Stage 5 — Verify

1. Run `check-invariants.sh compare {RUN_DIR}` (add `--current {RUN_DIR}/proposed` in `report-only` mode) and save the output to `{RUN_DIR}/invariants.txt`. Exit code 2 means findings.
2. Resolve each finding: restore it, or record it in the notes as a deliberate removal with the reason, such as a link to a deleted file. For "non-comment line changed", confirm that only comment or docstring text differs, otherwise revert the line.
3. Review behaviour for `agent` and `schema` files: run one sub-agent per batch with `prompts/stage-5-reviewer.md`, even when Stage 3 ran without sub-agents. Do not pass it the notes, so it judges the text alone.
4. Fix every `changes-behaviour` and `ambiguous` finding that was not a deliberate removal, restoring the meaning in tightened words. Record deliberate ones in the notes.
5. Re-run the compare until every finding is fixed or explained.

### Stage 6 — Report

Write `{RUN_DIR}/report.md`:

1. Scope, categories, style and mode.
2. A table of file, words before, words after and change.
3. Removed instructions, quoted with reasons, from the notes. The user must check these.
4. Judgement calls, and text left unchanged on purpose (strings matched by tests, stale TODOs).
5. Invariant and review findings, and how each was resolved.

Then reply with the totals, the removed instructions, the report path, and how to review: `git diff -- <scope>`, or `diff -ru {RUN_DIR}/baseline {RUN_DIR}/proposed` in `report-only` mode. For heavily cut skills, suggest a test run of the skill before committing. Do not commit.

## Prompt placeholders

Fill these before passing a prompt to the Agent tool:

| Placeholder | Value |
|---|---|
| `{SKILL_DIR}` | Absolute path of this skill directory |
| `{RUN_DIR}` | Absolute path of the run directory |
| `{REPO_ROOT}` | Absolute path of the repo root |
| `{BATCH_ID}` | Short batch name, such as `b1-delegate-skill` |
| `{FILES}` | The batch's file paths, one per line |
| `{STYLE}` | `plain` or `terse` |
| `{MODE}` | `apply` or `report-only` |
| `{ALLOWANCES}` | Opt-ins beyond the defaults, such as "help text in scripts may change", or "none" |
| `{CURRENT_ROOT}` | `{REPO_ROOT}`, or `{RUN_DIR}/proposed` in `report-only` mode |

## What this skill can and cannot conclude

- The invariant check finds lost exact strings (code, paths, numbers, placeholders, URLs, headings, trigger phrases), changed code lines and broken links. It cannot judge meaning.
- The reviewer finds behaviour differences as one model reads them. It is not a test run; for a skill, running it again is the real test.
- Neither checks that the docs are true.
