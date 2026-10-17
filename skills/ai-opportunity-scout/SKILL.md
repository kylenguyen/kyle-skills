---
name: ai-opportunity-scout
description: Find, stress-test and shortlist AI-native business opportunities within a given scope (industry, business function, buyer type, region or the user's own domain expertise). Generates a broad set of ideas where current AI capability beats existing solutions, then narrows them through evidence-based gates, a four-specialist execution deep-dive and a red team down to the 3 strongest, each with a validation plan. Use this skill whenever the user wants to brainstorm, discover, evaluate, compare or shortlist AI business ideas, AI startup or product opportunities, "where can AI replace manual work in X", AI venture or new-business ideation, or asks which AI ideas in a domain are worth pursuing, even if they don't say "business idea" explicitly.
---

# AI Opportunity Scout

Find AI business opportunities in a scope the user gives, then narrow them down until only the 3 strongest remain. The skill spends little on the many early ideas and a lot on the few that survive. Each gate uses more evidence and more sub-agents than the one before it.

The core question is the same as for any business: is the problem painful, and will someone pay? AI products add specific risks: the model may not be good enough yet, incumbents or model providers may ship the feature, and inference costs, liability and commodity models all affect the business. The rubric in `references/rubric.md` captures these risks. Read it before Stage 3.

## Freshness comes first

AI capability, model pricing, competitors and incumbent roadmaps change month to month. Your training data is out of date for all of them. An idea that looked like a gap at your training cutoff may already be a free feature in a mainstream product.

So the skill treats time-sensitive facts as things to look up, not things to remember. Read `references/freshness.md` before starting. It defines:

- which facts must come from a current search, and which may come from model knowledge;
- how to tag and date evidence;
- what to do when search is unavailable.

Pass the freshness rules to every sub-agent; each prompt in `prompts/` already references them. Stage 1 builds a shared, dated snapshot of the current landscape, so sub-agents start from current facts instead of each re-deriving them from memory.

## Inputs

Collect these from the user's prompt. Ask one short question only if the **domain** or the **target buyer** is missing. Default everything else and show the defaults in the scope confirmation.

| Input | Default |
|---|---|
| Domain or scope (industry, function, workflow) | Required |
| Target buyer (B2B, B2C, internal enterprise, SMB, segment) | Required |
| Region or market | Global, with Singapore/SEA noted where relevant |
| User background and unfair advantage | Ask once; if declined, criterion #9 is scored neutral (3) |
| Exclusions (sectors, ideas already tried) | None |
| Depth | `standard` |
| AI smoke test in the execution deep-dive | Off (opt-in) |

### Depth settings

| Depth | Ideas generated | After Gate 1 | Into deep-dive | Final | Approx. sub-agents |
|---|---|---|---|---|---|
| quick | 30 | 10 | 4 | 3 | ~30 |
| standard | 50 | 15 | 5 | 3 | ~45 |
| deep | 80 | 25 | 8 | 3 | ~70 |

Tell the user the approximate sub-agent count in the scope confirmation, because token cost scales with it.

## Run folder

Create `./opportunity-scout-runs/<YYYY-MM-DD>-<scope-slug>/` in the current working directory. Every stage writes its output there. This lets a run resume from any stage, and it keeps an audit trail of why each idea was killed. Keep `run-log.md` updated with the stage, timestamp, sub-agent count and whether web search was available.

## How to spawn sub-agents

Each stage has a prompt file in `prompts/`. Read it, fill in the `{placeholders}` (always include `{SKILL_DIR}` as the absolute path of this skill directory, `{RUN_DIR}` and `{TODAY}`), and pass the result to the Agent tool. Launch every independent sub-agent in a stage in a single message so they run in parallel. Sub-agents write their results to the paths given in the prompt and return a short summary. Read the files, not just the summaries.

## Pipeline

```
0 Scope ─► 1 Landscape ─► 2 Diverge ─► Dedupe ─► 3 Gate 1 ─► 4 Gate 2 ─► 5 Gate 3 ─► 6 Gate 4 ─► 7 Final ─► Report
  brief     snapshot       5 lenses     merge     quick kill   evidence    execution    red team    judge
```

### Stage 0: Scope brief (main agent)

Write `scope.md`: domain, buyer, region, user background, exclusions, depth, smoke-test on/off, today's date. Show it to the user in a few lines and wait for confirmation before spawning anything. A wrong scope wastes the whole run, and confirming costs one message.

### Stage 1: Landscape snapshot (1 sub-agent, `prompts/landscape.md`)

The sub-agent researches the current state of AI and the scope domain, and writes `landscape.md`. It covers:

- current frontier and open-weight models;
- what they can now do reliably;
- API pricing;
- recent launches by model providers and by incumbents in the domain;
- AI startups already in the domain and their funding;
- relevant regulation.

Every claim must carry a source and a date. Later stages treat this file as the baseline of current facts, and search further only for what it doesn't cover.

### Stage 2: Diverge (5 parallel sub-agents, `prompts/generator.md`)

Run one sub-agent per lens in `references/lenses.md`. Each lens produces one fifth of the depth's idea count (pass it as `{N}`), as candidates in the format in `references/idea-schema.md`, written to `candidates/lens-<name>.json`. Different lenses stop the list collapsing into 50 versions of "AI copilot for X".

**Dedupe (main agent):** merge near-duplicates (keep the richer entry and record the merged IDs), drop anything in the exclusions, and write `candidates.json`.

### Stage 3: Gate 1, quick kill (parallel sub-agents, ~10 ideas each, `prompts/screener.md`)

Each idea is checked pass/kill against three questions:

- **#1:** does it replace costly manual work, rather than add a nicer UI to existing software?
- **#2:** is AI plausibly good enough today, at the accuracy this buyer needs?
- **#4:** would it survive a model provider or incumbent shipping it as a feature within 6 months?

This gate is cheap on purpose. The screener relies mainly on `landscape.md` and runs targeted searches only when #4 depends on a recent launch the snapshot doesn't cover. Each kill gets a one-line reason. Screeners write `gate1/batch-<n>.json`; merge these into `gate1.json`. Keep the passing ideas up to the depth target, ranked by confidence.

### Stage 4: Gate 2, evidence scoring (1 sub-agent per 3 ideas, `prompts/analyst.md`)

Score all 9 core criteria from `references/rubric.md` with researched evidence: who does the work today, the hours and cost involved, the incumbents and their recent roadmaps, price benchmarks, and inference cost per task at current prices. Write one file per idea to `gate2/<id>.md`.

Apply the knockouts (#2 or #4 below 3 kills the idea), rank by weighted score, and keep the deep-dive count for the chosen depth.

### Stage 5: Gate 3, execution deep-dive (4 specialists + 1 synthesiser per idea)

This stage tests whether the idea can actually be built, sold and run, before final scoring. For each shortlisted idea, launch four specialist sub-agents in parallel. Each one covers one section of `references/feasibility-checklist.md`:

| Specialist | Prompt | Output |
|---|---|---|
| Business viability | `prompts/feas-business.md` | `gate3/<id>/business.md` |
| Technical feasibility (runs the smoke test if enabled) | `prompts/feas-technical.md` | `gate3/<id>/technical.md` |
| Operational feasibility | `prompts/feas-operations.md` | `gate3/<id>/operations.md` |
| Go-to-market and risk | `prompts/feas-gtm-risk.md` | `gate3/<id>/gtm-risk.md` |

Launch all specialists for all shortlisted ideas in a single message, up to 20 agents at standard depth. When all four reports for an idea are in, launch the synthesiser (`prompts/synthesiser.md`). The synthesiser's main job is to find contradictions between the specialists and resolve them. A typical example: business assumes two-week onboarding while operations finds a three-month integration. It then writes `gate3/<id>/dossier.md` using `templates/execution-dossier.md`.

Check the execution knockouts in the rubric. A knocked-out idea goes to the funnel report with its reason. It does not advance.

### Stage 6: Gate 4, red team (1 sub-agent per surviving idea, `prompts/red-team.md`)

Each attacker argues why the idea fails. It targets the dossier's 90-day plan and its weakest assumptions, and it re-checks the competitor and incumbent landscape with a fresh search. The re-check matters because days or weeks may have passed since Stage 1. Output: `gate4/<id>.md`.

### Stage 7: Final scoring (1 judge sub-agent, `prompts/judge.md`)

The judge rescores all 10 criteria (the 9 core criteria plus execution complexity) for every surviving idea, using the dossier and the red-team attack. It applies the knockouts, ranks the ideas, and picks the top 3. It must justify each change from the Gate 2 score. Output: `final.json`.

### Report (main agent)

Write `report.md` with:

1. A summary: the top 3 in two lines each, the run date, and whether search was available.
2. One one-pager per finalist, using `templates/one-pager.md`.
3. A score-movement table showing each idea's Gate 2 score next to its final score.
4. A funnel report from `templates/funnel-report.md`: every idea, the stage where it died, and the reason.

In chat, give the user the top 3 and the path to `report.md`. Offer to publish the report as a page if they plan to share it.

## What this skill can and cannot conclude

Desk research cannot verify accuracy on real customer data (#2) or willingness to pay (#3). It can only judge how plausible they are. Presenting those judgements as findings would mislead the user into skipping the most important validation. So every finalist's one-pager lists them as **unproven assumptions**, each paired with a concrete test: the sample size, the pass threshold, and the result that kills the idea.

The smoke test, if run, gives an indicative accuracy number on public or synthetic data. It shows whether the task is plausible. It does not prove the product.

## Data handling

Sub-agents search the public web. Scope descriptions can contain internal context. For example, a scope about the user's own company's operations might mention internal systems, volumes or roadmaps. Put only generic, public framing into search queries, never internal names, figures or plans. The smoke test uses public or synthetic data only, never customer or confidential data. If it needs an API key, it reads one already set in the environment. It never asks the user to paste a key and never prints one.
