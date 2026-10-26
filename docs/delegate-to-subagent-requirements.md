# Requirements: `delegate-to-subagent` skill

## Goal

Opus plans, writes the task briefs and reviews. A cheaper model running in pi does the edits, inside a throwaway Docker container on `as1.manee-goby.ts.net` (Tailscale, Docker installed, passwordless ssh from the local machine). Quality comes from checks the wrapper runs itself, not from what the sub-agent says about its own work. Cost stays low because Opus never reads sub-agent transcripts and only reads diffs when the automated checks pass.

Out of scope: writing documentation, merging to `main` without the user, and any sub-agent access outside its own clone.

## Modes

One skill with three entry points. The plan format and the executor depend on each other, so splitting them would break the rule that each skill folder stands alone.

| Mode | Example triggers | Output |
|---|---|---|
| plan | "plan this feature", "break this into tasks" | `docs/<feature>-plan.md`, committed after the user approves |
| execute | "execute docs/x-plan.md" | One commit per task on `feature/<feature>`, plus an end-to-end (E2E) report |
| task | "delegate this fix to a sub-agent" | One branch, `agent/<task-id>` |

## Stage 1: Plan

1. Break the feature into tasks, each with a clear outcome. Dependencies (`depends_on`) must form a graph with no cycles.
2. Each task must stand on its own. The sub-agent sees only the shared context and its own task section, never the conversation, so the task section must carry every interface, file pointer and convention it needs.
3. Size limit: one concern, about 5 files or fewer, about 300 changed lines or fewer. Split anything bigger, because cheap models degrade quickly on large tasks.
4. Each task must be testable alone, with exact commands and expected results.
5. Tasks may touch the same files and still run at the same time. List each task's `files` so the executor can predict overlap, choose a merge order and run guard checks.
6. End with an E2E verification section that proves the whole feature works once every task is merged.
7. Leave out history and past decisions. Include only what implementation and testing need.
8. Mark a task `executor: opus` when it needs design judgement, touches security-sensitive code, or is smaller than its own brief would be.
9. Don't include tasks for writing docs. Show the plan in chat. Once the user approves, write `docs/<feature>-plan.md`, commit it and stop.

Plan template (`templates/plan.md`):

```markdown
## Shared context
Stack, install/typecheck/lint/test commands, conventions, gotchas.

### T3: Add retry to SIM client
- depends_on: [T1]
- executor: subagent            # or opus
- harness / model: (optional override)
- files: src/sim/client.ts, src/sim/client.test.ts   # expected files; guard allowlist
- context: upstream interfaces, existing code with file:line pointers
- steps: …
- acceptance: …
- verify: `pnpm tsc --noEmit`; `pnpm vitest run src/sim` (expect: pass, new test "retries 3 times")
- out_of_scope: …

## End-to-end verification
```

## Stage 2: Execute

1. **Preflight:** run `delegate.sh doctor` to check ssh, Docker, the image, the API key on the server and disk space. The local tree must be clean. Create `feature/<feature>` and a local worktree for it (`../<project>-feature-<feature>`), so merges and conflict resolution never disturb the user's main checkout.
2. **Schedule:** go in dependency order. Run ready tasks at the same time, up to `max_parallel` (default 2), each as a background Bash command. A task starts from the feature branch tip at the moment it is launched.
3. **Brief:** for each task, combine the shared context, the task section and `prompts/task-brief.md`.
4. **Review:** see the Review section. The result is merge, fix-up, Opus takes over, or discard.
5. **Merge:** see Merging and conflicts. Each accepted task lands on the feature branch as one commit, `<task-id>: <title>`.
6. **Finish:** run the plan's E2E verification on the feature branch with `delegate.sh verify feature/<feature>`. Report each task's status, fix-up rounds, conflicts resolved, cost and open issues. Never merge to `main` without the user.
7. **Resume:** keep state in `.subagent-runs/<feature>/state.json` (gitignored), so an interrupted run can pick up where it stopped.

## Merging and conflicts

Parallel tasks normally touch the same files, so conflicts are expected and handled as part of the flow rather than avoided in the plan.

