---
name: delegate-to-subagent
description: Plan a feature as small self-contained tasks, then have a cheaper model (pi or omp running DeepSeek by default) implement them in throwaway Docker containers on a remote server, while Claude writes the briefs, reviews the diffs and merges. Quality comes from checks the wrapper runs itself (verify commands, guard checks on the diff), not from what the sub-agent reports. Three modes. Plan: "plan this feature", "break this into tasks", "write an implementation plan for sub-agents". Execute: "execute docs/x-plan.md", "run the plan", "implement the plan with sub-agents". Task: "delegate this fix to a sub-agent", "have a cheaper model do this", "offload this to pi/DeepSeek". Use it whenever the user wants implementation work split into tasks or handed to a cheaper or remote coding agent, even if they don't say "sub-agent". Not for writing documentation, and never merges to main without the user.
---

# Delegate to sub-agent

Opus plans, writes the task briefs and reviews. A cheaper model running in a coding harness (pi by default) does the edits inside a throwaway container on a remote Docker host. You trust what the wrapper measured (`result.json`: exit codes of the verify commands it ran, guard flags on the diff), never what the sub-agent says about its own work. Cost stays low because you never read transcripts and read diffs only when the automated checks pass.

Out of scope: writing documentation, merging to `main` without the user, and any sub-agent access outside its own clone.

## Modes

| Mode | Example triggers | Output |
|---|---|---|
| plan | "plan this feature", "break this into tasks" | `docs/<feature>-plan.md`, committed after the user approves |
| execute | "execute docs/x-plan.md" | One commit per task on `feature/<feature>`, plus an end-to-end (E2E) report |
| task | "delegate this fix to a sub-agent" | One branch, `agent/<slug>` |

The plan format and the executor depend on each other, which is why they live in one skill.

## When to delegate

| Delegate | Don't delegate (do it yourself or mark `executor: opus`) |
|---|---|
| Clearly specified, mechanical work that commands can check | Changes under about 30 lines, where the brief costs more than the work |
| Tests | Unclear design |
| Boilerplate | Auth, payment or other security-sensitive code |
| Migrations that follow a pattern | Anything that needs secrets or internal services |
| | Debugging without a reproduction |

Overrides: use `--harness omp` for cross-file renames and refactors in large typed codebases, where its LSP tools help. Switch to a stronger model (`--model deepseek-v4-pro` or another provider) after a failed fix-up round.

## The wrapper: `scripts/delegate.sh`

Call it by absolute path (`<this skill's directory>/scripts/delegate.sh`; below, just `delegate.sh`) from inside the project repo, in any worktree. It keeps local results in `<repo>/.subagent-runs/` (added to `.git/info/exclude` automatically) and talks to the server over ssh. The server side is described in `references/server-setup.md`; configuration and overrides in `references/config.md`.

| Command | Use |
|---|---|
| `delegate.sh doctor` | Preflight: ssh, Docker, image, harness, model ID, API key present, disk |
| `delegate.sh config --explain [overrides]` | Show each resolved setting and which layer it came from |
| `delegate.sh run <id> --brief F --title T --files G... --verify C... [--base R] [--merge R] [--branch B]` | Run one task. Blocks until done, fetches `agent/<id>` and prints a digest of `result.json` |
| `delegate.sh status\|fetch\|cancel <id>` | Reconnect to a job after ssh drops, collect it, or kill it |
| `delegate.sh verify <ref> --verify C...` | Run commands against any ref in a fresh container with the network off |

`run` and `verify` take minutes. Start them with the Bash tool's `run_in_background`, and read their final output when notified; it ends with a digest such as:

```
status=ok verify=pass (2/2) guard=1 flags diff=+120/-8 in 4 files commit=2a97ffe281 cost=$0.012 turns=14
  outside_files: src/util/format.ts
```

Run ids are lowercase and unique per repo: `<feature>-t3` for a task, `<feature>-t3-fix1` for its first fix-up, `<feature>-t3-merge1` for a conflict task, `<slug>` in task mode. Results land in `.subagent-runs/<run-id>/`: `result.json`, `REPORT.md`, `transcript.jsonl`, `verify/`, `in/brief.md`.

Pass plan task fields as `--plan key=value` (for example `--plan harness=omp`) and your own overrides as flags (`--model ...`), so `config --explain` shows where each value came from. Never pass an API key; the server reads it from its own env file.

## Stage 1: Plan

Read `references/plan-format.md` before writing a plan; it defines each field and the rules below in detail.

