# Scoring rubric

Score each criterion from 1 to 5 using the scale points below. A 4 lies between the 3 and 5 descriptions; a 2 lies between 1 and 3. Most ideas should land at 2–3 on most criteria. If you are giving 4s and 5s across the board, you are probably scoring optimistically. Recheck the evidence.

For every score, give the evidence that justifies it, tagged as described in `freshness.md`. Ideas are compared on these scores, so an untagged claim can't be checked and shouldn't move a score.

## Evidence caps

- A criterion supported only by `[A]` or `[M]` evidence is capped at **2**.
- A time-sensitive claim (freshness.md section 2) tagged `[M]` counts as `[A]`.
- If a score depends on a `stale` source, note it, and lower the score by 1 unless a newer source confirms it.

## Criteria and weights

Gate 2 uses criteria 1–9. The weights are renormalised over those nine, so they sum to 100%. Final scoring (Stage 7) adds criterion 10 and uses the weights below.

| # | Criterion | Final weight | Knockout |
|---|---|---|---|
| 1 | Real, costly, manual problem | 13.5% | |
| 2 | AI is good enough, now | 13.5% | Yes: must be ≥ 3 |
| 3 | Willingness to pay, priced on value | 9% | |
| 4 | Survives the next model release | 13.5% | Yes: must be ≥ 3 |
| 5 | Defensibility beyond the model | 13.5% | |
| 6 | Unit economics including inference | 4.5% | |
| 7 | Trust, liability and adoption | 4.5% | |
| 8 | Distribution | 13.5% | |
| 9 | Unfair advantage | 4.5% | |
| 10 | Execution complexity (final only) | 10% | |

Weighted score = Σ(score × weight), on a 1–5 scale.

### 1. Real, costly, manual problem
The best AI opportunities replace expensive manual work: hours of skilled labour or outsourced services. Adding a nicer UI to existing software doesn't count.
- **1:** A convenience or UI improvement over existing software. No clear labour being replaced.
- **3:** Identifiable manual work. Hours or cost are estimated but not sourced, or the work is moderate (a few hours a week per team).
- **5:** Sourced evidence of substantial skilled labour or outsourcing spend: who does it, how many hours, and at what rate. The buyer already has a budget line for it.

### 2. AI is good enough, now
- **1:** The task needs capabilities current models clearly lack, or needs near-perfect accuracy with no room for human review.
- **3:** Current models plausibly do the task with human review. There is evidence from comparable products, published evals or benchmarks, but none on this exact task. The accuracy bar is known.
- **5:** Recent evidence (products in production, published evals or a smoke test) shows current models meet the buyer's accuracy bar for this task, and errors are cheap to catch.

Always state the accuracy bar: 99%+ for legal, finance and production code; around 80% can be fine with human review.

### 3. Willingness to pay, priced on value
- **1:** No evidence anyone pays for this outcome today. Only "cool demo" reactions.
- **3:** Buyers pay for adjacent tools or services. A value-based price (a fraction of the labour or outcome replaced) is plausible.
- **5:** Sourced evidence of current spend on the outcome, and existing AI products in the space sold on value or outcome pricing.

### 4. Survives the next model release
Ask whether a model provider or the incumbent platform could ship this as a feature within 6 months. If they could, it's a feature, not a company.
- **1:** A model provider or incumbent has already shipped this, or announced it in the past 6 months.
- **3:** Incumbents could add it, but it needs domain depth, data or integrations they are unlikely to build soon. Nothing has been announced. Cite your search.
- **5:** Structurally unattractive or hard for incumbents and providers: a niche too small for them, regulated, data they can't get, or it conflicts with their business model.

This score must cite a fresh search of incumbent and provider launches. A score above 2 that rests on memory alone breaks the evidence cap.

### 5. Defensibility beyond the model
The model is a commodity, so the idea needs at least one of these:
- proprietary data or feedback loops that improve results over time;
- deep workflow integration that is painful to rip out;
- domain expertise encoded in evaluation, guardrails and edge cases;
- distribution or trust in a niche.

Scale:
- **1:** None. A thin wrapper around a model.
- **3:** One plausible moat, not yet proven.
- **5:** Two or more moats that compound with usage.

### 6. Unit economics including inference
- **1:** Inference cost per task at current prices takes most of a realistic price, or heavy agentic loops make the cost unpredictable.
- **3:** Healthy margin at current prices under stated assumptions (tokens per task, tasks per customer).
- **5:** Inference is a small fraction of price even at heavy usage, with a sourced price per million tokens and a worked calculation.

### 7. Trust, liability and adoption
Who is accountable when the AI is wrong? Will security, compliance and legal teams approve it?
- **1:** Errors are high-stakes, liability is unclear, and buyer security or legal teams typically block this category.
- **3:** Manageable with human review, audit trails and standard security certifications. Procurement friction is moderate.
- **5:** Low-stakes errors or clear human sign-off. Buyers already approve similar AI tools.

### 8. Distribution
AI makes building cheaper for everyone, so getting customers becomes the real constraint.
- **1:** No clear channel. Buyers are scattered and expensive to reach.
- **3:** A known channel (communities, marketplaces, partners, direct sales to a reachable list), but its cost and conversion are unproven.
- **5:** Cheap, proven access to buyers: an existing audience, an integration marketplace with demand, a partner channel, or the founder's network in the niche.

### 9. Unfair advantage
Scored against the user background in `scope.md`. Problems the user has personally felt score highest, because they know the buyer, the pain and how decisions get made. If no background was given, score 3 and say so.
- **1:** Unfamiliar domain with no network.
- **3:** Adjacent experience.
- **5:** The user has lived the problem, knows buyers personally and understands the purchase process.

### 10. Execution complexity (final only)
Higher means easier to execute.
- **1:** The MVP needs more than 9 months or a large team, heavy capital, or hard-to-get data or partnerships before any revenue.
- **3:** MVP in 3–6 months with 2–4 people, and the first paying customer plausible within about 6 months.
- **5:** MVP in under 3 months with 1–2 people, and paid pilots possible almost immediately.

## Execution knockouts (checked at Gate 3 and Final)

An idea is dropped regardless of score if the deep-dive finds any of the following:

- A licence, certification or regulatory approval is needed before any customer can use it.
- The data it fundamentally needs can't be obtained legally or practically.
- The MVP realistically takes more than about 9 months with a small team.
- It depends on a single platform that can cut off access (API terms, marketplace policy) and offers no alternative.

## Gate 1 rule

Gate 1 is pass/kill only. Kill an idea if any of these is clearly true:
- #1 is a UI improvement with no labour replaced;
- #2 is clearly beyond current models at the buyer's accuracy bar;
- #4 has already been shipped or announced by a provider or incumbent.

When in doubt, pass the idea. Later gates are better equipped to judge borderline ideas.
