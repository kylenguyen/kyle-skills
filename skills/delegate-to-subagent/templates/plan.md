# {Feature name} plan

Branch: `feature/{feature}`. Tasks run in dependency order; see `references/plan-format.md` in the delegate-to-subagent skill for the field rules.

## Shared context

- Stack: {language, framework, runtime versions}
- Install: `{e.g. pnpm install --frozen-lockfile}`
- Typecheck: `{e.g. pnpm tsc --noEmit}`
- Lint: `{e.g. pnpm eslint src}`
- Test: `{e.g. pnpm vitest run}`
- Conventions: {error handling, naming, file layout, test style; point to one good example file:line}
- Gotchas: {anything a newcomer gets wrong in this code}

## Tasks

### T1: {Title}
- depends_on: []
- executor: subagent
- files: {path, path}
- context: {upstream interfaces as code; existing code with file:line pointers}
- steps:
  1. {step}
  2. {step}
- acceptance:
  - {observable outcome}
- verify: `{command}` (expect: {result}); `{command}` (expect: {result})
- out_of_scope: {what not to touch}

### T2: {Title}
- depends_on: [T1]
- executor: subagent            # or opus
- harness / model: {optional, e.g. omp / deepseek-v4-pro}
- files: {path, path}
- context: …
- steps: …
- acceptance: …
- verify: …
- out_of_scope: …

## End-to-end verification

Run on `feature/{feature}` once every task is merged.

1. `{command}` (expect: {result})
2. {Manual or service-dependent check, if any, and its expected result}
