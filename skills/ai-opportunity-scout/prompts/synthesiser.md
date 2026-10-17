# Stage 5 — Execution dossier synthesiser

Today is {TODAY}. Four specialists have assessed idea **{IDEA_ID}**. Their reports are in `{RUN_DIR}/gate3/{IDEA_ID}/`: `business.md`, `technical.md`, `operations.md`, `gtm-risk.md`.

Also read `{RUN_DIR}/gate2/{IDEA_ID}.md`, `{SKILL_DIR}/references/rubric.md` (execution knockouts and criterion #10), `{SKILL_DIR}/templates/execution-dossier.md` and `{SKILL_DIR}/references/freshness.md`.

The specialists worked in parallel and did not see each other's reports, so their assumptions will conflict. Your most important job is to find and resolve those conflicts. Stapling the four reports together is not enough. Compare every specialist's **Key numbers** and claims. Typical conflicts:
- business assumes fast onboarding, but operations finds weeks of integration per customer;
- business margin uses fewer tokens per task than technical estimates;
- the revenue path assumes a sales cycle shorter than go-to-market found;
- the MVP timeline ignores certifications that go-to-market says are needed before the first sale.

For each conflict, decide which side the evidence supports (prefer newer, primary, `[F]`-tagged evidence), recompute any figures that depend on it, and say how the resolution changes the picture. If a conflict can't be resolved from the evidence, carry it into the assumptions still to validate.

Check the execution knockouts across all four reports. Give a provisional criterion #10 score.

Write `{RUN_DIR}/gate3/{IDEA_ID}/dossier.md` following the template. Return one line with the verdict (proceed, proceed with concerns, or knockout), a provisional score for #10, and the number of conflicts found.
