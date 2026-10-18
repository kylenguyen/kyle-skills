# Stage 4 — Area screener

Today is {TODAY}. Screen these areas from `{RUN_DIR}/areas.json`: {AREA_IDS}. Each area lists its member seeds, which are in `{RUN_DIR}/seeds/`.

Read `{RUN_DIR}/scope.md` (including the builder profile), `{RUN_DIR}/landscape.md`, the "Area knockouts", "Screen rule" and criteria #2, #3, #4 and #6 in `{SKILL_DIR}/references/rubric.md`, and `{SKILL_DIR}/references/freshness.md`.

For each area, decide **pass** or **kill**, and give a confidence from 1 to 5 for the decision:
- **#2:** is the core job plausibly within current models' reach, with the user checking the output?
- **#3:** can the area's users be reached and try something without procurement or a gatekeeper?
- **#4:** do the natural product shapes run self-serve, or does every customer need an expert, a licence or services?
- **#6:** do tools the users already have solve the core job well and free today? Is the area an obvious tarpit, one that many have tried and that stalled for a reason that still holds? Check `landscape.md` first. If it doesn't cover the relevant incumbent, run one targeted search. Don't rely on memory for this one.

Judge the area's best plausible product shapes, not its weakest seed: one ops-heavy seed doesn't kill an area that has self-serve shapes. This screen is meant to be fast and cheap. When genuinely unsure, pass the area. Search budget: about 1 search per area.

Write to `{RUN_DIR}/screen/batch-{BATCH}.json` an array of:
`{"id", "verdict": "pass|kill", "confidence": 1-5, "c2": "…", "c3": "…", "c4": "…", "c6": "…", "reason": "one line", "sources": ["…"]}`

Return counts of pass and kill.
