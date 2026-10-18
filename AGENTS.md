# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor and similar) working in this repo.

## What this repo is

A collection of Agent Skills for Claude Code. There is no application code, build step or test suite. Every file is Markdown or JSON that an LLM reads at runtime, so the prose is the product: wording changes behaviour.

## Layout

```
skills/<skill-name>/
  SKILL.md        # required entry point
  prompts/        # sub-agent prompt templates (orchestrating skills only)
  references/     # material the skill reads on demand: rubrics, schemas, policies
  templates/      # output templates the skill fills in
```

Users install a skill by symlinking or copying `skills/<skill-name>/` into `~/.claude/skills/` or a project's `.claude/skills/` (see README.md). A skill folder must therefore be self-contained: never reference files outside its own directory.

## Skill conventions

### SKILL.md

- YAML frontmatter with exactly `name` and `description`. `name` matches the folder name, kebab-case.
- `description` is the trigger. Claude decides whether to load the skill from it alone, so state what the skill does and list the phrasings that should trigger it, including indirect ones ("even if they don't say X explicitly").
- The body is the runbook: inputs and defaults, stages in order, where each stage writes output, and what the skill can and cannot conclude.
- Keep SKILL.md focused on flow. Move long rubrics, schemas and checklists into `references/` and tell the agent when to read them ("Read it before Stage 3").

### Prompt templates (`prompts/`)

- One file per sub-agent role, titled `# Stage <n> — <role>`.
- Use `{UPPER_SNAKE}` placeholders. The shared ones are `{SKILL_DIR}` (absolute path to the skill), `{RUN_DIR}` and `{TODAY}`; add stage-specific ones (`{AREA_ID}`, `{LENS}`, `{N}`) as needed. When you add a placeholder, update the instructions in SKILL.md that fill it.
- Each prompt lists the files to read first, the exact output path, and what to return to the orchestrator (a short summary, not the full output).
- Reference shared policies by path (for example `{SKILL_DIR}/references/freshness.md`) rather than copying them into each prompt.

### Cross-file consistency

Skills here are tightly cross-referenced. Stage numbers, file paths, criterion numbers (#1 to #9), depth counts and knockout rules appear in SKILL.md, prompts, references and templates. When you change one, grep the skill folder and update every occurrence:

```bash
grep -rn "probes/" skills/ai-opportunity-scout/
```

## Writing style

- British/Singapore English spelling (synthesiser, prioritise), plain and direct.
- Explain the reason behind a rule in one sentence. Agents follow rules better when they know why, and it helps them handle edge cases.
- Prefer tables for inputs, defaults and comparisons; numbered steps for procedures.
- No emojis. Avoid heavy bold; reserve it for the one word that must not be missed.

## Data handling and safety

These skills are used inside FairPrice Group and drive sub-agents that search the public web.

- Never add real customer data, PII, internal system names, credentials, API keys or unpublished financials to any file, example or test fixture. Use synthetic or public examples.
- Any skill that searches must tell its agents to put only generic, public framing into queries.
- Any skill that needs an API key must read it from the environment and never ask the user to paste it or print it.
- Do not write skills that bypass authentication, disable security controls or take destructive actions without explicit user confirmation.

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter and body as above. Use the `skill-creator` skill if available.
2. Add supporting `prompts/`, `references/` and `templates/` only if needed. A simple skill can be a single SKILL.md.
3. Add a row to the Skills table in README.md.
4. Test it: install via symlink, start a fresh Claude Code session, and run two or three realistic prompts, including one that should not trigger the skill. Check it triggers correctly and that outputs land where SKILL.md says.

## Commits

- Short, lowercase, imperative subject lines, for example `add AI opportunity scout skill` or `tighten gate 2 knockout rules`.
- One skill per commit where practical.
- Do not commit run outputs (`opportunity-scout-runs/`) or other generated artefacts.
