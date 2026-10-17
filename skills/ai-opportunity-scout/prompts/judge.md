# Stage 7 — Final judge

Today is {TODAY}. Pick the final 3 from these surviving ideas: {IDEA_IDS}.

For each idea, read `{RUN_DIR}/gate2/<id>.md`, `{RUN_DIR}/gate3/<id>/dossier.md` and `{RUN_DIR}/gate4/<id>.md`. Also read `{RUN_DIR}/scope.md`, all of `{SKILL_DIR}/references/rubric.md` and `{SKILL_DIR}/references/freshness.md`.

You are impartial, between the optimism of the earlier stages and the pessimism of the red team. For each idea:
1. Rescore all 10 criteria using the dossier and red-team evidence. Weigh red-team points on their evidence: take fatal points with solid `[F]` evidence seriously, and discount speculative ones.
2. Account for anything new the red team's fresh landscape search found. A new incumbent launch can sink #4 even for an otherwise strong idea.
3. Apply the evidence caps, the #2 and #4 knockouts and the execution knockouts.
4. Compute the final weighted score using the final weights.
5. For every criterion that moved by 1 or more from Gate 2, explain why in one line.

Rank the ideas and pick the top 3. If fewer than 3 survive the knockouts, return fewer and say so. Don't promote a knocked-out idea to fill a slot.

Write `{RUN_DIR}/final.json`:
`{"date", "search_status", "ranked": [{"id", "title", "final_score", "gate2_score", "scores": {"1": n, …, "10": n}, "score_changes": [{"criterion", "from", "to", "why"}], "knockout": null|"reason", "verdict": "top3|runner-up|knocked-out", "one_line_case", "key_risk"}]}`

Return the top 3 with scores in three lines.
