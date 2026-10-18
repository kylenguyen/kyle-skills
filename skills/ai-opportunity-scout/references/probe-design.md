# Probe design (Stage 6)

A probe is a small, time-boxed experiment that puts something real in front of an area's users and measures what they do. The aim is to learn what the market wants as cheaply as possible, not to launch a company. Each probe answers one question in the area's learning agenda, and its result decides the next move.

Search for every time-sensitive point (marketplace rules and review times, platform terms, model prices, conversion benchmarks); `freshness.md` section 2 lists them. Tag evidence as `[F]`, `[I]`, `[A]` or `[M]`.

## 1. What every probe states

| Field | What to write |
|---|---|
| Question | The one thing this probe will teach, from the learning agenda |
| Shape | A probe type from section 2, and what the user sees |
| Build | Days of building, and the stack in one line |
| Operating load | Hours per week once live, and what those hours are spent on |
| Cost cap | Cash for tools, hosting and inference over the time box, with a hard spending limit set at the provider |
| Channel | Where it is put in front of users, with an estimate of reach |
| Signal metric | One behavioural metric from the signal ladder (section 3) |
| Thresholds | Double down / iterate / move on, as numbers |
| Time box | How long it runs before the decision, usually 2–4 weeks |
| Teaches even if it fails | What you know afterwards regardless of the outcome |

## 2. Probe types

Cheapest first. Use the cheapest type that can answer the question.

| Type | Build | Operating load | Signal it can give | Best when |
|---|---|---|---|---|
| Content or community post | Hours | None | Whether the problem resonates, and how users describe it | Before building anything, to test the job and the wording |
| Fake door: landing page with a price and a sign-up or pre-order | 1–2 days | None | Demand for a specific promise at a specific price | Testing positioning and price before building |
| Free single-job tool: a generator, checker or converter | 3–7 days | Very low | Usage and repeat use on the core job | The job can be done in one step, and search or communities can bring users |
| Thin working product | 1–2 weeks | Low if fully self-serve | Activation, retention and payment | The fake door or tool passed, or the job needs a real workflow to test |
| Marketplace add-on: a browser extension, app-store or plugin listing, or an AI assistant plugin | 1–2 weeks plus review | Low | Installs and retention from demand the marketplace already has | The users already work inside that platform; check review times and policies first |
| Developer surface: API, CLI, open-source repo or MCP server | Days | Low | Real usage, issues and requests | The users are developers or technical operators |
| Concierge (Wizard of Oz) | Days | High, so time-box it | What the job really involves | Only to learn the job: at most 2 weeks and 5 users, then automate or drop it |

A concierge probe breaks the low-ops rule if it runs past its time box. Flag it in the playbook and state the automation step that replaces it.

## 3. Signal ladder

Strongest first. A continue decision (double down or iterate) must rest on a signal at the activation level or above. Views, likes and stars may only decide wording and positioning tests.

1. Money: payment, a pre-order or a deposit.
2. Repeat use: the same user doing the core job again, unprompted, in a later week.
3. Activation: a new user completing the core job once.
4. Committed sign-up: sign-up plus a stated use case, or an answer to a question that costs effort.
5. Sign-up or waitlist.
6. Views, clicks, likes or stars.

Two ways AI probes mislead, and how to read past them:

- AI tourists. New AI tools attract people who try anything once and leave. Investors now rebase retention to month 3 and treat that as the committed base (`vc-principles.md`). Probes are shorter, so measure repeat use from week 2 onwards among users who activated, and ignore the launch-week spike when setting thresholds.
- Averages hide the well. Break every metric down by segment and channel. One segment that repeats far more than the rest is the most valuable thing a probe can find: it says who wants this right now, and the next probe should narrow to them. A flat, uniformly weak curve across every segment is a move-on signal, not an iterate.

## 4. Thresholds

Set every threshold before the probe launches. Once you have seen the numbers, it is too easy to find reasons why a weak result is encouraging.

- Give three outcomes: double down (move to the next probe in the sequence, or invest more in this one), iterate (change one thing and rerun once), and move on (follow the pivot map).
- Anchor thresholds on searched benchmarks where they exist, such as typical landing-page conversion for the channel, or extension or plugin retention. Tag them `[F]`. Where no benchmark exists, set a modest threshold, tag it `[A]` and say so.
- State the denominator: "8% of visitors from the community post", not "8%".
- Minimum sample: the time box must be long enough to reach roughly 100 visitors or 20 users for the metric, or the outcome is "iterate on the channel", not a verdict on the product.

## 5. Low-ops design rules

Check every probe against these rules. A probe that breaks one must say so and give the reason.