1. **Order:** merge accepted tasks in plan order among those that are ready. When several are ready, merge the smaller diff first, because the larger task's conflict resolution then has the most context.
2. **Clean merge:** squash the task branch onto the feature tip in the local feature worktree.
3. **Textual conflict:** choose who resolves it.

   | Conflict | Resolver |
   |---|---|
   | Up to about 3 hunks and the intent of both sides is obvious | Opus resolves directly in the feature worktree |
   | Larger, or needs re-implementing logic | Sub-agent `conflict` task via `prompts/conflict-brief.md` |

   The `conflict` task clones the feature tip on the server, runs `git merge agent/<task-id>` to leave conflict markers in place, and asks the sub-agent to resolve them while keeping the intent of both sides. Its brief contains both task sections (the one already merged and the one being merged) and the list of conflicted files. It goes through the same verify and guard phases as any task.
4. **Verify after every merge:** run the verify commands of every task merged so far, plus typecheck and lint, on the new feature tip with `delegate.sh verify`. This catches semantic conflicts, where the text merges cleanly but the behaviour breaks.
5. **Failure after merge:** if verify fails, revert that merge commit and send a fix-up to the task's branch, rebased on the current feature tip, with the failing output. This counts as a fix-up round.

## Remote execution

The local script `scripts/delegate.sh` runs these steps:

1. Resolve the config.
2. Push the base commit to a bare repo on the server at `~/subagent/repos/<project>.git`. A worktree can't be mounted into the container directly, because its `.git` file points to the main repo by an absolute path outside the mount.
3. Copy `remote-run.sh` to the server (on every run, so the server copy never goes stale) and start it with `nohup`, so the job survives a dropped Tailscale connection.
4. Fetch `agent/<task-id>`.
5. Copy `REPORT.md`, `result.json` and the transcript into `.subagent-runs/<task-id>/`.

`delegate.sh status|fetch|cancel <task-id>` reconnects to a job if ssh drops. `delegate.sh verify <ref>` runs verify commands against any ref in a container, so merge checks don't depend on the local toolchain.

On the server, each task gets its own folder, `~/subagent/runs/<task-id>/`, and goes through these phases:

| Phase | Network | What happens |
|---|---|---|
| setup | on | Fresh `git clone`, then the project's `setup` command (e.g. `pnpm install --frozen-lockfile`), with a package-cache volume per project |
| agent | API host | pi runs headless. It reads the brief from a read-only mount and writes `REPORT.md` to `/out`, outside the repo so it never gets committed |
| verify | off | The wrapper runs the task's verify commands and saves exit codes and the last part of the output to `result.json` |
| guard | — | Flags edits outside `files`, changes to tests/config/lockfiles not in the plan, skipped or deleted tests, new TODOs or stubs, and diff size |
| commit | — | The wrapper squashes the work into one commit on `agent/<task-id>` |

Container hardening:

- Runs as a non-root user with `--cap-drop ALL` and `--security-opt no-new-privileges`.
- Memory, CPU and process-count limits.
- No Docker socket, no ssh agent and no host home folder.
- A timeout kills the container.

The API key comes from a server-side env file (mode 600) passed with `--env-file`. It is never printed and never passes through Claude.

Network: in v1 the agent can reach any host, which is acceptable because the API key is the only secret inside the container. v3 adds an allowlist proxy.

## Configuration and overrides

Order of precedence, highest first:

1. Flags passed by Claude to the wrapper, e.g. `--harness omp --model <provider/model>`
2. Task fields in the plan
3. Environment variables: `SUBAGENT_HARNESS`, `SUBAGENT_MODEL`, `SUBAGENT_PROVIDER`
4. Project config: `.claude/subagent.yaml`
5. User config: `~/.claude/subagent.yaml`
6. Built-in defaults

