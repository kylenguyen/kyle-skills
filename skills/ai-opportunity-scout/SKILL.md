---
name: ai-opportunity-scout
description: Find promising AI product areas to explore within a given scope (industry, function, user type, region or the user's own expertise), and design cheap, low-maintenance prototype probes to test each one in the market. Generates many seed ideas, clusters them into opportunity areas wide enough to pivot within, scores the areas on signal speed, operating load and pivot room, red-teams them, and recommends a starting area with a sequenced probe plan, signal thresholds and a pivot map. Also reviews probe results on a later visit and picks the next move. Use this skill whenever the user wants to brainstorm, discover, evaluate or shortlist AI business or product ideas, AI side projects, indie or bootstrapped AI products, what to prototype or build next, "where can AI replace manual work in X", or which AI directions in a domain are worth exploring, even if they don't say "business idea" explicitly.
---

# AI Opportunity Scout

Find a good place to start building, not a finished business plan. Products are found by shipping something specific, watching what users do, then improving or pivoting. Desk research can't tell you which product will work. It can tell you which areas are worth exploring, and which first experiments will give honest signal fastest. That is what this skill produces.

The unit of output is an **opportunity area**: a user segment, a recurring job they struggle with, and a recent shift that makes AI useful for it. A good area is wide enough to hold several product shapes, so a failed first prototype leads to a pivot inside the area rather than a fresh start. Inside each area, the skill designs **probes**: small prototypes or tests, each buildable in days and cheap to leave running, each with a pre-agreed threshold that decides whether to double down, iterate or move on.

Why areas and not single ideas: when the unit is a single idea, every gate rewards narrowing it until it survives scrutiny. The survivors end up as small niches that only work with an expert attached, have no room to pivot, and need a lot of human work to run. Scoring areas keeps the options open until the market, not the desk research, picks the product.

## Builder profile

The rubric and probe design assume the builder below. Show these defaults in the scope confirmation and let the user change them, because they decide which areas pass.

| Trait | Default | Where it bites |
|---|---|---|
| Build speed | Ships a working prototype in 1–2 weeks with AI coding tools | #7 prototype cost; probe build windows |
| Operating load per live probe | 2 hours a week at most; no per-customer human review, onboarding or services | #4 low-ops fit (knockout) |
| Return horizon | Patient; no need for near-term revenue | #8 is a light check that a path to revenue exists |
| Sales appetite | Self-serve, marketplace and community channels; no enterprise procurement | #3 signal speed (knockout) |
| Cash per probe | Under SGD 500 for tools, hosting and inference | Probe cost caps |
| Parallel probes | Up to 3 live at once | Probe sequencing |

## Freshness comes first

AI capability, model pricing, competitors, incumbent roadmaps and marketplace rules change month to month. Your training data is out of date for all of them. Read `references/freshness.md` before starting. It defines which facts must come from a current search, how to tag and date evidence, how to budget searches, and what to do when search is unavailable. Every prompt in `prompts/` already references it. Stage 1 builds a shared, dated snapshot so sub-agents start from current facts instead of each re-deriving them from memory.

## Inputs

Collect these from the user's prompt. Ask one short question only if both the domain and the target users are missing, or if the user background is missing (ask once). Default everything else and show the defaults in the scope confirmation.

| Input | Default |
|---|---|
| Domain or scope (industry, function, workflow) | At least one of domain or target users is required |
| Target users (role, segment, B2B/B2C, firm size) | Left open for the run to find segments |
| Region or market | Global, with Singapore/SEA noted where relevant |
| User background: industry knowledge, communities they belong to, any audience | Ask once; if declined, #9 is scored neutral (3) |
| Builder profile | The defaults above |
| Exclusions (sectors, ideas already tried) | None |
| Depth | `standard` |
| AI smoke test during probe design | Off (opt-in) |

Ask for the background even if the scope looks complete. It changes the result more than any other input: insider knowledge of an industry or membership of a user community makes probes faster and their signal easier to read.

### Depth settings

| Depth | Seeds generated | Areas after clustering | Into probe design | Final | Approx. sub-agents |
|---|---|---|---|---|---|
| quick | 30 | 6–8 | 2 | 1 primary + 1 alternate | ~20 |
| standard | 50 | 8–12 | 3 | 1 primary + 2 alternates | ~26 |
| deep | 80 | 12–16 | 4 | 1 primary + 2 alternates | ~33 |

Tell the user the approximate sub-agent count in the scope confirmation, because token cost scales with it.

## Run folder

Create `./opportunity-scout-runs/<YYYY-MM-DD>-<scope-slug>/` in the current working directory. Every stage writes its output there, which lets a run resume from any stage and keeps a record of why each area was dropped. Keep `run-log.md` updated with the stage, timestamp, sub-agent count and whether web search was available.

### Resuming

Runs can pause on usage limits. Before launching any sub-agent, check whether its output file already exists and is complete, and skip it if so. Never have two live sub-agents with the same output path: parallel writers to one file overwrite each other's work. If a sub-agent must be relaunched, tell it to overwrite the partial file.

## How to spawn sub-agents

Each stage has a prompt file in `prompts/`. Read it, fill in the `{placeholders}`, and pass the result to the Agent tool. Always fill `{SKILL_DIR}` (the absolute path of this skill directory), `{RUN_DIR}` and `{TODAY}`. The stage-specific ones are:

| Placeholder | Used in | Value |
|---|---|---|
| `{SCOPE_SUMMARY}` | landscape | A few lines from `scope.md` |
| `{LENS}`, `{N}` | generator | The lens name, and the depth's seed count divided by 5 |
| `{AREA_IDS}`, `{BATCH}` | screener, analyst, judge | The area IDs for this agent, and the batch number for the screener |
| `{AREA_ID}` | probe-channel, probe-build, synthesiser, red-team | One area ID |
| `{SMOKE_TEST}` | probe-build | `on` or `off`, from `scope.md` |
| `{N_ALTERNATES}` | judge | 1 at quick depth, 2 otherwise | Launch every independent sub-agent in a stage in a single message so they run in parallel. Sub-agents write their results to the paths given in the prompt and return a short summary. Read the files, not just the summaries.

## Pipeline

```
0 Scope ─► 1 Landscape ─► 2 Seeds ─► 3 Cluster ─► 4 Screen ─► 5 Score ─► 6 Probe design ─► 7 Red team ─► 8 Judge ─► Report
  brief     snapshot      5 lenses    into areas   knockouts   evidence   2 specialists      per area      rank        playbooks
                                                                         + synthesiser
```

### Stage 0: Scope brief (main agent)

Write `scope.md`: domain, target users, region, user background, builder profile, exclusions, depth, smoke test on or off, today's date. Show it to the user in a few lines and wait for confirmation before spawning anything. A wrong scope or builder profile wastes the whole run, and confirming costs one message.

### Stage 1: Landscape snapshot (1 sub-agent, `prompts/landscape.md`)

The sub-agent researches the current state of AI and the scope, and writes `landscape.md`: current models and what they now do reliably, API pricing, provider and incumbent launches, AI startups and small self-serve AI products in the scope, the distribution surfaces where the scope's users find tools (marketplaces, app stores, plugin directories, communities) and their rules, self-serve price points, and relevant regulation. Every claim carries a source and a date. Later stages treat this file as the baseline and search further only for what it doesn't cover.

### Stage 2: Seeds (5 parallel sub-agents, `prompts/generator.md`)

Run one sub-agent per lens in `references/lenses.md`. Each lens produces one fifth of the depth's seed count (pass it as `{N}`), in the seed format in `references/idea-schema.md`, written to `seeds/lens-<name>.json`. A seed is a concrete product shape with a light evidence anchor. Seeds are raw material for clustering, so variety matters more than polish.

### Stage 3: Cluster into areas (main agent)

Group the seeds into opportunity areas using the area schema in `references/idea-schema.md`, and write `areas.json`. This step decides what the rest of the run evaluates, so take care with it:

1. Define each area by segment, job and shift, not by a product. "IRAS R&D claim evidence pack from Git and Jira" is a seed. Its area is wider: "turning engineering activity into the reports non-engineers need" holds R&D claims, capitalisation schedules, client status reports and release notes for customers.
2. Test the width. You should be able to name the user, the recurring job, and at least three product shapes that serve that user's job. If you can't name three shapes, the area is too narrow. If the users or the job differ across the shapes, the area is too wide ("AI for SMEs"), so split it.
3. Prefer areas with seeds from two or more lenses. Independent lenses landing on the same job is evidence the job is real. An area with only one or two seeds may stay if you can name adjacent shapes; mark it `thin`.
4. Add `adjacent_shapes`: product shapes that fit the area but that no generator proposed. Probe design draws on these.
5. Drop anything in the exclusions. Record seeds that fit no area as `unclustered` for the funnel report.

Aim for the area count in the depth table.

### Stage 4: Area screen (parallel sub-agents, ~5 areas each, `prompts/screener.md`)

A cheap pass/kill check of each area against the knockouts in `references/rubric.md`: #2 AI step change, #3 signal speed, #4 low-ops fit and #6 room for a small builder. The screener relies mainly on `landscape.md` and runs a targeted search only when a knockout depends on something the snapshot doesn't cover. Write `screen/batch-<n>.json` and merge into `screen.json`. When in doubt, pass the area.

### Stage 5: Area scoring (1 sub-agent per 2 areas, `prompts/analyst.md`)

Score all 9 criteria in `references/rubric.md` with researched evidence. Write one file per area to `scoring/<area-id>.md`. Apply the knockouts, rank by weighted score, and keep the probe-design count for the chosen depth. If two areas tie within 0.25 for the last place, prefer the one with higher #3 signal speed.

### Stage 6: Probe design (2 specialists + 1 synthesiser per area)

For each shortlisted area, launch two specialists in parallel. Each follows `references/probe-design.md`.

| Specialist | Prompt | Output |
|---|---|---|
| Channel and signal: where the users are, how to reach them without sales, what signal to trust | `prompts/probe-channel.md` | `probes/<area-id>/channel.md` |
| Build and operations: what can be built in the build window, what it costs to run, what creates human work (runs the smoke test if enabled) | `prompts/probe-build.md` | `probes/<area-id>/build.md` |

Launch both specialists for all shortlisted areas in a single message. When both reports for an area are in, launch the synthesiser (`prompts/synthesiser.md`). Its first job is to reconcile the two. A typical conflict: channel wants a marketplace add-on, but build finds a six-week review queue, or build proposes a tool that needs a human to clean each user's data. It then designs 3–5 sequenced probes and a pivot map, and writes `probes/<area-id>/playbook.md` using `templates/area-playbook.md`.

### Stage 7: Red team (1 sub-agent per area, `prompts/red-team.md`)

Each attacker argues that the area is a trap: probes that will produce false signal, human work hidden in the design, a hard ceiling, or an incumbent about to bundle the job. It runs a fresh competitor and incumbent search, because days or weeks may have passed since Stage 1. Output: `redteam/<area-id>.md`.

### Stage 8: Judge (1 sub-agent, `prompts/judge.md`)

The judge rescores all 9 criteria for each area using the playbook and the red team, applies the knockouts, ranks the areas, and picks one primary area and the alternates. It also names the single first probe to ship. It must justify every score change from Stage 5. Output: `final.json`.

### Report (main agent)

Write `report.md` with:

1. **Start here:** the primary area in two lines, the first probe, what it costs, when it can ship, and the date by which its signal decides the next move. Then each alternate in two lines, the run date and the search status.
2. One area brief per finalist, using `templates/area-brief.md`.
3. A score-movement table: each area's Stage 5 score next to its final score.
4. A funnel report from `templates/funnel-report.md`: every area and where it stopped, and which area each seed went to.

In chat, give the user the start-here recommendation and the path to `report.md`. Offer to publish the report as a page if they plan to share it.

## After the run: reviewing probe results

The build-measure-pivot loop continues after the report. When the user comes back with probe results for a run, don't rerun the funnel:

1. Read the run's `report.md` and the area's `probes/<area-id>/playbook.md`.
2. Append the results to `probe-log.md` in the run folder: the probe, dates, the numbers observed, and what users said.
3. Apply the playbook's thresholds as written. Say plainly which outcome was reached (double down, iterate or move on), even if it's disappointing. The thresholds were set in advance so that a hopeful reading can't override them.
4. Use the pivot map to propose the next probe. If the result matches no row, design one new probe using `references/probe-design.md`.
5. If more than 4 weeks have passed since the run, run a quick fresh search for competitor and incumbent launches in the area before recommending a move.
6. If the area's exit criteria are met, recommend the next alternate from the report.

## What this skill can and cannot conclude

Desk research cannot establish whether users will adopt a product or pay for it. Probes can. So the skill doesn't claim a winner. It ranks where to start and what to try first, and each finalist's thresholds are the decision rule for what happens next. Scores are relative to the builder profile in `scope.md`: an area knocked out for its operating load might suit a builder willing to run a service.

The smoke test, if run, gives an indicative accuracy number on public or synthetic data. It shows whether the core AI task is plausible. It does not prove the product.

## Data handling

Sub-agents search the public web. Scope descriptions can contain internal context, such as a scope about the user's own company's operations. Put only generic, public framing into search queries, never internal names, figures or plans. The smoke test uses public or synthetic data only. If it needs an API key, it reads one already set in the environment. It never asks the user to paste a key and never prints one.

This skill designs probes. It never launches them: it does not post to communities, publish listings, sign up for services or spend money. The user runs every probe.