1. Self-serve: users sign up, set up and get value without a call or a human step.
2. No per-user human review: the user checks the AI output, or the output is low-stakes.
3. Errors are visible to the user and cheap to fix; nothing is filed, sent or paid on the user's behalf without their confirmation.
4. No promised support level: help by docs and email at best effort, stated on the page.
5. Billing by card through a standard provider, and no invoicing.
6. A hard monthly spending cap on every provider account, and per-user rate limits.
7. Hold as little user data as possible. Avoid sensitive personal data, and state retention.
8. Every probe can be switched off or left running with no maintenance for a month.

## 6. Sequencing and the pivot map

- The first probe should ship within 7 days of starting and need no prior probe.
- Aim the first probe at the area's `urgent_subsegment`, not the whole segment. A narrow group that urgently wants the job gives clearer signal than a broad group that mildly wants it.
- Order the probes so that the riskiest assumption is tested first in the cheapest way, usually problem resonance, then demand for a promise, then use, then payment.
- Each probe should reuse something from the one before: audience, code, data or wording. This is what keeps pivots inside an area cheap.
- At most 3 probes live at once, per the builder profile.
- The pivot map lists the likely signals and the move each triggers. Draw the moves from the area's seeds and `adjacent_shapes`: for example, "users love the output but won't connect their accounts → switch from integration to upload-based tool", or "the developer segment activates, the finance segment doesn't → retarget the next probe at developers".
- Each probe should leave an asset behind even if it fails: an audience list, search rankings, a labelled dataset, an eval set or reusable code. Name it in "Teaches even if it fails".
- Exit criteria: say when to leave the area entirely, for example "three probes in a row land on move on" or "no channel reaches 100 target users in 4 weeks".

## 7. Specialist output format

Both specialists' files have these parts:

1. A header: area ID, specialist, date, and search status (`ok`, `partial` or `unavailable`).
2. The numbered sections for the specialist (below), with tagged evidence.
3. **Candidate probes:** 3–6 probe ideas with the section 1 fields this specialist can fill in. Leave the rest for the synthesiser.
4. **Score:** 1–5 for this dimension (higher means better for a low-ops, fast-signal builder), with a two-line justification.
5. **Key numbers:** figures the other specialist may depend on, such as reach per channel, review time, build days, inference cost per active user and operating hours per week. The synthesiser compares these.
6. **Knockouts found:** any area knockout from the rubric, or "None".
7. **Open questions.**

### Channel and signal sections
1. **Where the users are:** specific surfaces (communities, marketplaces, search terms, newsletters, events), approximate reach, and each surface's rules on self-promotion.
2. **Existing demand:** threads asking for this, marketplace listings in the area with install counts, ratings and complaints, and signs of search interest.
3. **What they pay today:** self-serve price points for tools and services in the area.
4. **Signal design:** for each candidate probe, the metric, a benchmark if one exists, and proposed thresholds.
5. **False-signal risks:** where a probe could look good without real demand, such as launch-day spikes, curious developers signing up for anything new, or friends-and-network bias.
6. **Channel risks:** review times, listing policies, bans on promotion, and dependence on one platform's algorithm.

### Build and operations sections
1. **Buildable shapes:** probe shapes that fit the builder's window, with the stack, current model choice (from `landscape.md` or a search) and build days per component.
2. **Operating load once live:** per-user human work, support, failure handling, and what would make the load creep upwards.
3. **Running cost:** inference and hosting cost per active user per month at current prices (sourced), the worst case, and the caps that bound it.
4. **Dependencies and platform risk:** the APIs, platform terms and review processes each shape depends on, and the alternative if access is cut.
5. **Data and safety:** what user data each shape touches, data protection duties (PDPA, GDPR or local equivalents), and how to keep errors low-stakes.
6. **Quality bar:** how good the output must be for the probe to be useful, and the cheapest way to check before launch. Include the smoke test if it is enabled.
7. **Reuse across probes:** components that make later probes cheaper, such as shared ingestion, prompts, evals or a landing-page kit.

## 8. The opening round

Investors pick by conviction because they can't run experiments cheaply. This builder can, so the run lets the market choose between finalists. The judge picks one opening probe per finalist area (at most the builder's parallel-probe limit) and runs them side by side over the same time box. Opening probes should be the cheapest type that can reach at least the activation rung, so they can be compared like for like.

The focus rule, written before launch:
1. Focus on the area whose opening probe reached double down. If more than one did, pick the one whose best signal sits higher on the ladder, then the one with a standout segment, then the higher #9 founder fit.
2. If none reached double down but some reached iterate, rerun the strongest one once with its one change, and drop the rest.
3. If every opening probe lands on move on, check the sample: if any probe missed its minimum sample, iterate on the channel once. Otherwise go to the next ranked areas, or rerun the scout with a changed scope.

Keep only the focus area's probe running afterwards, unless another costs nothing to leave live and is still collecting an asset.
