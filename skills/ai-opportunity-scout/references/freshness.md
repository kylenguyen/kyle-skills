# Freshness policy

AI capability, model pricing and the competitive landscape change faster than any model's training data. Ideas built on stale facts fail in predictable ways:

- "No one does this yet" is false because three startups launched last quarter.
- "Models can't do this reliably" is false because a recent release can.
- "Inference makes this uneconomic" is false because prices fell several-fold.
- "This is defensible" is false because the incumbent shipped it as a free feature.

Each of these errors can promote a dead area or kill a live one. So every agent in this skill follows the rules below.

## 1. Know today's date and distrust your sense of "latest"

Every prompt passes `{TODAY}`. Your idea of the "latest model", "current price" or "newest feature" reflects your training cutoff, not today. Before you rely on any of these, search for them.

## 2. Facts that must come from a current search

Look these up. Do not answer them from memory:

| Category | Examples | Maximum source age |
|---|---|---|
| AI model capability | What current models can do, benchmark results, context limits, modalities, agent and computer-use reliability | 6 months |
| Model and inference pricing | Price per million tokens, per image, per minute of audio; batch and caching discounts | 3 months |
| Competitors and startups | Who is building this, launches, funding, shutdowns, acquisitions | 6 months |
| Incumbent features and roadmaps | What platform vendors in the domain have shipped or announced, especially AI features | 6 months |
| Model provider product moves | First-party products, agents and integrations that could absorb the idea | 3 months |
| Regulation and compliance | AI-specific laws, sector rules, data protection guidance and enforcement | 12 months; check for anything newer |
| Market data | Labour rates, salaries, outsourcing costs, market sizes, adoption surveys | 24 months; prefer newer |
| Pricing of existing solutions | What users pay today for tools or services, including self-serve price points | 12 months |
| Distribution surfaces | Marketplace and app-store listing rules, review times, install counts, community promotion rules | 12 months |
| Conversion and retention benchmarks | Landing-page conversion, trial-to-paid, extension or plugin retention | 24 months; prefer newer |

If the only source you can find is older than its limit, you may use it, but tag it `stale` and lower your confidence.

## 3. What model knowledge is still fine for

Use your own knowledge for stable things: business frameworks, typical workflow shapes in a domain, engineering practice, how to design an eval or an experiment. Tag it `[M]` where it supports a score, so readers know it was not looked up.

## 4. Evidence tags

Tag every claim that supports a score:

- `[F: <source>, <YYYY-MM-DD or YYYY-MM>]` — fact from a source you found in this run. Include the publication date, not the access date. Add `stale` if the source is past its maximum age.
- `[I]` — your inference from tagged facts. Say briefly which facts.
- `[A]` — an assumption with no direct evidence.
- `[M]` — model knowledge, not looked up in this run. Allowed only for stable topics (section 3).

Scoring consequence (also stated in the rubric): a criterion supported only by `[A]` or `[M]` evidence is capped at 2. A time-sensitive claim (section 2) tagged `[M]` counts as `[A]`.

## 5. Search well, not just often

- Prefer primary sources: vendor pricing pages, official changelogs and release notes, regulator sites, company announcements, filings.
- Use secondary sources (news, analyst posts, review sites, forums) for signal, and cross-check anything that moves a score.
- Search for disconfirming evidence too. For example, search "<idea> startup", "<incumbent> AI <feature>" and "<task> AI accuracy problems", not only evidence that supports the idea.
- When sources conflict, prefer the newer primary source and note the conflict.
- Put only generic, public framing into search queries. Never include internal company names, figures or plans from the scope.

### Search budget

Each prompt gives an approximate search budget, because per-agent search limits are real and a run degrades when agents exhaust them on low-value lookups. Spend searches first on the facts that could trigger a knockout or move a score by 2 or more, then on the rest. If you hit a limit, stop searching, record `search: partial`, tag what you couldn't check, and finish the output rather than leaving it incomplete.

## 6. When search is unavailable or fails

Do not quietly fall back to memory. Instead:

1. Record `search: unavailable` (or `partial`) in your output and in `run-log.md`.
2. Tag the affected claims `[M]` or `[A]`. The scoring caps then apply automatically.
3. The final report must say in its summary that the run is degraded and which conclusions are most at risk. Usually these are #2 (AI step change), #6 (room for a small builder), the channel rules and the probe thresholds.

## 7. Re-check before you conclude

Stage 1 snapshots the landscape at the start of the run. The red team (Stage 7) runs a fresh search for competitor and incumbent launches for each shortlisted area, because a run can span days, and launches cluster. The judge must account for anything new the red team finds.
