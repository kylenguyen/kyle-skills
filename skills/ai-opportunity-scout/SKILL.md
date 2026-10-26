---
name: ai-opportunity-scout
description: Find the best AI product area for a fast, low-maintenance, patient builder to focus on next, within a given scope (industry, function, user type, region or the user's own expertise), and design cheap prototype probes that let the market confirm the choice. Generates many seed ideas, clusters them into opportunity areas wide enough to pivot within, and scores them the way early-stage investors such as Y Combinator screen startups (acute pain, why now, insight, prior attempts, founder fit), adapted to the builder's edges of speed, low operating load and patience. Red-teams the finalists, then recommends a primary area, an opening round of parallel probes with thresholds, a focus rule and a pivot map. Also reviews probe results on a later visit and picks the next move. Use this skill whenever the user wants to brainstorm, discover, evaluate or shortlist AI business or product ideas, AI side projects, indie or bootstrapped AI products, what to prototype or build next, which area or problem to focus on next, "where can AI replace manual work in X", or which AI directions in a domain are worth exploring, even if they don't say "business idea" explicitly.
---

# AI Opportunity Scout

Find a good place to start building, not a finished business plan: which areas are worth exploring, and which first experiments give honest signal fastest.

The unit of output is an **opportunity area**: a user segment, a recurring job they struggle with, and a recent shift that makes AI useful for it. A good area is wide enough to hold several product shapes, so a failed first prototype leads to a pivot inside the area rather than a fresh start. Inside each area, the skill designs **probes**: small prototypes or tests, each buildable in days, cheap to leave running, and with a pre-agreed threshold that decides whether to double down, iterate or move on.

Areas are scored the way an early-stage investor reads an application, adapted to this builder (`references/rubric.md`). Because this builder can test cheaply where an investor must pick by conviction, the run ends with an opening round of parallel probes and a focus rule that lets their results choose the focus area.

## Builder profile

The rubric and probe design assume the builder below. Show these defaults in the scope confirmation and let the user change them, because they decide which areas pass. The first three rows are the builder's edges over a funded team; #10 advantage fit rewards areas where they pay off.

| Trait | Default | Where it bites |
|---|---|---|
| Build speed | Ships a working prototype in 1–2 weeks with AI coding tools | #3 signal speed; #10 (speed edge); probe build windows |
| Operating load per live probe | 2 hours a week at most; no per-customer human review, onboarding or services | #4 low-ops fit (knockout); #10 (low-ops edge) |
| Return horizon | Patient; no need for near-term revenue | #8 upside checks for a worthwhile prize, not near-term revenue; #10 (patience edge) |
| Sales appetite | Self-serve, marketplace and community channels; no enterprise procurement | #3 signal speed (knockout) |
| Cash per probe | Under SGD 500 for tools, hosting and inference | Probe cost caps |
| Parallel probes | Up to 3 live at once | Probe sequencing |

## Freshness

AI capability, model pricing, competitors and marketplace rules change month to month, so your training data is out of date for all of them. Read `references/freshness.md` before starting: it sets which facts must come from a current search, how to tag evidence, and what to do when search is unavailable.

## Inputs

Collect these from the user's prompt, default the rest, and show the defaults in the scope confirmation. Ask one short question, once, only if:

- the user background is missing. Ask even when the scope looks complete: the background changes the result more than any other input, because ideas from the builder's own work outperform brainstormed ones.
- both the domain and the target users are missing. If the user gives a rich background instead, the background can be the scope.

| Input | Default |
|---|---|
| Domain or scope (industry, function, workflow) | At least one of domain or target users is required |
| Target users (role, segment, B2B/B2C, firm size) | Left open for the run to find segments |
| Region or market | Global, with Singapore/SEA noted where relevant |
| User background: industries and roles they have worked in, problems they have hit themselves, communities they belong to, assets (audience, code, data, products already live), and the AI workflows they already run day to day | Ask once; if declined, #9 is scored neutral (3) and the founder lens runs without context |
| Builder profile | The defaults above |
| Exclusions (sectors, ideas already tried) | None |
| Depth | `standard` |
| AI smoke test during probe design | Off (opt-in) |

### Depth settings

| Depth | Seeds generated | Areas after clustering | Into probe design | Final | Approx. sub-agents |
|---|---|---|---|---|---|
| quick | 35 | 6–8 | 2 | 1 primary + 1 alternate | ~21 |
| standard | 56 | 8–12 | 3 | 1 primary + 2 alternates | ~27 |
| deep | 84 | 12–16 | 4 | 1 primary + 2 alternates | ~34 |

Tell the user the approximate sub-agent count in the scope confirmation, because token cost scales with it.

## Run folder

Create `./opportunity-scout-runs/<YYYY-MM-DD>-<scope-slug>/` in the current working directory. Every stage writes its output there, so a run can resume from any stage. Keep `run-log.md` in it updated with the stage, timestamp, sub-agent count and whether web search was available.

### Resuming

Before launching any sub-agent, check whether its output file already exists and is complete, and skip it if so. Never have two live sub-agents with the same output path, because parallel writers overwrite each other. If a sub-agent must be relaunched, tell it to overwrite the partial file.

## How to spawn sub-agents

Each sub-agent stage has a prompt file in `prompts/`. Read it, fill in the `{placeholders}`, and pass the result to the Agent tool. Always fill `{SKILL_DIR}` (the absolute path of this skill directory), `{RUN_DIR}` and `{TODAY}`. The stage-specific ones are:

| Placeholder | Used in | Value |
|---|---|---|
| `{SCOPE_SUMMARY}` | landscape | A few lines from `scope.md` |
| `{LENS}`, `{N}` | generator | The lens name, and the depth's seed count divided by 7 (twice that for the founder lens) |
| `{AREA_IDS}`, `{BATCH}` | screener, analyst, judge | The area IDs for this agent, and the batch number for the screener |
| `{AREA_ID}` | probe-channel, probe-build, synthesiser, red-team | One area ID |
| `{SMOKE_TEST}` | probe-build | `on` or `off`, from `scope.md` |
| `{N_ALTERNATES}` | judge | 1 at quick depth, 2 otherwise |

Launch every independent sub-agent in a stage in a single message so they run in parallel. Sub-agents write to the paths given in the prompt and return a short summary. Read the files, not just the summaries.

## Pipeline

```
0 Scope ─► 1 Landscape ─► 2 Seeds ─► 3 Cluster ─► 4 Screen ─► 5 Score ─► 6 Probe design ─► 7 Red team ─► 8 Judge ─► Report
  brief     snapshot      6 lenses    into areas   knockouts   evidence   2 specialists      per area      committee   playbooks
                                                                         + synthesiser                     + opening round
```

### Stage 0: Scope brief (main agent)

Write `scope.md`: domain, target users, region, user background, builder profile, exclusions, depth, smoke test on or off, today's date. Show it to the user in a few lines and wait for confirmation before spawning anything, because a wrong scope or builder profile wastes the whole run.

### Stage 1: Landscape snapshot (1 sub-agent, `prompts/landscape.md`)

Writes `landscape.md`: a dated, sourced snapshot of current AI capability and pricing, incumbents, startups, capital flows, distribution surfaces and regulation in the scope. Later stages treat it as the baseline and search only for what it doesn't cover.

### Stage 2: Seeds (6 parallel sub-agents, `prompts/generator.md`)

Run one sub-agent per lens in `references/lenses.md`, writing to `seeds/lens-<name>.json`. Set `{N}` as in the placeholder table.

### Stage 3: Cluster into areas (main agent)

Group the seeds into opportunity areas using the area schema in `references/idea-schema.md`, and write `areas.json`. This step decides what the rest of the run evaluates:

1. Define each area by segment, job and shift, not by a product. "IRAS R&D claim evidence pack from Git and Jira" is a seed. Its area is wider: "turning engineering activity into the reports non-engineers need" holds R&D claims, capitalisation schedules, client status reports and release notes for customers.
2. Test the width: name the user, the recurring job and at least three product shapes that serve that job. If you can't name three shapes, the area is too narrow. If the users or the job differ across the shapes, the area is too wide ("AI for SMEs"), so split it.
3. Prefer areas with seeds from two or more lenses. Independent lenses landing on the same job is evidence the job is real. An area with only one or two seeds may stay if you can name adjacent shapes; mark it `thin`.
4. Add `adjacent_shapes`: product shapes that fit the area but that no generator proposed. Probe design draws on these.
5. Fill a rough first draft of `insight`, `urgent_subsegment`, `proxies` and `prior_attempts` from the seeds and `landscape.md`; the analyst checks them. When two candidate groupings are equally good, prefer the one that keeps a founder-lens seed in the area, because that is where the builder's insight is.
6. Drop anything in the exclusions. Record seeds that fit no area as `unclustered`.

Aim for the area count in the depth table.

### Stage 4: Area screen (parallel sub-agents, ~5 areas each, `prompts/screener.md`)

A cheap pass/kill check against the knockouts in `references/rubric.md`. Each writes `screen/batch-<n>.json`; merge them into `screen.json`.

### Stage 5: Area scoring (1 sub-agent per 2 areas, `prompts/analyst.md`)

Each analyst scores all 10 criteria in `references/rubric.md` with researched evidence and writes `scoring/<area-id>.md`. Apply the knockouts, rank by weighted score, and keep the probe-design count for the chosen depth. If two areas tie within 0.25 for the last place, prefer the one with higher #3 signal speed.

### Stage 6: Probe design (2 specialists + 1 synthesiser per area)

For each shortlisted area, launch two specialists:

| Specialist | Prompt | Output |
|---|---|---|
| Channel and signal | `prompts/probe-channel.md` | `probes/<area-id>/channel.md` |
| Build and operations (runs the smoke test if enabled) | `prompts/probe-build.md` | `probes/<area-id>/build.md` |

Launch both specialists for all shortlisted areas in a single message. When both reports for an area are in, launch the synthesiser (`prompts/synthesiser.md`), which reconciles them and writes `probes/<area-id>/playbook.md`.

### Stage 7: Red team (1 sub-agent per area, `prompts/red-team.md`)

Argues that the area is a trap, including a fresh competitor and incumbent search, because days may have passed since Stage 1. Output: `redteam/<area-id>.md`.

### Stage 8: Judge (1 sub-agent, `prompts/judge.md`)

Rescores, ranks and picks one primary area and the alternates, then designs the opening round, the focus rule and the single first probe. Output: `final.json`.

### Report (main agent)

Write `report.md` with:

1. **Start here:** the primary area in two lines, the first probe, what it costs, when it can ship, and the date by which its signal decides the next move. Then each alternate in two lines. Then the opening round as a table (area, probe, build days, cost cap, thresholds) with the focus rule beneath it, the run date and the search status.
2. One area brief per finalist, using `templates/area-brief.md`.
3. A funnel report from `templates/funnel-report.md`, including the score movement from Stage 5 to final.

In chat, give the user the start-here recommendation, the opening round in one line per probe, and the path to `report.md`. Offer to publish the report as a page if they plan to share it.

## After the run: reviewing probe results

When the user comes back with probe results for a run, don't rerun the funnel:

1. Read the run's `report.md` and the area's `probes/<area-id>/playbook.md`.
2. Append the results to `probe-log.md` in the run folder: the probe, dates, the numbers observed, and what users said.
3. Apply the playbook's thresholds as written and say plainly which outcome was reached (double down, iterate or move on), even if it's disappointing. They were set in advance so a hopeful reading can't override them. Break the numbers down by segment and channel, and call out any segment that repeats far more than the rest (`references/probe-design.md` section 3).
4. If these are opening-round results, apply the focus rule from `final.json` and name the focus area. Recommend switching off the other opening probes unless one costs nothing to leave live and is still collecting an asset.
5. Use the pivot map to propose the next probe. If the result matches no row, design one new probe using `references/probe-design.md`.
6. If more than 4 weeks have passed since the run, run a quick fresh search for competitor and incumbent launches in the area before recommending a move.
7. If the area's exit criteria are met, recommend the next alternate from the report.

## What this skill can and cannot conclude

Desk research cannot establish whether users will adopt a product or pay for it; probes can. So the skill doesn't claim a winner. It ranks where to start and what to try first, and the focus rule and thresholds decide what happens next. An area can score well on every criterion and still find no demand. Scores are relative to the builder profile in `scope.md`: an area knocked out for its operating load might suit a builder willing to run a service.

The smoke test, if run, gives an indicative accuracy number on public or synthetic data. It shows whether the core AI task is plausible, not that the product works.

## Data handling

Sub-agents search the public web, and scope descriptions can contain internal context. Put only generic, public framing into search queries, never internal names, figures or plans. The smoke test uses public or synthetic data only. If it needs an API key, it reads one already set in the environment; it never asks the user to paste a key and never prints one.

This skill designs probes. It never launches them: it does not post to communities, publish listings, sign up for services or spend money. The user runs every probe.