| Key | Default |
|---|---|
| `harness` / `provider` / `model` | `pi` / `deepseek` / DeepSeek V4.1 Flash (check the exact ID with the harness's model list) |
| `server` | `as1.manee-goby.ts.net` |
| `image`, `setup` | Base image with pi and Node; no setup command |
| `timeout_min`, `max_turns` | 20, 60 |
| `max_parallel`, `max_fixup_rounds` | 2, 2 |
| `max_run_spend_usd` | Stop and ask when reached |
| `resources` | 4 CPU, 8 GB, 512 pids |
| `egress_hosts`, `api_key_env.<provider>` | — |

- Config files can name the env var that holds a key, never the key itself.
- `delegate.sh config --explain` prints each resolved value and where it came from.

## Harness adapters

Each `scripts/adapters/<name>.sh` defines these parts, so the wrapper stays harness-agnostic:

| Part | What it does |
|---|---|
| `install` | Dockerfile snippet with a pinned version |
| `run` | Headless command with no prompts; brief path, model and provider passed in |
| `isolate` | Empty HOME plus harness-specific env vars, so no host config, extensions, sessions or skills load |
| `parse_usage` | Reads tokens in and out, cost and turns from the transcript into `result.json` |
| `exit_map` | Maps exit codes to `ok`, `agent_error`, `timeout` or `api_error` |

Ship three adapters:

- `pi`
- `omp`
- `fake`, which applies a canned patch so the pipeline can be tested without API spend

Claude doesn't read the transcript by default. If a run returns `agent_error` with an empty diff, it may read the last 50 lines.

## Review (Opus)

Read the inputs in this order, and stop once the decision is clear:

1. `result.json`
2. `REPORT.md`
3. `git diff base...agent/<id>`, file by file if it is large

If `result.json` and `REPORT.md` disagree, trust `result.json`. The full checklist lives in `references/review-checklist.md`: acceptance criteria met, verify passed per the wrapper, no unexplained edits outside `files`, no weakened tests, matches conventions, no dead code or stubs.

| Finding | Action |
|---|---|
| Everything passes | Merge |
| Specific defects | Fix-up brief (`prompts/fixup-brief.md`) listing each defect with file:line, same branch, round +1 |
| Rounds used up, or the fix is trivial | Opus fixes it directly |
| Wrong approach, or the brief was the problem | Discard, fix the plan, rerun |
| The model keeps failing at this kind of task | Override to a stronger model, or set `executor: opus` |

## When to delegate (for SKILL.md)

Delegate:

- tasks that are clearly specified, mechanical and checkable by commands
- tests
- boilerplate
- migrations that follow a pattern

Don't delegate:

- changes under about 30 lines, where the brief costs more than the work
- unclear design
- auth, payment or other security-sensitive code
- anything that needs secrets or internal services
- debugging without a reproduction

Overrides:

- Use omp for cross-file renames and refactors in large typed codebases, where its LSP support helps.
- Switch to a stronger model after a failed fix-up round.

## Cost controls

- Caps per task (timeout, turns) and per run (spend). Hitting a cap stops the run and asks the user.
- Opus reads `result.json` first, reads the diff only when needed, and never reads the transcript.
- Briefs include file:line pointers so the sub-agent doesn't spend tokens exploring.
- Cost per task is logged in `state.json` and totalled at the end.

## Secrets

- Briefs never contain secrets or production config. The container never gets local `.env` files.
- The API key is read from the server environment only, never printed and never pasted into the conversation.

## Skill layout

```
skills/delegate-to-subagent/
  SKILL.md
  prompts/      task-brief.md, fixup-brief.md, conflict-brief.md
  references/   plan-format.md, review-checklist.md, config.md, server-setup.md
  templates/    plan.md, report.md
  scripts/      delegate.sh, remote-run.sh, Dockerfile, adapters/{pi,omp,fake}.sh
```

Also add `scripts/` to the layout section of `AGENTS.md`.

## Testing

1. **Plumbing:** use the `fake` adapter on a toy repo to test the pipeline, the guard checks and resume.
2. **Real model:** use pi with DeepSeek on the toy repo. Start with one task, then a 3-task plan with two parallel tasks that edit the same file, to exercise conflict resolution.
3. **Failure cases:**
   - kill ssh during a run
   - use a bad API key
   - force a timeout
   - make the agent edit a test file outside the allowlist
   - two tasks that merge cleanly but break each other (semantic conflict)
4. **Triggers:** use the three mode prompts, plus one prompt that should not trigger the skill.

## Rollout

- v1: task mode, and execute mode running one task at a time.
- v2: parallel tasks, conflict resolution and resume.
- v3: network allowlist proxy and cost summary.

## Open questions

1. Which languages and toolchains do the Docker images need to cover?
2. Is v1 without parallel tasks acceptable, with conflict resolution arriving in v2?
