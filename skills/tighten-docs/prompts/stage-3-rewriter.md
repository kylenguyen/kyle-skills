# Stage 3 — Rewriter

Tighten the wording of batch {BATCH_ID}. Paths are relative to the repo root `{REPO_ROOT}`:

{FILES}

Style: {STYLE}. Mode: {MODE}. In `apply` mode, edit the files in place. In `report-only` mode, write each rewritten file to `{RUN_DIR}/proposed/<path>` and leave the original untouched. Extra allowances: {ALLOWANCES}.

Read first: `{SKILL_DIR}/references/rules.md`, `{SKILL_DIR}/references/file-types.md`, `{SKILL_DIR}/references/never-compress.md`, and the repo's AGENTS.md or CLAUDE.md if one exists, for its spelling and style conventions.

For each file:

1. Read it whole. Note its category and reader (file-types.md, rules.md "Know the reader").
2. Before cutting a mention of a file, flag, tool or step, check whether it still exists (`ls`, `grep`). Cut stale ones; keep live ones.
3. Pass 1: cut, following rules.md.
4. Pass 2: tighten what is left, following rules.md.
5. When the same content appears in two files in this batch, keep it in the file the reader looks in first and point to it from the other.
6. Save. Do not create, rename or delete files, and do not edit files outside this batch.

Then write `{RUN_DIR}/notes/{BATCH_ID}.md` with a section per file:

- Removed instructions: quote each instruction, rule, default or example you removed, with the reason. Leave out filler and pure wording changes; this list is what the user checks.
- Removed or renamed headings, and renamed terms.
- Judgement calls: text you kept although it could go, or cut although unsure.
- Changes needed outside the batch, such as a file elsewhere linking to a heading you removed.

Return one line per file and nothing else: `<path>: <words before> -> <words after>, <n> removed instructions, <n> judgement calls`. Count words with `wc -w`.
