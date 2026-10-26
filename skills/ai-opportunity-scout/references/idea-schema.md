# Seed and area schemas

Seeds and areas use these JSON shapes, so the main agent can cluster seeds and pass areas between stages without rereading prose.

## Seed

Generators write an array of these objects. A seed is a concrete product shape: specific enough to picture a first prototype, light enough to produce dozens of quickly.

```json
{
  "id": "wf-03",
  "lens": "workflow",
  "title": "Short name",
  "one_liner": "What it does, for whom, in one sentence.",
  "user": "Who uses it day to day",
  "payer": "Who pays, if different from the user",
  "job": "The recurring job or pain, as the user would describe it",
  "frequency": "daily | weekly | monthly | quarterly | yearly",
  "ai_capability": "The current AI capability that makes this work now",
  "why_now": "What changed recently: a capability, a price, a platform, a rule or a behaviour",
  "insight": "What a well-placed builder knows that outsiders miss, or 'none'",
  "prototype_shape": "content | fake-door | tool | product | add-on | developer | concierge",
  "channel_guess": "Where these users could be reached without a sales call",
  "ops_profile": "What a human must do per user once it is live, or 'none'",
  "current_alternatives": ["How it's done today: tools, services, manual work"],
  "evidence": [
    {"claim": "…", "tag": "F|I|A|M", "source": "URL or name", "date": "YYYY-MM-DD"}
  ]
}
```

Rules:
- ID prefixes by lens: `wf-`, `cap-`, `gap-`, `fdr-`, `prv-`, `srf-`, followed by a two-digit number.
- `prototype_shape` uses the probe types in `probe-design.md` section 2.
- `evidence` needs at least one entry tagged `F` that shows the job or pain is real. A seed with no sourced anchor is usually a hunch.
- Keep each field short: the schema is for clustering and comparing, not pitching.

## Area

The main agent writes `areas.json` as an array of these objects in Stage 3.

```json
{
  "id": "area-01",
  "name": "Short name",
  "thesis": "Two sentences: the segment, the recurring job they struggle with, and the shift that makes AI useful for it now.",
  "segment": "Who the users are",
  "job": "The recurring job",
  "shift": "What changed recently, with a date",
  "insight": "The non-obvious belief behind the area: what this builder sees that funded teams and incumbents don't",
  "urgent_subsegment": "Who wants this most urgently right now; the first probe targets them",
  "proxies": ["Similar models working in another region, segment or industry, with a source"],
  "prior_attempts": ["Startups or products that tried this and stalled, and why, if known"],
  "seeds": ["wf-03", "gap-07", "srf-02"],
  "lenses": ["workflow", "gap", "surface"],
  "adjacent_shapes": ["Product shapes that fit the area but no generator proposed"],
  "thin": false,
  "notes": "Anything the screen or scoring should know, such as why two seeds were kept apart"
}
```

Rules:
- Area IDs are `area-` followed by a two-digit number.
- `thin` is true when the area has fewer than 3 seeds.
- `insight`, `proxies` and `prior_attempts` may be rough at Stage 3; the analyst fills the gaps. An empty `insight` is allowed, but say so, because an area with no insight is usually a crowded one.
- List seeds that fit no area in `areas.json` under a final object `{"id": "unclustered", "seeds": [...]}`.
