# kyle-skills

A collection of [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code. Each skill is a self-contained folder under `skills/` with a `SKILL.md` entry point that Claude loads when a request matches the skill's description.

## Skills

| Skill | What it does |
|---|---|
| [ai-opportunity-scout](skills/ai-opportunity-scout/SKILL.md) | Finds AI product areas worth exploring within a given scope and designs cheap, low-maintenance prototype probes to test each one. Generates seed ideas, clusters them into areas wide enough to pivot within, scores the areas on signal speed, operating load and pivot room, and recommends a starting area with a sequenced probe plan, signal thresholds and a pivot map. Orchestrates roughly 20–33 sub-agents depending on depth. |

## Installation

### Prerequisites

- [Claude Code](https://docs.claude.com/en/docs/claude-code) installed and signed in.
- Web search available in your Claude Code session. `ai-opportunity-scout` depends on current facts; without search the run is marked degraded, time-sensitive claims are tagged as unverified and their scores are capped.

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

`ai-opportunity-scout` confirms the scope, your builder profile (build speed, operating-load ceiling, return horizon, channels) and the approximate sub-agent count before it spends any tokens. It then writes all outputs to `./opportunity-scout-runs/<YYYY-MM-DD>-<scope-slug>/` in your current directory. The final `report.md` names a primary area and the first probe to ship, gives a brief for each area with its probe plan and pivot map, and includes a funnel report showing why every other area was dropped.

When you have run a probe, come back with the results (for example "P1 in the primary area got 140 visitors and 6 pre-orders"). The skill applies the thresholds set in the playbook and proposes the next move from the pivot map, without rerunning the funnel.

Token cost scales with depth (`quick` ~20 sub-agents, `standard` ~26, `deep` ~33). Start with `quick` to try it out.

## Data handling

Skills in this repo search the public web. Do not put Confidential or Secret data, customer PII, credentials or unpublished financials into a scope or prompt. Follow the FPG AI Acceptable Use Policy.

## Repository layout

```
skills/
  <skill-name>/
    SKILL.md        # entry point: frontmatter (name, description) + instructions
    prompts/        # sub-agent prompt templates with {PLACEHOLDERS}
    references/     # rubrics, schemas, policies the skill reads on demand
    templates/      # output templates
```

See [AGENTS.md](AGENTS.md) for conventions when adding or editing skills.
