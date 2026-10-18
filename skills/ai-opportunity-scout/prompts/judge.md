# Stage 8 — Final judge

Today is {TODAY}. Rank these surviving areas and pick where the builder should start: {AREA_IDS}.

For each area, read `{RUN_DIR}/scoring/<id>.md`, `{RUN_DIR}/probes/<id>/playbook.md` and `{RUN_DIR}/redteam/<id>.md`. Also read `{RUN_DIR}/scope.md` (including the builder profile and user background), all of `{SKILL_DIR}/references/rubric.md`, section 8 of `{SKILL_DIR}/references/probe-design.md` and `{SKILL_DIR}/references/freshness.md`.

You are the investment committee: impartial, between the optimism of the earlier stages and the pessimism of the red team. For each area:
1. Rescore all 10 criteria using the playbook and red-team evidence. Weigh red-team points on their evidence: take fatal points with solid `[F]` evidence seriously, and discount speculative ones.
2. Account for anything new the red team's fresh landscape search found. A new incumbent launch can sink #6 even for an otherwise strong area.
3. Apply the evidence caps and the area knockouts.
4. Compute the final weighted score.
5. For every criterion that moved by 1 or more from Stage 5, explain why in one line.
6. Fold in the red team's changes to probes or thresholds that you accept, and say which.
7. Write the committee view in three short lines: why now, why this builder, and what would have to be true for the area to be worth two years of focus.

Rank the areas. Pick one **primary** area and up to {N_ALTERNATES} **alternates**. If fewer areas survive the knockouts, return fewer and say so; don't promote a knocked-out area to fill a slot. If the top areas are within 0.25 of each other, say that the difference is inside scoring noise, and break the tie on #3 signal speed, then #9 founder fit, then #10 advantage fit, because those decide how fast the builder learns.

The ranking is your best judgement, but the builder can test cheaply where an investor can't, so don't stop at a pick. Design the **opening round** per `probe-design.md` section 8: one opening probe from the playbook of each of the primary and alternate areas (no more than the builder's parallel-probe limit), all on the same time box, and the focus rule written out with each probe's thresholds. Then name the **first probe**: the opening probe to ship first if the builder can only start one this week, normally the primary area's.

Write `{RUN_DIR}/final.json`:
`{"date", "search_status", "first_probe": {"area_id", "probe", "build_days", "cost_cap", "time_box", "thresholds"}, "opening_round": {"time_box", "probes": [{"area_id", "probe", "build_days", "cost_cap", "signal_metric", "thresholds"}], "focus_rule": "…"}, "ranked": [{"id", "name", "final_score", "stage5_score", "scores": {"1": n, …, "10": n}, "score_changes": [{"criterion", "from", "to", "why"}], "knockout": null|"reason", "verdict": "primary|alternate|runner-up|knocked-out", "one_line_case", "insight", "why_now", "why_this_builder", "must_be_true", "key_risk", "probe_changes": ["…"]}]}`

Return the primary area, the alternates, the opening round and the first probe in four lines.
