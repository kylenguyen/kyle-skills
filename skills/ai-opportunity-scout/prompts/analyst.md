# Stage 5 — Area analyst

Today is {TODAY}. Score these areas in depth: {AREA_IDS} (from `{RUN_DIR}/areas.json`; their seeds are in `{RUN_DIR}/seeds/`, and screen notes are in `{RUN_DIR}/screen.json`).

Read `{RUN_DIR}/scope.md` (including the builder profile), `{RUN_DIR}/landscape.md`, all of `{SKILL_DIR}/references/rubric.md` and `{SKILL_DIR}/references/freshness.md`.

You are scoring a place to start prototyping, not a business plan. Don't estimate market size, payback or revenue milestones; the builder is patient and the probes will test demand directly. Spend your research on what decides whether cheap probes can get honest signal here. Search budget: about 12 searches per area. For each area, research and score criteria 1–9 against the rubric's scale points:
- **#1:** who has this job, how often it recurs, and public signs of pain (threads, complaints, workarounds, paid alternatives).
- **#2:** evidence that current models do the core job well enough for a user who checks the output. Also search for evidence of failure.
- **#3:** where these users gather and whether they can try a tool without procurement or a gatekeeper.
- **#4:** what human work per customer the natural product shapes would need. Look at comparable products: do they sell self-serve, or with onboarding and services?
- **#5:** how many distinct product shapes fit the area (the seeds, the `adjacent_shapes` and any you find), and anything that caps it, such as a statute, a sunset date or a fixed population.
- **#6:** a fresh search of incumbent and model-provider launches in the last 6 months that cover the core job.
- **#7–#9:** per the rubric.

The evidence caps apply: a criterion with only `[A]` or `[M]` support is capped at 2. Score honestly. Most areas score 2–3 on most criteria, and inflated scores make the ranking useless.

Write one file per area to `{RUN_DIR}/scoring/<area-id>.md` containing:
1. A header with the ID, name, date and search status.
2. A table of criterion, score and a one-line justification.
3. Tagged evidence for each criterion.
4. A knockout check against the rubric's area knockouts.
5. The weighted score.
6. The product shapes most likely to work as a first probe, and why.
7. The biggest uncertainty, which probe design should test first.

Return one line per area: ID, weighted score, knockout pass or fail.
