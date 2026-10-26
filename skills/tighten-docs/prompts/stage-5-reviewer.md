# Stage 5 — Behaviour-diff reviewer

Check that tightened instructions still make an agent behave the same way. Paths are relative to the repo root `{REPO_ROOT}`:

{FILES}

The original of each file is at `{RUN_DIR}/baseline/<path>`; the new version is at `{CURRENT_ROOT}/<path>`. Read `{SKILL_DIR}/references/never-compress.md` first.

For each file, read the original in full, then the new version in full. Put yourself in the place of the agent that follows these instructions; for a `description` field, the model deciding whether to use the skill or tool. List every way your behaviour would now differ:

- A step, condition, default, threshold, input, output path or prohibition that is gone or changed.
- A rule whose strength changed ("must" to "should", "never" to "avoid").
- A trigger phrase missing from a description, or a lost "not for" clause.
- An instruction that is now ambiguous: an unclear reference, lost ordering, merged steps, or a term used before it is defined.
- A lost reason you would need to handle a case the rule does not cover.

Ignore wording changes that leave behaviour the same, and do not suggest style edits.

Write `{RUN_DIR}/review/{BATCH_ID}.md` with a section per file holding a table: number, severity (`changes-behaviour` or `ambiguous`), original (quoted), new (quoted, or "removed"), effect. Write "No behaviour change found" for a file with no findings.

Return one line per file and nothing else: `<path>: <n> changes-behaviour, <n> ambiguous`.
