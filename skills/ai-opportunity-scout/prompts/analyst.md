# Stage 5 — Area analyst

Today is {TODAY}. Score these areas in depth: {AREA_IDS} (from `{RUN_DIR}/areas.json`; their seeds are in `{RUN_DIR}/seeds/`, and screen notes are in `{RUN_DIR}/screen.json`).

Read `{RUN_DIR}/scope.md` (including the builder profile), `{RUN_DIR}/landscape.md`, all of `{SKILL_DIR}/references/rubric.md` and `{SKILL_DIR}/references/freshness.md`.

You are scoring a place to focus, not a business plan. Don't estimate market size, payback or revenue milestones; the builder is patient and the probes will test demand directly. Spend your research on what decides whether cheap probes can get honest signal here and whether the area rewards the builder's edges. Search budget: about 14 searches per area. For each area, research and score criteria 1–10 against the rubric's scale points:
- **#1:** who has this job, how often it recurs, public signs of pain (threads, complaints, workarounds, paid alternatives), and the sub-segment that wants it most urgently. Update the area's `urgent_subsegment` if you find a better one.
- **#2:** evidence that current models do the core job well enough for a user who checks the output. Also search for evidence of failure. Then judge the tailwind: does the natural product sell a finished, verifiable piece of work that improves with each model release, or a thin layer the general assistants already match?
- **#3:** where these users gather, whether they can try a tool without procurement or a gatekeeper, and how many days a useful probe takes to build and get approved.
- **#4:** what human work per customer the natural product shapes would need. Look at comparable products: do they sell self-serve, or with onboarding and services?
- **#5:** how many distinct product shapes fit the area (the seeds, the `adjacent_shapes` and any you find), and anything that caps it, such as a statute, a sunset date or a fixed population. Name the asset each probe would leave behind (audience, rankings, data, integrations) and whether it carries to the next shape.
- **#6:** a fresh search of incumbent, model-provider and funded-startup activity in the last 6 months that covers the core job. Then a tarpit check: search for products that tried this and stalled ("<job> startup shut down", "<job> post-mortem"), name the barrier that stopped them, and say whether it still holds. Fill `prior_attempts`.
- **#7:** the dated change that opened the area, whether the behaviour is growing (sourced), and how long the window looks before an incumbent or a model release closes it.
- **#8:** spend you can see: self-serve prices, freelancer or agency rates for the job, and adjacent segments or regions that success would open. Fill `proxies` with any similar model working elsewhere.
- **#9 and #10:** per the rubric, against the background and builder profile in `scope.md`. For #10, say specifically which of the builder's three edges (speed, low operating load, patience) pays off here and why.

The evidence caps apply: a criterion with only `[A]` or `[M]` support is capped at 2. Score honestly. Most areas score 2–3 on most criteria, and inflated scores make the ranking useless.

Write one file per area to `{RUN_DIR}/scoring/<area-id>.md` containing:
1. A header with the ID, name, date and search status.
2. A table of criterion, score and a one-line justification.
3. Tagged evidence for each criterion.
4. A knockout check against the rubric's area knockouts.
5. The weighted score.
6. The area's insight in one sentence, or "none found".
7. Answers to the partner questions in the rubric, one line each.
8. The product shapes most likely to work as a first probe, and why.
9. The biggest uncertainty, which probe design should test first.

Return one line per area: ID, weighted score, knockout pass or fail.
