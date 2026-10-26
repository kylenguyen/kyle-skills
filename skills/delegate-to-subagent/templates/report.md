# {Feature name}: execution report

Date: {YYYY-MM-DD}. Plan: `docs/{feature}-plan.md`. Branch: `feature/{feature}` in `{worktree path}`, not merged to `main`.

## Result

{One or two lines: did the E2E verification pass, and is the branch ready for the user's review?}

## Tasks

| Task | Executor | Status | Fix-up rounds | Conflicts | Cost (USD) | Commit |
|---|---|---|---|---|---|---|
| T1: {title} | subagent ({harness}/{model}) | merged | 0 | none | 0.012 | `abc1234` |
| T2: {title} | opus | merged | – | resolved by opus | – | `def5678` |
| T3: {title} | subagent | discarded, redone by opus | 2 | – | 0.040 | `0123abc` |
| Total | | | {n} | {n} | {total} | |

## End-to-end verification

| Check | Result |
|---|---|
| `{command}` | pass / fail: {key line} |
| {manual check} | not run: {why}; the user should check {what} |

## Open issues

- {Anything a reviewer flagged but left, guard flags accepted with a reason, tests the plan didn't cover, follow-up work}

## Notes for next time

- {Brief or plan problems that caused fix-ups or discards, and model or harness choices that worked or didn't}
