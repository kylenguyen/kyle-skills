# Stage 8 — Final judge

Today is {TODAY}. Rank these surviving areas and pick where the builder should start: {AREA_IDS}.

For each area, read `{RUN_DIR}/scoring/<id>.md`, `{RUN_DIR}/probes/<id>/playbook.md` and `{RUN_DIR}/redteam/<id>.md`. Also read `{RUN_DIR}/scope.md` (including the builder profile and user background), all of `{SKILL_DIR}/references/rubric.md` and `{SKILL_DIR}/references/freshness.md`.

You are impartial, between the optimism of the earlier stages and the pessimism of the red team. For each area:
1. Rescore all 9 criteria using the playbook and red-team evidence. Weigh red-team points on their evidence: take fatal points with solid `[F]` evidence seriously, and discount speculative ones.
2. Account for anything new the red team's fresh landscape search found. A new incumbent launch can sink #6 even for an otherwise strong area.
3. Apply the evidence caps and the area knockouts.
4. Compute the final weighted score.
5. For every criterion that moved by 1 or more from Stage 5, explain why in one line.
6. Fold in the red team's changes to probes or thresholds that you accept, and say which.

Rank the areas. Pick one **primary** area and up to {N_ALTERNATES} **alternates**. If fewer areas survive the knockouts, return fewer and say so; don't promote a knocked-out area to fill a slot. If the top areas are within 0.25 of each other, say that the difference is inside scoring noise, and break the tie on #3 signal speed and then #9 founder fit, because those decide how fast the builder learns.

Then name the **first probe**: the single probe from the primary area's playbook the builder should ship first, with its build days, cost cap, time box and thresholds.

Write `{RUN_DIR}/final.json`:
`{"date", "search_status", "first_probe": {"area_id", "probe", "build_days", "cost_cap", "time_box", "thresholds"}, "ranked": [{"id", "name", "final_score", "stage5_score", "scores": {"1": n, …, "9": n}, "score_changes": [{"criterion", "from", "to", "why"}], "knockout": null|"reason", "verdict": "primary|alternate|runner-up|knocked-out", "one_line_case", "key_risk", "probe_changes": ["…"]}]}`

Return the primary area, the alternates and the first probe in three lines.
