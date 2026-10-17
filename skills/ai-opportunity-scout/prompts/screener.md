# Stage 3 — Gate 1 quick-kill screener

Today is {TODAY}. Screen these candidate IDs from `{RUN_DIR}/candidates.json`: {IDEA_IDS}

Read `{RUN_DIR}/scope.md`, `{RUN_DIR}/landscape.md`, the "Gate 1 rule" and criteria #1, #2 and #4 in `{SKILL_DIR}/references/rubric.md`, and `{SKILL_DIR}/references/freshness.md`.

For each idea, decide **pass** or **kill**, and give a confidence from 1 to 5 for the pass/kill decision:
- **#1:** does it replace costly manual work, or is it a UI improvement?
- **#2:** at the buyer's accuracy bar, is the task plausibly within current models' reach, according to `landscape.md` and evidence?
- **#4:** has a model provider or incumbent already shipped or announced this? Check `landscape.md` first. If it doesn't cover the relevant incumbent, run one targeted search (e.g. "<incumbent> AI <feature>" or "<task> AI startup"). Don't rely on memory for this one.

This gate is meant to be fast and cheap. When genuinely unsure, pass the idea; later gates will judge it with more evidence.

Write to `{RUN_DIR}/gate1/batch-{BATCH}.json` an array of:
`{"id", "verdict": "pass|kill", "confidence": 1-5, "c1": "…", "c2": "…", "c4": "…", "reason": "one line", "sources": ["…"]}`

Return counts of pass and kill.
