# Plan format

A plan has two readers. The executor (you, later, possibly after the conversation is gone) needs the dependency graph, file lists and verify commands. Each sub-agent sees only the Shared context and its own task section, pasted into a brief. Write every section for a capable engineer who has never seen this codebase or this conversation.

Use `templates/plan.md`. Save it as `docs/<feature>-plan.md`, where `<feature>` is a short kebab-case slug; it also names the branch `feature/<feature>` and the run ids `<feature>-t<n>`.

## Shared context

Everything every task needs and nothing more:

| Item | Why it matters |
|---|---|
| Stack and versions | The sub-agent otherwise guesses APIs from the wrong version |
| Install, typecheck, lint and test commands | Verify commands build on them; the project's `setup` config usually equals the install command |
| Conventions, with one good example file:line | The sub-agent doesn't load the repo's AGENTS.md or CLAUDE.md, so conventions must be here |
| Gotchas | Things that look wrong but are deliberate, generated files not to edit, slow tests to avoid |

Leave out history, past decisions, alternatives considered and anything about the conversation. They cost tokens in every brief and change nothing in the code.

## Task fields

| Field | Required | Rule |
|---|---|---|
| `### T<n>: <title>` | yes | Imperative title; becomes the commit message `T<n>: <title>` |
| `depends_on` | yes | Task ids that must be merged first; `[]` if none. No cycles |
| `executor` | yes | `subagent` or `opus` (see below) |
| `harness / model` | no | Override for this task only, e.g. `omp` for a cross-file rename. Passed as `--plan harness=...` |
| `files` | yes | Every file the task is expected to create or change, including tests. Globs allowed (`src/sim/*.ts`); a trailing `/` means a whole folder. This is the guard allowlist |
| `context` | yes | Upstream interfaces written out as code (signatures, types), and existing code to read or copy, with file:line pointers |
| `steps` | yes | Numbered, concrete. Name functions, files and behaviours |
| `acceptance` | yes | Observable outcomes a reviewer can check against the diff |
| `verify` | yes | Exact commands with expected results: `` `pnpm vitest run src/sim` (expect: pass, new test "retries 3 times") `` |
| `out_of_scope` | yes | Nearby things not to touch, especially ones the sub-agent might "helpfully" fix |

## Rules

1. **Self-contained.** If a task depends on another task's output, write the interface it will see into `context` (for example the exact function signature T1 adds). The sub-agent can't read T1's section or ask.
2. **Size.** One concern, about 5 files or fewer, about 300 changed lines or fewer. If a task needs more, split it: interface first, then implementation, then callers. Cheap models degrade quickly on large tasks, and the guard flags diffs over 300 lines.
3. **Testable alone.** Verify commands run in a clean container with the network off after the project's `setup` command, so they must not need running services, secrets or internet. Where the full suite is slow, scope them to the task (`vitest run src/sim`, not the whole suite); the executor runs typecheck and lint across the whole branch after each merge.
4. **Expected results.** Name the new tests that must exist and pass, not just "tests pass". That stops a sub-agent passing by writing no tests.
5. **Overlap is fine.** Tasks may touch the same files and run in parallel; conflicts are resolved at merge time. Accurate `files` lists let the executor predict overlap and pick a merge order.
6. **`executor: opus`** when the task needs design judgement, touches auth, payment or other security-sensitive code, needs secrets or internal services, or is smaller than its own brief would be (under about 30 lines).
7. **No doc tasks.** Don't plan tasks that only write documentation.
8. **End-to-end verification.** The last section proves the whole feature works once every task is merged: commands that exercise the feature across task boundaries, plus any manual or service-dependent checks, each with its expected result.

## Example task

```markdown
### T3: Add retry to SIM client
- depends_on: [T1]
- executor: subagent
- files: src/sim/client.ts, src/sim/client.test.ts
- context:
  - T1 added `export class TransientError extends Error {}` in src/sim/errors.ts:4.
  - `SimClient.send()` is at src/sim/client.ts:42; it calls `this.http.post()` once and throws on any error.
  - Copy the backoff style from src/billing/poller.ts:18-35 (`sleep(ms)` from src/util/time.ts).
- steps:
  1. In `send()`, retry up to 3 attempts when `this.http.post()` throws `TransientError`; rethrow anything else at once.
  2. Wait 100 ms, then 200 ms, between attempts using `sleep`.
  3. Add tests with a fake `http` that fails twice then succeeds, and one that always fails.
- acceptance:
  - `send()` succeeds after two transient failures and makes exactly 3 calls.
  - Non-transient errors are not retried.
- verify: `pnpm tsc --noEmit` (expect: no errors); `pnpm vitest run src/sim` (expect: pass, new tests "retries 3 times" and "does not retry other errors")
- out_of_scope: the http layer in src/net/, other callers of SimClient.
```
