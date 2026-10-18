# Area scoring rubric

This rubric scores opportunity areas, not single products. The question it answers is "is this a good place for this builder to start prototyping?", not "will this idea return an investment?". So it rewards areas where cheap, low-maintenance probes can get honest market signal fast and where a failed probe can pivot to a neighbouring shape. It gives little weight to near-term unit economics.

Score each criterion from 1 to 5 using the scale points below. A 4 lies between the 3 and 5 descriptions, and a 2 lies between 1 and 3. Most areas should land at 2–3 on most criteria. If you are giving 4s and 5s across the board, you are probably scoring optimistically, so recheck the evidence.

For every score, give the evidence that justifies it, tagged as described in `freshness.md`. Areas are compared on these scores, so an untagged claim can't be checked and shouldn't move a score.

## Builder profile

The scale points assume the default builder profile in SKILL.md: prototypes in 1–2 weeks, at most 2 hours a week of operating load per live probe, self-serve channels, patient about returns. Read the profile in `scope.md`. If the user changed it, adjust the affected anchors (for example, a builder who accepts 10 hours a week of operating load can score #4 one point higher for a light service component) and say so in the justification.

## Evidence caps

- A criterion supported only by `[A]` or `[M]` evidence is capped at **2**.
- A time-sensitive claim (freshness.md section 2) tagged `[M]` counts as `[A]`.
- If a score depends on a `stale` source, note it, and lower the score by 1 unless a newer source confirms it.

## Criteria and weights

| # | Criterion | Weight | Knockout |
|---|---|---|---|
| 1 | Recurring pain for many reachable people | 15% | |
| 2 | AI makes a step change now | 10% | Must be ≥ 3 |
| 3 | Signal speed | 15% | Must be ≥ 2 |
| 4 | Low-ops fit | 15% | Must be ≥ 3 |
| 5 | Pivot room | 15% | |
| 6 | Room for a small builder | 10% | Must be ≥ 2 |
| 7 | Prototype cost | 5% | |
| 8 | Monetisation path | 5% | |
| 9 | Founder fit | 10% | |

Weighted score = Σ(score × weight), on a 1–5 scale. The same 9 criteria are used at Stage 5 and by the judge.

### 1. Recurring pain for many reachable people
Frequency matters as much as intensity. A job that recurs weekly gives a probe repeat usage to measure within a fortnight. A job that comes up once a year, such as an annual filing, gives one data point a year.
- **1:** Occasional or mild pain, or pain felt only by a small, fixed population (for example, a few hundred accredited professionals).
- **3:** A real job that recurs at least monthly for an identifiable segment of thousands of people or hundreds of firms, with sourced signs of pain: complaints, workarounds or paid alternatives.
- **5:** A frequent (weekly or more) painful job for a large reachable segment, with sourced evidence that people actively look for solutions: forum requests, "how do I…" threads, search interest, or paid workarounds.

### 2. AI makes a step change now
- **1:** The core job needs capabilities current models lack, or near-perfect accuracy with no way for the user to check the output.
- **3:** Current models plausibly do the core job with the user checking the output. There is evidence from comparable products, published evals or benchmarks, but not on this exact job.
- **5:** Recent evidence (products in use, published evals or a smoke test) shows current models do the job well, and errors are cheap for the user to spot and fix.

State the accuracy the user needs and who checks the output. A product where the user reviews its output before acting on it needs far less than one that acts unattended.

### 3. Signal speed
How quickly can a probe get honest behavioural signal: real use, repeat use or payment, rather than opinions? This decides how many build-measure-pivot loops fit into a year.
- **1:** Users can only be reached through enterprise or regulated procurement, or through a gatekeeper who must approve first. Any honest signal takes more than 3 months.
- **3:** Users are reachable through known self-serve channels (communities, marketplaces, search or content). Individuals or small teams decide for themselves. A probe could show activation within 4–6 weeks.
- **5:** Users already gather on a surface where a probe can be listed or posted within days, can try it without talking to anyone, and can pay by card. Meaningful signal arrives within 2 weeks.

### 4. Low-ops fit
Can products in this area run unattended? Human work per customer is the hidden cost that turns a software idea into a services business: per-customer review, onboarding, data clean-up, expert sign-off or heavy support. Judge the most natural product shapes in the area, not the worst one.
- **1:** Every customer needs expert human review, onboarding or services. A licence or a named accountable professional is required, or errors are high-stakes for third parties.
- **3:** Products can be self-serve with occasional support. The user checks the output themselves. Onboarding is a short setup, and any data sensitivity is manageable with standard practice.
- **5:** Fully self-serve with no per-user human work. Errors are low-stakes and visible to the user, and no sensitive data needs to be held.

Expert-gated compliance services (an accredited agent signs the GST review, a DPO signs the assessment, a specialist reviews every claim) score 1–2 here, however strong the pain.

### 5. Pivot room
If the first probe fails, how many other product shapes are left in the area, and how much of what was learned and built carries over?
- **1:** One product shape, or the area is capped by statute, a sunset date or a tiny fixed population.
- **3:** Several plausible shapes for the same users' job, or the same job across adjacent segments. At least 3 seeds, or 3 named adjacent shapes.
- **5:** Many shapes along both the segment and the job axis, with seeds from 3 or more lenses, and a growing tailwind. Code, audience and insight carry across shapes.

### 6. Room for a small builder
Unlike a venture rubric, a related feature shipped by an incumbent doesn't kill an area. It kills the probes that compete with it head-on. A builder who iterates fast can also profit from products with a short life. What kills an area is the core job already being solved, free or nearly free, by tools the segment already uses.
- **1:** Default tools the segment already uses (its main platforms, general AI assistants, free model-provider features) solve the core job well now.
- **3:** Incumbents or providers cover parts of the job. The segment or job is niche, cross-platform or fast-moving enough that a focused product can serve some users better. Cite your search.
- **5:** Incumbents are structurally unlikely to serve it: too small for them, spread across several platforms, or against their business model. Nothing ships today. Cite your search.

This score must cite a fresh search of incumbent and provider launches. A score above 2 that rests on memory alone breaks the evidence cap.

### 7. Prototype cost
- **1:** Any useful probe needs hard integrations, partner access, proprietary data, an approval process or more than 6 weeks of building.
- **3:** A useful probe in 2–4 weeks, with some integration work or a marketplace review wait.
- **5:** A useful probe within a week using public APIs and current tools, cheap to keep running.

### 8. Monetisation path
The builder is patient, so this checks that a path to revenue exists, not that it pays soon.
- **1:** No evidence anyone pays for anything in this area. Users accept only free tools.
- **3:** Users pay for adjacent tools or services, and a self-serve price point is plausible.
- **5:** Sourced evidence that self-serve AI products in this area are being paid for.

### 9. Founder fit
Scored against the user background in `scope.md`. Insider knowledge makes probes sharper, and membership of the user community makes reaching users cheap and their feedback easier to read. If no background was given, score 3 and say so.
- **1:** Unfamiliar domain, no access to the users, and no relevant building experience.
- **3:** Adjacent experience, or access to the user community.
- **5:** The user has lived the job, belongs to the user community, or already has an audience there.

## Area knockouts

An area is dropped, whatever its score, if any of these is true:

- A knockout criterion is below its threshold (#2 < 3, #3 < 2, #4 < 3, #6 < 2).
- A licence, accreditation or regulatory approval is needed before anyone can try any product in the area.
- The data the core job needs can't be obtained legally or practically, even with the user's consent.
- Every product shape in the area depends on a single platform that can cut off access and offers no alternative.

## Screen rule (Stage 4)

The screen is pass/kill only. Kill an area if any knockout is clearly true. When in doubt, pass it: Stage 5 is better equipped to judge borderline areas.
