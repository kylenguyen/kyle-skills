# Stage 4 — Gate 2 evidence analyst

Today is {TODAY}. Score these ideas in depth: {IDEA_IDS} (from `{RUN_DIR}/candidates.json`; Gate 1 notes are in `{RUN_DIR}/gate1/`).

Read `{RUN_DIR}/scope.md`, `{RUN_DIR}/landscape.md`, all of `{SKILL_DIR}/references/rubric.md` and `{SKILL_DIR}/references/freshness.md`.

For each idea, research and score criteria 1–9 against the rubric's scale points. Search the web for every time-sensitive point:
- **#1:** who does this work today, the hours or volume, and the cost (salary data, outsourcing rates, job postings).
- **#2:** evidence that current models handle this task at the buyer's accuracy bar: production products, published evals, case studies. Also search for evidence of failure.
- **#3:** what buyers pay today for this outcome (tools, services, headcount), and how AI competitors price.
- **#4:** a fresh search of incumbent and model-provider launches and announcements for this feature, within the last 6 months.
- **#5–#9:** per the rubric. For #6, show the calculation using current prices from the providers' pricing pages.

The evidence caps apply: a criterion with only `[A]` or `[M]` support is capped at 2. Score honestly. Most ideas score 2–3 on most criteria, and inflated scores make the ranking useless.

Write one file per idea to `{RUN_DIR}/gate2/<id>.md` containing:
1. A header with the ID, title, date and search status.
2. A table of criterion, score and a one-line justification.
3. Tagged evidence for each criterion.
4. Knockout check (#2 ≥ 3 and #4 ≥ 3?).
5. The weighted score, using the 9 criteria renormalised as the rubric describes.
6. The biggest uncertainty.

Return one line per idea: ID, weighted score, knockout pass or fail.
