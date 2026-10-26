# Review checklist

Review is where Opus tokens go, so read the cheapest inputs first and stop once the decision is clear. Trust what the wrapper measured over what the sub-agent wrote: when `result.json` and `REPORT.md` disagree, `result.json` wins.

## Reading order

1. **The digest** printed at the end of `delegate.sh run` (a summary of `result.json`). Open `result.json` itself only for the verify `tail` of a failing command or for a field the digest leaves out.
2. **`REPORT.md`**, for deviations and open issues. Treat its claims as leads to check, not evidence.
3. **The diff**: `git show agent/<id>` (the branch is always one commit on its base). If it is large, list files with `git show --stat agent/<id>` and read them one at a time with `git show agent/<id> -- <path>`.
4. **Never the transcript**, except: on `agent_error` with an empty diff, read the last 50 lines of `transcript.jsonl` (or `agent.stderr`) to see why it stopped.

## Status

| `status` | Meaning | Action |
|---|---|---|
| `ok` | The harness exited normally | Review verify, guard and the diff |
| `agent_error` | The harness failed or hit `max_turns` (see `note`) | Partial work may be committed; review it, or rerun with a sharper brief or stronger model |
| `timeout` | Killed at `timeout_min`; verify, guard and commit still ran on what was there | Usually the task is too big; split it in the plan |
| `api_error` | Bad key, quota, rate limit or provider outage | Not a sub-agent failure; check `doctor`, rerun, don't count a round |
| `setup_error` | The project `setup` command failed (`setup.log`) | Fix config or the image; rerun |
| `infra_error`, `cancelled` | Wrapper or server problem, or cancelled | Check `remote.log` on the server; rerun |

## Verify

`verify.passed` is true only if every command the wrapper ran exited 0. A pass with zero commands (`verify=none`) is not a pass; the task needs verify commands. When a command fails, the `tail` in `result.json` is the evidence for the fix-up brief.

Also check that the plan's expected results hold: if the plan expects a new test called "retries 3 times", look for it in the diff. A passing suite with the test missing is a defect.

## Guard flags

| Flag | Meaning | Usually |
|---|---|---|
| `outside_files` | Changed a file not in the task's `files` | Accept if it is a small, necessary follow-on (an import, a type export) and the report explains it; otherwise a defect |
| `test_unplanned` | Changed a test file not in `files` | Read it closely: editing someone else's test to make it pass is the classic failure |
| `config_unplanned` | Changed package.json, tsconfig, lint or CI config, .gitignore and similar | Defect unless the task needs it |
| `lockfile_unplanned` | Changed a lockfile | A new dependency the plan didn't ask for: defect |
| `deleted_test` | Deleted a test file | Defect unless the task says so |
| `removed_test_cases` | More test definitions removed than added in a file | Check whether tests were dropped or just restructured |
| `skipped_test` | Added `.skip`, `.only`, `xit`, `@pytest.mark.skip` and similar | Defect |
| `todo_or_stub` | Added TODO, FIXME, `not implemented` and similar | Defect, unless the TODO is required by the plan |
| `conflict_marker` | Conflict markers left in the diff | Defect |
| `diff_size` | Over about 300 changed lines | Check for unrelated churn; if the work needed it, the task was too big |
| `empty_diff` | No changes | Read the report and the last 50 transcript lines |

## Diff checklist

- [ ] Every acceptance criterion is met, judged from the diff, not the report.
- [ ] Verify passed per the wrapper, and the expected new tests exist and test the right thing (assertions on behaviour, not just "does not throw").
- [ ] No unexplained edits outside `files`; no unrelated refactors, renames or reformatting.
- [ ] No weakened tests: no loosened assertions, deleted cases, skips, or mocks that bypass the code under test.
- [ ] Matches the conventions in the plan's Shared context and the surrounding code.
- [ ] No dead code, stubs, debug logging or commented-out code.
- [ ] Error handling and edge cases the steps named are handled.
- [ ] Nothing security-relevant slipped in (new network calls, shelling out, reading env vars, logging data).

## Decision

Act on the review with the Finding and Action table under Review in SKILL.md.

## Writing a fix-up

- One line per defect: `src/sim/client.ts:57: retries on every error; should rethrow anything that is not TransientError`. Say what correct looks like, not only what is wrong.
- Paste the failing `tail` from `result.json` under Failing output. Don't paste the whole log.
- Don't restate what is already right. Don't add new requirements; if the plan was wrong, discard and fix the plan instead.
- If the same defect survives a fix-up round, the brief is probably ambiguous: rewrite that part instead of repeating it louder.
