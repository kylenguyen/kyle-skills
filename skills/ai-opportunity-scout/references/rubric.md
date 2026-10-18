# Area scoring rubric

This rubric scores opportunity areas, not single products. The question it answers is "is this the best place for this builder to focus next?", not "will this idea return a venture fund?". It borrows what early-stage investors select for (an acute problem, a reason it works now, an insight others lack, a team suited to it) and adapts it to a builder whose edge is speed, low operating load and patience. `vc-principles.md` explains where each criterion comes from and where this rubric deliberately departs from venture practice.

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
| 1 | Acute, recurring pain | 15% | |
| 2 | AI step change and model tailwind | 10% | Must be ≥ 3 |
| 3 | Signal speed | 10% | Must be ≥ 2 |
| 4 | Low-ops fit | 10% | Must be ≥ 3 |
| 5 | Pivot room and compounding | 10% | |
| 6 | Room for a small builder | 10% | Must be ≥ 2 |
| 7 | Why now and trajectory | 10% | |
| 8 | Upside | 5% | |
| 9 | Founder fit | 10% | |
| 10 | Advantage fit | 10% | |

Weighted score = Σ(score × weight), on a 1–5 scale. The same 10 criteria are used at Stage 5 and by the judge.

### 1. Acute, recurring pain
Investors prefer a well to a puddle: a group that urgently needs something over a large group that mildly wants it. Frequency matters as much as intensity, because a job that recurs weekly gives a probe repeat use to measure within a fortnight, while a yearly filing gives one data point a year. Name the sub-segment that wants this most urgently; that is who the first probe targets.
- **1:** Occasional or mild pain, or pain felt only by a small, fixed population (for example, a few hundred accredited professionals). No one is doing anything about it today.
- **3:** A real job that recurs at least monthly for an identifiable segment of thousands of people or hundreds of firms, with sourced signs of pain: complaints, workarounds or paid alternatives.
- **5:** A frequent (weekly or more) painful job with a clearly identifiable urgent sub-segment, and sourced evidence that its members actively look for or hack together solutions: forum requests, "is there a tool that…" threads, spreadsheets passed around, or money spent on freelancers or tools.

### 2. AI step change and model tailwind
The most common investor objection is a technology looking for a problem; the most common AI-era objection is a product the next model release absorbs. Score both: can current models do the core job, and does the product get better or get replaced when models improve?
- **1:** The core job needs capabilities current models lack, or near-perfect accuracy with no way for the user to check the output. Or the product is a thin layer the general assistants already match.
- **3:** Current models plausibly do the core job with the user checking the output, with evidence from comparable products, published evals or benchmarks, though not on this exact job. Better models make the product somewhat better, but also make it easier to copy.
- **5:** Recent evidence (products in use, published evals or a smoke test) shows current models do the job well, and errors are cheap for the user to spot and fix. The product sells a finished, verifiable piece of work (not a generic assistant), so each model release lowers its cost and raises its quality while the surrounding workflow, data or channel stays the builder's.

State the accuracy the user needs and who checks the output. A product where the user reviews its output before acting on it needs far less than one that acts unattended.

### 3. Signal speed
How quickly can a probe get honest behavioural signal (real use, repeat use or payment, rather than opinions), counting build days and any approvals? This decides how many build-measure-pivot loops fit into a year, which is the builder's main advantage.
- **1:** Users can only be reached through enterprise or regulated procurement, or through a gatekeeper who must approve first. Any useful probe needs partner access, proprietary data or more than 6 weeks of building. Honest signal takes more than 3 months.
- **3:** Users are reachable through known self-serve channels (communities, marketplaces, search or content). Individuals or small teams decide for themselves. A useful probe takes 2–4 weeks including any marketplace review, and could show activation within 4–6 weeks of starting.
- **5:** A useful probe can be built within a week on public APIs. Users already gather on a surface where it can be listed or posted within days, can try it without talking to anyone, and can pay by card. Meaningful signal arrives within 2 weeks of launch.

### 4. Low-ops fit
Can products in this area run unattended? Human work per customer is the hidden cost that turns a software idea into a services business: per-customer review, onboarding, data clean-up, expert sign-off or heavy support. Investors accept that cost early because funded teams can hire; this builder can't. Judge the most natural product shapes in the area, not the worst one.
- **1:** Every customer needs expert human review, onboarding or services. A licence or a named accountable professional is required, or errors are high-stakes for third parties.
- **3:** Products can be self-serve with occasional support. The user checks the output themselves. Onboarding is a short setup, and any data sensitivity is manageable with standard practice.
- **5:** Fully self-serve with no per-user human work. Errors are low-stakes and visible to the user, and no sensitive data needs to be held.

Expert-gated compliance services (an accredited agent signs the GST review, a DPO signs the assessment, a specialist reviews every claim) score 1–2 here, however strong the pain. "Selling the work" scores well here only when the output can be verified by the user or automatically, not by the builder.

