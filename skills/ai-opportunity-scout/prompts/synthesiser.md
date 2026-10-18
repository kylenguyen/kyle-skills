# Stage 6 — Area playbook synthesiser

Today is {TODAY}. Two specialists have designed candidate probes for area **{AREA_ID}**. Their reports are in `{RUN_DIR}/probes/{AREA_ID}/`: `channel.md` and `build.md`.

Also read `{RUN_DIR}/areas.json` (ID {AREA_ID}), `{RUN_DIR}/scoring/{AREA_ID}.md`, `{RUN_DIR}/scope.md` (including the builder profile), `{SKILL_DIR}/references/probe-design.md`, `{SKILL_DIR}/references/rubric.md`, `{SKILL_DIR}/templates/area-playbook.md` and `{SKILL_DIR}/references/freshness.md`.

The specialists worked in parallel and did not see each other's reports, so their assumptions will conflict. Your first job is to find and resolve those conflicts; stapling the two reports together is not enough. Compare their **Key numbers** and candidate probes. Typical conflicts:
- channel's best surface is a marketplace, but build finds a review queue longer than the time box;
- channel's strongest signal needs users to connect an account, but build finds the integration needs partner approval;
- build's cheapest shape needs a human step per user, which breaks the operating-load ceiling;
- channel expects a price point that build's running cost per user can't support, even with caps.

For each conflict, decide which side the evidence supports (prefer newer, primary, `[F]`-tagged evidence), adjust the affected probes, and say how the change affects the plan. If a conflict can't be resolved from the evidence, make it the question of an early probe.

Then build the playbook:
1. Write the learning agenda: the 3 questions this area must answer, in order. The first is usually "does the urgent sub-segment feel this job often enough to act?"
2. Design 3–5 probes, sequenced per `probe-design.md` section 6, each with every field from section 1. The first must ship within 7 days. Check every probe against the low-ops design rules.
3. Write the pivot map, drawing moves from the area's seeds and `adjacent_shapes`.
4. Write the exit criteria for the whole area.

Check the area knockouts across both reports.

Write `{RUN_DIR}/probes/{AREA_ID}/playbook.md` following the template. Return one line with the verdict (explore, explore with concerns, or knockout), the first probe and its build days, and the number of conflicts found.
