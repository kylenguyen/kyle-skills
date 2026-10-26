# Server setup

One-time setup of the remote Docker host. The default is `as1.manee-goby.ts.net` on Tailscale. The user does these steps; Claude can run the read-only checks (`delegate.sh doctor`) and `image build`, but never handles the API key.

## Requirements

| Item | Check |
|---|---|
| Passwordless ssh from the local machine | `ssh -o BatchMode=yes <server> true` |
| Docker usable without sudo (user in the `docker` group) | `ssh <server> docker info` |
| git and jq | `ssh <server> 'git --version; jq --version'` |
| 10 GB or more free in the home folder | `doctor` checks it |

## API key

The key lives only in `~/subagent/secrets.env` on the server, mode 600, one `NAME=value` per line. The user creates it on the server directly, for example with an editor over ssh:

```bash
ssh <server>
mkdir -p ~/subagent && touch ~/subagent/secrets.env && chmod 600 ~/subagent/secrets.env
nano ~/subagent/secrets.env      # add: DEEPSEEK_API_KEY=...
```

Never paste a key into the Claude conversation, a config file or a brief. For each task, the wrapper copies only the one variable the run needs into a temporary mode-600 env file, passes it to the agent container alone (not to setup or verify) and deletes it afterwards.

## Image

From any repo on the local machine:

```bash
<skill dir>/scripts/delegate.sh image build    # builds subagent-base:v1 on the server
<skill dir>/scripts/delegate.sh doctor         # every line should say ok
```

`image build` concatenates `scripts/Dockerfile` with each adapter's pinned install snippet. To upgrade pi or omp, change the version pinned in `scripts/adapters/<name>.sh`, rebuild, and rerun `doctor`, because model IDs can change between releases.

## Layout on the server

```
~/subagent/
  bin/              remote-run.sh and adapters/, overwritten on every run
  image/            the generated Dockerfile
  repos/<project>.git   bare repo; delegate.sh pushes base/, start/ and merge/ refs and reads agent/ branches
  runs/<run-id>/    in/, out/, logs/, remote.log; the clone is deleted when the run ends
  cache/<project>/  package caches shared by that project's runs
  secrets.env       API keys, mode 600
```

## What each run does

| Phase | Network | What happens |
|---|---|---|
| setup | on | Fresh `git clone` from the bare repo, then the project's `setup` command |
| agent | on (v1) | The harness runs headless with the brief mounted read-only at `/in` and writes `REPORT.md` to `/out`, outside the repo |
| verify | off | The wrapper runs the verify commands and records exit codes and output tails |
| guard | n/a | Flags edits outside `files`, unplanned test/config/lockfile changes, skipped or deleted tests, TODOs and stubs, conflict markers and diff size |
| commit | n/a | Squashes the work into one commit on `agent/<id>` and pushes it to the bare repo |

Container hardening on every phase: runs as the server user's uid (non-root), `--cap-drop ALL`, `--security-opt no-new-privileges`, CPU, memory and process limits, a timeout that kills the container, and no Docker socket, ssh agent or host home folder. Before git runs on the host after a container has touched the repo, the wrapper restores `.git/config` from a snapshot and empties `.git/hooks`, so nothing the agent wrote there can execute on the server.

Network: in v1 the agent can reach any host. That is acceptable because the API key is the only secret inside the container, but it means repo contents can reach the model provider and anything the agent fetches. v3 adds an allowlist proxy (`egress_hosts`).

## Running Claude Code on the server

Claude Code can run on the Docker host itself instead of a laptop. With `server: local`, `delegate.sh` runs the server commands directly and pushes to the bare repo by path, with no ssh. Everything else, including the layout above, is the same.

1. Do the steps above (Docker group, `secrets.env`, image) on the server.
2. Install the skill there: clone this repo and symlink `skills/delegate-to-subagent/` into `~/.claude/skills/`.
3. Add `server: local` to `~/.claude/subagent.yaml` on the server, then run `delegate.sh doctor` from a project repo there.

Two things change when Claude runs as the same user as the wrapper:

- `~/subagent/secrets.env` is readable by Claude. The rule against reading or printing it still applies. As a guardrail (not a real boundary), add a deny rule for it to the Claude Code settings on the server, for example `"permissions": { "deny": ["Read(~/subagent/secrets.env)"] }`.
- Docker access is close to root on that host, and Claude has it too. Only use local mode on a host dedicated to this work.

## Housekeeping

Run folders stay on the server for debugging. To clear runs older than 14 days and the wrapper's leftover refs:

```bash
ssh <server> 'find ~/subagent/runs -mindepth 1 -maxdepth 1 -mtime +14 -exec rm -rf {} +'
ssh <server> 'git -C ~/subagent/repos/<project>.git for-each-ref --format="%(refname)" refs/heads/base refs/heads/start refs/heads/merge | xargs -rn1 git -C ~/subagent/repos/<project>.git update-ref -d'
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `doctor`: model not listed | Run the listing command it prints and set `model` to an exact ID from it |
| `doctor`: key not set | Add the variable to `~/subagent/secrets.env` (name from `config --explain`) |
| `setup_error` | Read `.subagent-runs/<id>/setup.log`; usually a missing toolchain in the image or a wrong `setup` command |
| `api_error` | Check the key, the provider balance and quota; `agent.stderr` in the run folder has the provider's message |
| `delegate.sh run` lost ssh | The job keeps running. `delegate.sh status <id>`, then `delegate.sh fetch <id>` once it says done |
| A run is stuck | `delegate.sh cancel <id>`; the container is killed within a few seconds |