1. Explore the code enough to give every task real file:line pointers and interfaces. Briefs with pointers stop the sub-agent burning tokens on exploration.
2. Break the feature into tasks with clear outcomes. `depends_on` must form a graph with no cycles.
3. Make each task stand alone. The sub-agent sees only the shared context and its own task section, never this conversation or the repo's AGENTS.md, so the section carries every interface, pointer and convention it needs.
4. Keep each task to one concern, about 5 files or fewer and about 300 changed lines or fewer. Split anything bigger, because cheap models degrade quickly on large tasks.
5. Give every task exact verify commands with expected results, runnable offline once setup has run.
6. Tasks may touch the same files and still run in parallel. List each task's `files` accurately: the executor uses them to predict overlap and order merges, and the guard flags edits outside them.
7. Mark a task `executor: opus` when it needs design judgement, touches security-sensitive code, or is smaller than its own brief would be.
8. End with an E2E verification section that proves the whole feature works once every task is merged.
9. Leave out history and past decisions, and don't include tasks for writing docs.
10. Use `templates/plan.md`. Show the plan in chat. Once the user approves, write `docs/<feature>-plan.md`, commit it (`add <feature> plan`) and stop.

## Stage 2: Execute

Read `references/review-checklist.md` before the first review.

### Preflight

1. Run `delegate.sh doctor`. Stop on any FAIL and tell the user how to fix it (`references/server-setup.md`).
2. The local tree must be clean; if it isn't, ask the user to commit or stash.
3. Create the feature branch and a worktree for it, so merges and conflict resolution never disturb the user's checkout:
   `git worktree add -b feature/<feature> ../<project>-feature-<feature> <current branch>`
   If both already exist, this is a resume (see Resume).
4. Create `.subagent-runs/<feature>/state.json` (schema below) and a `briefs/` folder next to it.

### Schedule

Go in dependency order. A task is ready when every `depends_on` task is merged. Launch ready tasks at the same time, up to `max_parallel` (default 2), each as a background `delegate.sh run`. A task starts from the feature branch tip at the moment it is launched (`--base feature/<feature>`). Run `executor: opus` tasks yourself in the feature worktree while sub-agent tasks run.

Before every launch, check the run's total spend in `state.json` against `max_run_spend_usd`. If it is reached, stop and ask the user before spending more. Stop and ask as well when a task hits its timeout or turn cap twice.

### Brief

Fill `prompts/task-brief.md` and write it to `.subagent-runs/<feature>/briefs/<run-id>.md`:

| Placeholder | Value |
|---|---|
| `{TASK_ID}`, `{TITLE}` | From the plan, e.g. `T3`, `Add retry to SIM client` |
| `{SHARED_CONTEXT}` | The plan's Shared context section, verbatim |
| `{TASK_SECTION}` | The task's section, verbatim, plus any interface that changed in an upstream task after the plan was written |
| `{FILES}` | The task's `files`, one per line |
| `{VERIFY}` | The task's verify commands with expected results, one per line |
| `{ROUND}`, `{DEFECTS}`, `{FAILING_OUTPUT}` | Fix-up brief only: the round number; each defect as `path:line: what is wrong and what correct looks like`; the failing `tail` from `result.json` (or "None") |
| `{MERGED_TASK_ID}`, `{MERGED_TASK_SECTION}`, `{CONFLICTED_FILES}` | Conflict brief only: the task already on the feature branch, its section, and the conflicted paths from your local merge attempt |

Then launch:

```bash
delegate.sh run <feature>-t3 --brief .subagent-runs/<feature>/briefs/<feature>-t3.md \
  --title "T3: Add retry to SIM client" --base feature/<feature> \
  --files src/sim/client.ts --files src/sim/client.test.ts \
  --verify "pnpm tsc --noEmit" --verify "pnpm vitest run src/sim" [--plan harness=omp]
```

`--verify` takes the commands only; the expected results belong in the brief and in your review.

### Review

