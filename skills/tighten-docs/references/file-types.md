# File types

Read before Stage 3. Categories come from `scripts/inventory.sh`. Never create, rename or delete files; suggest such changes in the notes instead, because they break links the invariant check cannot see.

## Summary

| Category | Included | Files |
|---|---|---|
| `agent` | Default | AGENTS.md, CLAUDE.md, GEMINI.md, `.cursorrules`, `.cursor/rules/*.mdc`, `.github/copilot-instructions.md`, SKILL.md and the Markdown files beside it (`prompts/`, `references/`, `templates/`), `.claude/agents/*.md`, `.claude/commands/*.md` |
| `doc` | Default | README, CONTRIBUTING, `docs/**`, CONTEXT.md, runbooks, other Markdown, reStructuredText and AsciiDoc |
| `template` | Default | `.github/ISSUE_TEMPLATE/*`, pull request templates |
| `comments` | When the scope is a code directory or the prompt asks | Comments and docstrings in source files |
| `config` | On request | Comments in YAML, TOML, INI, Dockerfile, Makefile, Terraform, `.env.example` |
| `schema` | On request | Prose fields in `package.json`, OpenAPI, AsyncAPI, JSON Schema |
| `notebook` | On request | Markdown cells in `.ipynb` |
| `strings` | On request | Source-language i18n files |
| `exclude` | Never | See the end of this file |

Help text and error messages inside source files are also on request ("also tighten the help text"). They are string literals, so the program's output changes.

## agent

- Frontmatter: keep every key and the `name` value exactly. The `description` is the trigger: keep every trigger phrase and any "not for" clause; tighten only the connecting words. In `.mdc` files keep `globs` and `alwaysApply`; in `.claude/agents` keep `tools` and `model`.
- Prompt templates: keep placeholders, output paths, the list of files to read and the return instructions.
- Output templates: keep placeholders and the heading structure the skill fills in.
- AGENTS.md and CLAUDE.md accumulate rules over time. Merge duplicates, group by topic, and cut rules about things that no longer exist (check first).
- A skill's SKILL.md holds the flow and its `references/` hold detail. When the same text is in both, keep it where it belongs and point to it from the other.

## doc

- Keep commands, install steps and their order, badges, and anchors linked from elsewhere (`grep -rn '#anchor'`).
- Open with what it is and how to use it.

## template

- Keep field headings, checkboxes and frontmatter (`name`, `about`, `labels`). HTML comments are instructions to whoever fills in the template; tighten them.

## comments

- Change comment and docstring text only. Delete comments that restate the code; keep ones that say why, warn, or state an invariant or link to an issue.
- Never change code, string literals (unless help text is in scope), directives (`noqa`, `eslint-disable`, `shellcheck`, `@ts-`, `type: ignore`), shebangs, licence headers, docstring structure (`Args:`, `Returns:`, `@param`, `:param`), doctest lines (`>>>`) or type comments.
- Help text and error messages, when in scope: before changing a string, `grep -rnF` the repo for it. If tests, snapshots, docs or alert config match it, leave it and list it in the notes.

## config

- Comments only. Leave directives (`# syntax=`, `# hadolint`, `# yamllint`, `# renovate:`) and commented-out entries.

## schema

- Change only `description`, `summary` and `title` values. Keys, enums, defaults and examples stay.
- Tool and API descriptions steer models as much as a SKILL.md does, so these files always get the Stage 5 review.
- After editing, check the file still parses: `jq empty file.json`, or `python3 -c 'import sys, yaml; yaml.safe_load(open(sys.argv[1]))' file.yaml`.

## notebook

- Markdown cells only. Edit with the NotebookEdit tool or `jq`, never as plain text, and never touch code cells or outputs.

## strings

- Source language only. Keys and placeholders (`{name}`, `%s`, `{{count}}`) stay. List every changed key in the notes, because translations of those keys are now stale.

## exclude

Always skipped, because their length or exact wording is the point:

| Files | Reason |
|---|---|
| CHANGELOG, HISTORY, ADRs (`adr/`, `decisions/`) | Historical by design |
| LICENSE, NOTICE, COPYING, SECURITY.md, CODE_OF_CONDUCT | Legal or policy wording |
| Fixtures, `testdata/`, snapshots | Tests match them |
| Lockfiles, generated, minified, vendored and build output | Not written by hand |
