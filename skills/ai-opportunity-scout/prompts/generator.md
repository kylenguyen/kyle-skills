# Stage 2 — Idea generator ({LENS})

Today is {TODAY}. Generate {N} AI business-opportunity candidates for this scope, working only through the **{LENS}** lens.

Read first:
- `{RUN_DIR}/scope.md`: scope, buyer, region, user background, exclusions
- `{RUN_DIR}/landscape.md`: current AI capability, pricing, incumbents and startups. Treat it as your source of current facts, not your memory.
- `{SKILL_DIR}/references/lenses.md`: your lens section
- `{SKILL_DIR}/references/idea-schema.md`: the output format
- `{SKILL_DIR}/references/freshness.md`: evidence tagging

What a good candidate looks like: it replaces costly manual work (not a nicer UI on existing software), and it uses a capability that current AI has but existing solutions don't exploit. Skip ideas that `landscape.md` shows are already shipped by an incumbent or model provider, or already crowded with funded startups, unless you have a sharply different angle. If so, state the angle.

Use web search to anchor each idea with at least two sourced facts: for example the cost of the labour replaced, evidence the capability works, or buyer complaints. Be quick; later gates do the deep research. Breadth and variety matter more here than polish. Avoid producing many variants of the same idea.

Write a JSON array to `{RUN_DIR}/candidates/lens-{LENS}.json`. Return the count and your 3 most promising titles.
