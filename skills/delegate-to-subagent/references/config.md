# Configuration

`delegate.sh` resolves every setting from these layers, highest precedence first. `delegate.sh config --explain [flags]` prints each resolved value and the layer it came from.

| # | Layer | How it is set |
|---|---|---|
| 1 | Flags | `--harness omp --model deepseek-v4-pro --timeout-min 30 --set resources.memory=12g` |
| 2 | Plan task fields | `--plan harness=omp --plan model=...`, passed by Claude from the task's `harness / model` field |
| 3 | Environment | `SUBAGENT_HARNESS`, `SUBAGENT_PROVIDER`, `SUBAGENT_MODEL` |
| 4 | Project config | `.claude/subagent.yaml` in the repo (commit it) |
| 5 | User config | `~/.claude/subagent.yaml` |
| 6 | Built-in defaults | Below |

## Keys

| Key | Default | Notes |
|---|---|---|
| `harness` | `pi` | `pi`, `omp` or `fake`; one file per harness in `scripts/adapters/` |
| `provider` | `deepseek` | As the harness names it |
| `model` | `deepseek-flash` | DeepSeek V4.1 Flash in pi 1.4.0 and omp 18.12.6. Model IDs change between harness releases: `doctor` checks the ID against the harness's own model list |
| `server` | `as1.manee-goby.ts.net` | Any host with passwordless ssh and Docker, or `local` when Claude Code runs on the Docker host itself (no ssh; see `server-setup.md`) |
| `project` | Repo folder name | Names the bare repo and package cache on the server |
| `image` | `subagent-base:v1` | Built by `delegate.sh image build`; see Project images |
| `setup` | none | Run once per task in the fresh clone, network on, no API key, e.g. `pnpm install --frozen-lockfile` |
| `timeout_min` | `20` | Per phase (setup, agent, verify); the container is killed at the limit |
| `max_turns` | `60` | The wrapper counts the harness's turns and kills it past the limit |
| `max_parallel` | `2` | Tasks running at once in execute mode |
| `max_fixup_rounds` | `2` | Per task, before Opus takes over |
| `max_run_spend_usd` | `5` | Execute mode stops and asks the user when the run total reaches it |
| `resources.cpus` / `.memory` / `.pids` | `4` / `8g` / `512` | Container limits for every phase |
| `egress_hosts` | none | Reserved for the v3 allowlist proxy; ignored in v1 |
| `api_key_env.<provider>` | `api_key_env.deepseek: DEEPSEEK_API_KEY`; otherwise `<PROVIDER>_API_KEY` | The name of the variable in the server's `~/subagent/secrets.env`. Config may name a variable, never hold a key; `delegate.sh` refuses anything that doesn't look like a variable name |

## Example `.claude/subagent.yaml`

The parser reads `key: value` lines and one level of nesting, nothing more.

```yaml
# Node + pnpm service
setup: pnpm install --frozen-lockfile
timeout_min: 25
resources:
  memory: 12g
api_key_env:
  deepseek: DEEPSEEK_API_KEY
```

## Setup and caches

`setup` runs inside the project image with a package cache mounted per project (`~/subagent/cache/<project>` on the server), so repeat installs are fast. npm, pnpm, corepack, pip and anything that honours `XDG_CACHE_HOME` use it. Examples:

| Stack | `setup` |
|---|---|
| Node (npm) | `npm ci` |
| Node (pnpm) | `pnpm install --frozen-lockfile` |
| Python (uv) | `uv sync --frozen` (needs a project image with uv) |
| Go | `go mod download` (needs a project image with Go) |

Verify runs with the network off, so everything the verify commands need must be installed by `setup`.

## Project images

The base image has Node 24, git, jq, ripgrep, pi and omp. For other toolchains, build a project image on the server from it and set `image`:

```dockerfile
FROM subagent-base:v1
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-venv \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g --ignore-scripts typescript-language-server typescript
```

```bash
ssh <server> 'docker build -t subagent-myproject:v1 -' < Dockerfile.myproject
```

Add language servers (as above) if you use omp for refactors; its LSP tools only work when the server for the language is installed.

## Choosing harness and model

| Situation | Choice |
|---|---|
| Default mechanical task | `pi` + `deepseek-flash` |
| Cross-file rename or refactor in a large typed codebase | `--harness omp` (LSP rename and diagnostics), with language servers in the image |
| Failed a fix-up round, or a harder task | A stronger model, e.g. `--model deepseek-v4-pro`, or another provider whose key is in `secrets.env` |
| Testing the pipeline | `--harness fake --fake-patch <file>`; no API spend |
