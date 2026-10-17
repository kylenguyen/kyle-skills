# kyle-skills

A collection of [Agent Skills](https://docs.claude.com/en/docs/claude-code/skills) for Claude Code. Each skill is a self-contained folder under `skills/` with a `SKILL.md` entry point that Claude loads when a request matches the skill's description.

## Skills

| Skill | What it does |
|---|---|
| [ai-opportunity-scout](skills/ai-opportunity-scout/SKILL.md) | Generates AI-native business opportunities within a given scope, then narrows them through evidence-based gates, a four-specialist execution deep-dive and a red team down to the 3 strongest, each with a validation plan. Orchestrates roughly 30–70 sub-agents depending on depth. |

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

`ai-opportunity-scout` confirms the scope and the approximate sub-agent count before it spends any tokens, then writes all outputs to `./opportunity-scout-runs/<YYYY-MM-DD>-<scope-slug>/` in your current directory. The final `report.md` contains the top 3 ideas, one-pagers, score movement and a funnel report showing why every other idea was killed.

Token cost scales with depth (`quick` ~30 sub-agents, `standard` ~45, `deep` ~70). Start with `quick` to try it out.

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