### 5. Pivot room and compounding
If the first probe fails, how many other product shapes are left in the area, and what carries over? For a patient builder the second half matters as much: assets that accumulate with each probe (an audience, search rankings, a dataset, an eval set, integrations, a reputation in a community) are the solo builder's version of a moat.
- **1:** One product shape, or the area is capped by statute, a sunset date or a tiny fixed population. Nothing built or learned in one probe helps the next.
- **3:** Several plausible shapes for the same users' job, or the same job across adjacent segments (at least 3 seeds, or 3 named adjacent shapes). Code and audience partly carry across.
- **5:** Many shapes along both the segment and the job axis, with seeds from 3 or more lenses. Each probe leaves behind a named asset (audience, data, rankings, integrations) that makes the next probe cheaper or its signal stronger.

### 6. Room for a small builder
Investors treat competition as proof that the problem is real. What matters is whether a focused builder can serve some users better. A related feature shipped by an incumbent doesn't kill an area; it kills the probes that compete with it head-on. Three things do kill it: the core job already solved free by tools the segment uses, a tarpit, or a crowd of funded teams going after exactly the same users and shapes.
- **1:** Default tools the segment already uses (its main platforms, general AI assistants, free model-provider features) solve the core job well now. Or the area is a tarpit: it looks obvious, many have tried, and the structural barrier that stopped them still holds.
- **3:** Incumbents, providers or funded startups cover parts of the job. The segment or job is niche, cross-platform, regional or fast-moving enough that a focused product can serve some users better. Cite your search, including recent funding rounds.
- **5:** Incumbents and funded teams are structurally unlikely to serve it: too small for venture money, spread across several platforms, regional, or against their business model. Nothing ships today. Previous attempts stalled for reasons that no longer apply. Cite your search.

This score must cite a fresh search of incumbent, provider and startup activity, and name any previous attempts found. A score above 2 that rests on memory alone breaks the evidence cap.

### 7. Why now and trajectory
What recently changed to open this area, and which direction is it moving? Investors ask "why now?" of every pitch, because ideas that were always possible and never worked are usually tarpits. A change that just happened also opens a window: the first product to fit a newly possible job can keep an unusually loyal first cohort, until the next model or an incumbent makes the job easy for everyone.
- **1:** Nothing has changed recently; the idea was equally possible years ago. Or the trend is flat or shrinking (falling user numbers, a sunset rule, a platform in decline).
- **3:** A dated recent change (a capability, a price drop, a platform launch, a rule or a behaviour shift within the last 18 months) makes the area newly practical, and the segment or job is stable or growing.
- **5:** A change within the last 12 months makes the core job newly practical, adoption of the underlying behaviour is visibly growing (sourced), and the window before incumbents or providers close it looks like at least 6–12 months.

### 8. Upside
The builder is patient, so this is not about near-term revenue. It checks two things investors care about, adapted to a builder who needs a worthwhile prize rather than a fund-returning one: do people already pay for this job, and is there enough room to justify years of focus? Do not estimate market size; cite spend you can see.
- **1:** No evidence anyone pays for anything in this area, and the population is small. Users accept only free tools.
- **3:** Users pay for adjacent tools or services, a self-serve price point is plausible, and the segment is large enough that a small share would sustain the builder.
- **5:** Sourced evidence that self-serve AI products in this area are being paid for, or that buyers already pay freelancers or agencies to do the job (an existing budget line for the outcome), and success in the first segment opens adjacent segments or regions.

### 9. Founder fit
Most of YC's top companies came from ideas the founders met in their own work, because insiders see real problems and reach users cheaply. Scored against the user background in `scope.md`. If no background was given, score 3 and say so.
- **1:** Unfamiliar domain, no access to the users, and no relevant building experience.
- **3:** Adjacent experience, or access to the user community.
- **5:** The user has lived the job, belongs to the user community or already has an audience there, and holds an insight about it that outsiders lack.

### 10. Advantage fit
Does this area reward what this builder does better than a funded team? Score how much each of the three edges in the builder profile pays off here. An area can be attractive in general but reward the wrong things, such as enterprise sales, a large support team or a single big launch.
- **Speed:** the area moves fast (frequent model or platform changes, short windows), so shipping several probes in the time a funded team ships one is a real advantage.
- **Low operating load:** products here can be left running unattended, so the builder can keep many small probes alive at once, each holding its audience or rankings.
- **Patience:** the payoff compounds slowly (search traffic, community trust, accumulated data or content), which deters competitors who need fast returns.

- **1:** The area rewards none of the three, or rewards their opposites: big launches, sales teams, heavy service.
- **3:** One edge clearly pays off here and the others are neutral.
- **5:** All three edges pay off: windows are short, probes can run unattended for months, and value accumulates slowly in a way that keeps impatient competitors out.

## Area knockouts

An area is dropped, whatever its score, if any of these is true:

- A knockout criterion is below its threshold (#2 < 3, #3 < 2, #4 < 3, #6 < 2).
- A licence, accreditation or regulatory approval is needed before anyone can try any product in the area.
- The data the core job needs can't be obtained legally or practically, even with the user's consent.
- Every product shape in the area depends on a single platform that can cut off access and offers no alternative.

## Screen rule (Stage 4)

The screen is pass/kill only. Kill an area if any knockout is clearly true. When in doubt, pass it: Stage 5 is better equipped to judge borderline areas.