Read in this order and stop once the decision is clear: the digest (already in the run's output), then `REPORT.md`, then the diff (`git show agent/<id>`, file by file with `-- <path>` if it is large). If `result.json` and `REPORT.md` disagree, trust `result.json`. Never read the transcript, except the last 50 lines when a run returns `agent_error` with an empty diff.

| Finding | Action |
|---|---|
| Everything passes | Merge |
| Specific defects | Fix-up: fill `prompts/fixup-brief.md` listing each defect with file:line, run `<id>-fix<n>`; round +1 |
| Rounds used up (`max_fixup_rounds`, default 2), or the fix is trivial | `git merge --squash` it, fix the rest yourself in the feature worktree, then commit as `<Tn>: <title>` |
| Wrong approach, or the brief was the problem | Discard the branch, fix the plan section, rerun with a new id |
| The model keeps failing at this kind of task | Rerun with a stronger `--model`, or take it over as `executor: opus` |
| `api_error`, `setup_error`, `infra_error` | Not the sub-agent's fault. Check `doctor` and `setup.log`, fix, rerun; don't count a round |

A fix-up always starts from the current feature tip with the task's branch merged in, so it doubles as the rebase:

```bash
delegate.sh run <feature>-t3-fix1 --brief <fixup brief> --title "T3: Add retry to SIM client" \
  --base feature/<feature> --merge agent/<feature>-t3 --branch agent/<feature>-t3 --files ... --verify ...
```

### Merge

Work in the feature worktree. Merge accepted tasks in plan order among those that are ready; when several are ready, merge the smaller diff first, because the larger task's conflict resolution then has the most context.

1. `git merge --squash agent/<id>`. If it is clean, `git commit -m "<Tn>: <title>"`. Each accepted task lands as exactly one commit.
2. On a textual conflict, count the conflicted hunks (`git diff --diff-filter=U`):

   | Conflict | Resolver |
   |---|---|
   | Up to about 3 hunks and the intent of both sides is obvious | Resolve it yourself, `git add`, commit |
   | Larger, or needs logic re-implemented | `git reset --hard HEAD` to drop the half-merge, then a conflict task |

   A conflict task fills `prompts/conflict-brief.md` (both task sections, the conflicted files) and runs with `--base feature/<feature> --merge agent/<id> --branch agent/<id>-merge1`. The server merges with the conflict markers left in place and the sub-agent resolves them. Pass the union of both tasks' `files` and the verify commands of both tasks. Review it like any task, then squash-merge `agent/<id>-merge1` (it applies cleanly onto the tip) as `<Tn>: <title>`.
3. Verify after every merge, because text can merge cleanly while behaviour breaks: run `delegate.sh verify feature/<feature>` with the plan's typecheck and lint commands plus the verify commands of every task merged so far.
4. If that fails, undo the merge with `git reset --hard HEAD~1`. The feature branch is local and unshared, and dropping the commit keeps one commit per task. Then send a fix-up with the failing output. It counts as a fix-up round.

### Finish

1. Run the plan's E2E verification with `delegate.sh verify feature/<feature> --verify ...`. Steps that need a running service or a browser can't run in the container; run those locally in the feature worktree, or list them for the user.
2. Write the report from `templates/report.md` to `.subagent-runs/<feature>/report.md` and give the user its summary table in chat.
3. Never merge to `main`. Tell the user the branch and worktree are ready, and offer to open a PR or merge only when they ask.

### Resume

`.subagent-runs/<feature>/state.json` (gitignored) is the source of truth for an execute run:

```json
{
  "feature": "sim-retry", "plan": "docs/sim-retry-plan.md",
  "branch": "feature/sim-retry", "worktree": "../shop-feature-sim-retry",
  "spend_usd": 0.084, "max_run_spend_usd": 5,
  "tasks": {
    "T3": {
      "status": "pending | running | review | fixup | merging | merged | discarded | blocked",
      "executor": "subagent | opus",
      "runs": ["sim-retry-t3", "sim-retry-t3-fix1"],
      "fixup_rounds": 1, "cost_usd": 0.031,
      "commit": "<sha on feature branch, once merged>",
      "conflict": "none | opus | subagent",
      "notes": "one line, e.g. why it was taken over"
    }
  },
  "e2e": null
}
```

Update it after every launch, review decision and merge. On resume, read it, then for each task marked `running` call `delegate.sh status <run-id>`: fetch it if it is done, wait for it if it is still running, rerun it if it is missing. Check `git log feature/<feature>` against tasks marked `merged` before continuing.

## Task mode

For a single change with no plan:

1. Check it against "When to delegate"; if it is too small or too sensitive, say so and do it yourself.
2. Write one task section in the plan format (`references/plan-format.md`) with a short Shared context, show it to the user in a few lines, and run `doctor`.
3. Brief and run it as `<slug>` with `--base HEAD`. Review as in execute mode, with fix-up rounds on the same branch.
4. Leave the result on `agent/<slug>` and tell the user how to look at it (`git show agent/<slug>`) and merge it. Merge it into their branch only if they ask.

## Secrets and data handling

- Briefs never contain secrets, credentials, production config, customer data or internal hostnames. The container gets only a fresh clone, never local `.env` files.
- The API key lives on the server in `~/subagent/secrets.env` (mode 600) and is passed only to the agent phase. Never ask the user to paste a key, never print one, and never put one in a config file; config names the env var only.
- The sub-agent has network access in v1, so treat anything in the repo as visible to the model provider. Don't delegate tasks in repos that hold secrets in tracked files.

## What this skill can and cannot conclude

Verify and guard results show that the stated commands passed in a clean container and flag suspicious edits; they don't prove the change is correct beyond what the tests cover. Your diff review covers design, conventions and test quality. The E2E section shows the feature works as the plan defined it; anything the plan didn't specify is untested. Cost figures come from the harness's own usage reports and can be missing for some providers.
