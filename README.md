# kyle-skills

A collection of [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code. Each skill is a self-contained folder under `skills/` with a `SKILL.md` entry point that Claude loads when a request matches the skill's description.

## Skills

| Skill | What it does |
|---|---|
| [delegate-to-subagent](skills/delegate-to-subagent/SKILL.md) | Plans a feature as small self-contained tasks, then has a cheaper model (pi or omp running DeepSeek by default) implement them in throwaway Docker containers on a remote server, while Claude writes the briefs, reviews and merges. The wrapper runs the verify commands and guard checks on the diff itself, so review trusts measured results rather than the sub-agent's report. Modes: plan, execute a plan (one commit per task on a feature branch, conflicts resolved, end-to-end check), or delegate a single task. Never merges to `main`. |
| [ai-opportunity-scout](skills/ai-opportunity-scout/SKILL.md) | Finds the best AI product area for a fast, low-maintenance, patient builder to focus on next, and designs cheap prototype probes to test it. Generates seed ideas, clusters them into areas wide enough to pivot within, and scores them the way early-stage investors such as Y Combinator screen startups, adapted to the builder's edges. Recommends a primary area, an opening round of parallel probes with a focus rule, signal thresholds and a pivot map. Orchestrates roughly 21–34 sub-agents depending on depth. |

## Installation

### Prerequisites

- [Claude Code](https://docs.claude.com/en/docs/claude-code) installed and signed in.
- Web search available in your Claude Code session. `ai-opportunity-scout` depends on current facts; without search the run is marked degraded, time-sensitive claims are tagged as unverified and their scores are capped.
- For `delegate-to-subagent`: a Linux host with Docker, git and jq that you can reach by passwordless ssh, an API key for the sub-agent's model provider stored on that host, and `jq` locally. Claude Code can also run on that host itself (`server: local`, no ssh). One-time setup is in [server-setup.md](skills/delegate-to-subagent/references/server-setup.md).

### 1. Clone the repo

```bash
git clone <repo-url> ~/workspace/kyle-skills
```

### 2. Install the skills

Pick one option.

**Option A: personal install (all projects).** Symlink each skill into your user skills directory so `git pull` keeps them up to date:

```bash
mkdir -p ~/.claude/skills
for skill in ~/workspace/kyle-skills/skills/*/; do
  ln -sfn "$skill" ~/.claude/skills/"$(basename "$skill")"
done
```

**Option B: project install (one repo, shared with the team).** Copy the skills you need into the target project's `.claude/skills/` directory and commit them there:

```bash
mkdir -p /path/to/project/.claude/skills
cp -r ~/workspace/kyle-skills/skills/ai-opportunity-scout /path/to/project/.claude/skills/
```

### 3. Verify

Start a new Claude Code session (skills are discovered at session start) and ask:

```
What skills are available?
```

`ai-opportunity-scout` should appear in the list. You can also invoke it directly with `/ai-opportunity-scout`.

### Updating

- Option A: `git -C ~/workspace/kyle-skills pull`, then start a new session.
- Option B: re-copy the skill folder into the project.

### Uninstalling

```bash
rm ~/.claude/skills/ai-opportunity-scout   # removes the symlink only, not the repo
```

## Usage

Describe what you want in plain language; Claude picks the skill from its description. For example:

```
Find AI business opportunities in last-mile grocery logistics for SEA retailers. Depth: quick.
```

`ai-opportunity-scout` confirms the scope, your builder profile (build speed, operating-load ceiling, return horizon, channels) and the approximate sub-agent count before it spends any tokens. It then writes all outputs to `./opportunity-scout-runs/<YYYY-MM-DD>-<scope-slug>/` in your current directory. The final `report.md` names a primary area and the first probe to ship, sets out an opening round of parallel probes across the finalists with a rule for choosing which one to focus on, gives a brief for each area with its probe plan and pivot map, and includes a funnel report showing why every other area was dropped.

When you have run a probe, come back with the results (for example "P1 in the primary area got 140 visitors and 6 pre-orders"). The skill applies the thresholds set in the playbook and proposes the next move from the pivot map, without rerunning the funnel.

Token cost scales with depth (`quick` ~21 sub-agents, `standard` ~27, `deep` ~34). Start with `quick` to try it out.

For `delegate-to-subagent`, start with a plan, review it, then execute it:

```
Plan the CSV export feature as tasks for sub-agents.
Execute docs/csv-export-plan.md
```

Or hand over one change: `Delegate adding pagination tests for src/api/orders to a sub-agent.` Claude runs a preflight check (`delegate.sh doctor`) first. Execute mode works in a separate worktree on `feature/<feature>`, keeps its state in `.subagent-runs/` so an interrupted run can resume, stops to ask when spend reaches the run cap (USD 5 by default), and ends with a report of each task's status, fix-up rounds and cost.

## Data handling

Skills in this repo search the public web. Do not put Confidential or Secret data, customer PII, credentials or unpublished financials into a scope or prompt. Follow the FPG AI Acceptable Use Policy.

`delegate-to-subagent` sends the repo's contents and the task briefs to the sub-agent's model provider (DeepSeek by default). Only use it on code that policy allows you to share with that provider, and keep secrets out of tracked files.

## Repository layout

```
skills/
  <skill-name>/
    SKILL.md        # entry point: frontmatter (name, description) + instructions
    prompts/        # sub-agent prompt templates with {PLACEHOLDERS}
    references/     # rubrics, schemas, policies the skill reads on demand
    templates/      # output templates
    scripts/        # executables some skills run (shell scripts, Dockerfiles)
```

See [AGENTS.md](AGENTS.md) for conventions when adding or editing skills.
