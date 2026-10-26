#!/usr/bin/env bash
# Runs one sub-agent job on the server. delegate.sh copies this file over on every run and
# starts it with nohup, so the job survives a dropped ssh connection.
#
#   remote-run.sh <run-id>
#
# ~/subagent/runs/<run-id>/
#   in/         job.env, brief.md, verify.txt, files.txt, fake.patch   (read-only to containers)
#   out/        result.json, REPORT.md, transcript.jsonl, setup.log, verify/<n>.{cmd,log,exit}
#   repo/       the clone; deleted once the branch is pushed
#   phase       current phase; `done` holds the final status once finished
#   cancel      created by `delegate.sh cancel`; the running container is killed
#
# MODE=task runs setup, agent, verify, guard, commit. MODE=verify runs setup and verify only.
# With MERGE set, the agent starts from START with `git merge MERGE` conflicts left in place.
set -uo pipefail

RUN_ID=$1
ROOT=$HOME/subagent
RUN=$ROOT/runs/$RUN_ID
IN=$RUN/in OUT=$RUN/out REPO=$RUN/repo
source "$IN/job.env"
source "$ROOT/bin/adapters/$HARNESS.sh"
CACHE=$ROOT/cache/$PROJECT

mkdir -p "$OUT/verify" "$RUN/logs" "$RUN/agent-out" "$CACHE/home"
rm -f "$RUN/done" "$RUN/cancel"
echo $$ > "$RUN/pid"

STATUS=infra_error NOTE= EXIT= KILLED= COMMIT=null
USAGE='{"tokens_in":null,"tokens_out":null,"cost_usd":null,"turns":null}'
VERIFY='{"passed":null,"commands":[]}'
GUARD='{"flags":[],"files_changed":0,"lines_added":0,"lines_removed":0}'
PHASES='{}'
FINISHED=

log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >> "$RUN/remote.log"; }

# Git on the host ignores hooks and fsmonitor, because the agent could have written either into .git.
g() { git -C "$REPO" -c core.hooksPath=/dev/null -c core.fsmonitor=false "$@"; }

PHASE= PHASE_START=
phase() {
  [ -n "$PHASE" ] && PHASES=$(jq --arg p "$PHASE" --argjson s $((SECONDS - PHASE_START)) '.[$p] = $s' <<<"$PHASES")
  PHASE=$1 PHASE_START=$SECONDS
  echo "$1" > "$RUN/phase"
  log "phase: $1"
}

finish() {
  [ -n "$FINISHED" ] && return
  FINISHED=1
  STATUS=${1:-$STATUS}
  [ -n "${2:-}" ] && NOTE=$2
  phase finished
  jq -n --arg run_id "$RUN_ID" --arg mode "$MODE" --arg status "$STATUS" --arg note "$NOTE" \
    --arg harness "$HARNESS" --arg provider "$PROVIDER" --arg model "$MODEL" \
    --arg branch "$BRANCH" --arg base "$BASE" --arg start "$START" --arg merge "$MERGE" \
    --arg agent_exit "${EXIT:-}" --arg killed "${KILLED:-}" \
    --argjson commit "$COMMIT" --argjson usage "$USAGE" --argjson verify "$VERIFY" \
    --argjson guard "$GUARD" --argjson phase_secs "$PHASES" \
    '{run_id: $run_id, mode: $mode, status: $status, note: $note,
      harness: $harness, provider: $provider, model: $model,
      branch: $branch, base: $base, start: $start, merge: (if $merge == "" then null else $merge end),
      commit: $commit, agent_exit: ($agent_exit | tonumber? // null),
      killed: (if $killed == "" then null else $killed end),
      verify: $verify, guard: $guard, usage: $usage, phase_secs: $phase_secs}' > "$OUT/result.json"
  rm -f "$RUN/key.env"
  docker ps -aq --filter "name=^subagent-$RUN_ID-" | xargs -r docker rm -f >/dev/null 2>&1
  [ "${KEEP_REPO:-0}" = 1 ] || rm -rf "$REPO"
  echo "$STATUS" > "$RUN/done"
  log "done: $STATUS $NOTE"
}
trap 'finish infra_error "remote-run.sh exited unexpectedly in phase $PHASE"' EXIT

# docker_run <phase> <network> <limit-seconds> <command> [extra docker args...]
# Starts a hardened container, polls it so cancel, timeout and max_turns can kill it, then
# leaves EXIT (container exit code) and KILLED (cancelled|timeout|max_turns or empty).
docker_run() {
  local name="subagent-$RUN_ID-$1" net=$2 limit=$3 cmd=$4 start=$SECONDS
  shift 4
  KILLED= EXIT=
  docker rm -f "$name" >/dev/null 2>&1
  if ! docker run -d --name "$name" --network "$net" \
      --user "$(id -u):$(id -g)" --cap-drop ALL --security-opt no-new-privileges \
      --cpus "$CPUS" --memory "$MEMORY" --pids-limit "$PIDS" \
      --tmpfs /tmp:rw,exec,size=2g \
      -v "$REPO:/work" -w /work -v "$IN:/in:ro" -v "$CACHE:/cache" \
      -e XDG_CACHE_HOME=/cache/xdg -e npm_config_cache=/cache/npm -e COREPACK_HOME=/cache/corepack \
      -e npm_config_store_dir=/cache/pnpm-store -e PIP_CACHE_DIR=/cache/pip \
      -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 -e CI=1 \
      "$@" "$IMAGE" bash -c "$cmd" > "$RUN/logs/$1.cid" 2> "$RUN/logs/$1.err"; then
    EXIT=125
    return
  fi
  while [ "$(docker inspect -f '{{.State.Running}}' "$name" 2>/dev/null)" = true ]; do
    if [ -e "$RUN/cancel" ]; then KILLED=cancelled
    elif (( SECONDS - start > limit )); then KILLED=timeout
    elif [ -n "${WATCH_TURNS:-}" ] && (( MAX_TURNS > 0 )) && (( $(adapter_turns "$WATCH_TURNS") > MAX_TURNS )); then KILLED=max_turns
    fi
    if [ -n "$KILLED" ]; then docker kill "$name" >/dev/null 2>&1; break; fi
    sleep 3
  done
  EXIT=$(docker inspect -f '{{.State.ExitCode}}' "$name" 2>/dev/null || echo 125)
  docker logs "$name" > "$RUN/logs/$1.log" 2>&1
  docker rm -f "$name" >/dev/null 2>&1
}

# ---- setup: fresh clone, project setup command (network on, no API key) ----
phase setup
rm -rf "$REPO"
if ! git clone -q --no-checkout "$ROOT/repos/$PROJECT.git" "$REPO" 2>> "$RUN/remote.log" \
   || ! g checkout -q -B "${BRANCH:-verify}" "$START" 2>> "$RUN/remote.log"; then
  finish setup_error "clone or checkout of $START failed"; exit 0
fi
# Snapshot .git/config before any container touches the repo; restored before host git runs again.
cp "$REPO/.git/config" "$RUN/git-config"

if [ -n "$SETUP" ]; then
  docker_run setup bridge $((TIMEOUT_MIN * 60)) "$SETUP" -e HOME=/cache/home
  tail -n 200 "$RUN/logs/setup.log" > "$OUT/setup.log" 2>/dev/null
  [ -n "$KILLED" ] && { finish "$([ "$KILLED" = cancelled ] && echo cancelled || echo setup_error)" "setup $KILLED"; exit 0; }
  [ "$EXIT" != 0 ] && { finish setup_error "setup exited $EXIT; see setup.log"; exit 0; }
fi

restore_git() {
  cp "$RUN/git-config" "$REPO/.git/config"
  rm -rf "$REPO/.git/hooks" && mkdir -p "$REPO/.git/hooks"
  rm -f "$REPO/.git/info/attributes"
}

if [ -n "$MERGE" ]; then
  restore_git
  g merge -q --no-commit --no-ff "$MERGE" > "$RUN/logs/merge.log" 2>&1
  g diff --name-only --diff-filter=U > "$OUT/conflicts.txt"
  log "merge of $MERGE: $(wc -l < "$OUT/conflicts.txt") conflicted files"
fi

# ---- agent: the harness runs headless with only the API host it needs (v1: any host) ----
if [ "$MODE" = task ]; then
  phase agent
  restore_git
  adapter_isolate > "$RUN/isolate.env"
  key_args=()
  if [ -n "$KEY_VAR" ]; then
    (umask 077; grep "^${KEY_VAR}=" "$ROOT/secrets.env" > "$RUN/key.env" 2>/dev/null)
    [ -s "$RUN/key.env" ] || { finish api_error "$KEY_VAR is not set in ~/subagent/secrets.env"; exit 0; }
    key_args=(--env-file "$RUN/key.env")
  fi
  WATCH_TURNS=$RUN/agent-out/transcript.jsonl
  docker_run agent bridge $((TIMEOUT_MIN * 60)) "$(adapter_run /in/brief.md "$PROVIDER" "$MODEL" /out)" \
    --env-file "$RUN/isolate.env" "${key_args[@]}" -v "$RUN/agent-out:/out"
  WATCH_TURNS=
  rm -f "$RUN/key.env"
  for f in REPORT.md transcript.jsonl agent.stderr; do
    [ -f "$RUN/agent-out/$f" ] && cp "$RUN/agent-out/$f" "$OUT/$f"
  done
  USAGE=$(adapter_parse_usage "$OUT/transcript.jsonl")
  case $KILLED in
    cancelled) finish cancelled; exit 0 ;;
    timeout) STATUS=timeout NOTE="killed after ${TIMEOUT_MIN} min" ;;
    max_turns) STATUS=agent_error NOTE="killed after max_turns ($MAX_TURNS)" ;;
    *) STATUS=$(adapter_exit_map "$EXIT" "$OUT/transcript.jsonl") ;;
  esac
  [ "$STATUS" = api_error ] && { finish api_error "harness exit $EXIT"; exit 0; }
  restore_git
fi

# ---- verify: the wrapper runs the task's commands itself, network off ----
phase verify
mapfile -t VCMDS < <(grep . "$IN/verify.txt" 2>/dev/null)
expected=${#VCMDS[@]}
if (( expected > 0 )); then
  docker_run verify none $((TIMEOUT_MIN * 60)) \
    'i=0; while IFS= read -r c || [ -n "$c" ]; do [ -z "$c" ] && continue; i=$((i+1)); bash -c "$c" > /out/$i.log 2>&1 < /dev/null; echo $? > /out/$i.exit; done < /in/verify.txt' \
    -e HOME=/cache/home -v "$OUT/verify:/out"
  [ "$KILLED" = cancelled ] && { finish cancelled; exit 0; }
  cmds='[]'
  for ((i = 1; i <= expected; i++)); do
    x=$(cat "$OUT/verify/$i.exit" 2>/dev/null || echo null)
    # Failing commands keep a longer tail, because that output goes straight into a fix-up brief.
    n=5; [ "$x" != 0 ] && n=60
    t=$(tail -n "$n" "$OUT/verify/$i.log" 2>/dev/null | cut -c1-400)
    cmds=$(jq --arg c "${VCMDS[i-1]}" --arg x "$x" --arg t "$t" '. + [{cmd: $c, exit: ($x | tonumber? // null), tail: $t}]' <<<"$cmds")
  done
  VERIFY=$(jq --arg k "${KILLED:-}" '{passed: (all(.[]; .exit == 0) and ($k == "")), killed: (if $k == "" then null else $k end), commands: .}' <<<"$cmds")
else
  VERIFY='{"passed":null,"killed":null,"commands":[],"note":"no verify commands given"}'
fi

if [ "$MODE" = verify ]; then
  finish ok; exit 0
fi

# ---- guard: flag what the reviewer must look at; the wrapper never trusts REPORT.md ----
phase guard
g add -A
g diff --cached --numstat "$BASE" > "$RUN/numstat.tsv"
g diff --cached --name-status "$BASE" > "$RUN/namestatus.tsv"
g diff --cached -U0 --no-color --no-ext-diff "$BASE" | awk '
  /^diff --git /     { inhunk = 0; next }
  /^\+\+\+ /         { if (!inhunk) { f = substr($0, 7); next } }
  /^@@/              { inhunk = 1; next }
  inhunk && /^\+/    { print "A\t" f "\t" substr($0, 2) }
  inhunk && /^-/     { print "D\t" f "\t" substr($0, 2) }' > "$RUN/difflines.tsv"

TEST_RE='(^|/)(tests?|__tests__|specs?)/|\.(test|spec)\.[^/]+$|_test\.[a-z]+$|(^|/)test_[^/]+\.py$|Tests?\.(java|kt|cs)$'
LOCK_RE='(^|/)(package-lock\.json|npm-shrinkwrap\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?|poetry\.lock|uv\.lock|Pipfile\.lock|Cargo\.lock|go\.sum|Gemfile\.lock|composer\.lock)$'
CONFIG_RE='(^|/)(package\.json|tsconfig[^/]*\.json|\.eslintrc[^/]*|eslint\.config\.[^/]+|\.prettierrc[^/]*|prettier\.config\.[^/]+|(vitest|vite|jest|webpack|rollup|babel|playwright)\.config\.[^/]+|pyproject\.toml|setup\.cfg|setup\.py|tox\.ini|pytest\.ini|\.flake8|ruff\.toml|go\.mod|Cargo\.toml|Makefile|Dockerfile|docker-compose[^/]*|\.gitignore|\.gitattributes|\.editorconfig|\.npmrc|\.nvmrc|\.env[^/]*)$|(^|/)\.github/|(^|/)\.claude/'
SKIP_RE='\.(skip|only)\(|\b(xit|xdescribe|xtest)\(|@pytest\.mark\.(skip|xfail)|pytest\.skip\(|unittest\.skip|t\.Skip\(|@Disabled|@Ignore|#\[ignore\]|\.todo\('
TESTDEF_RE='^[[:space:]]*(it|test|describe)(\.each)?\(|^[[:space:]]*(async[[:space:]]+)?def test_|^[[:space:]]*func Test|@Test\b|#\[test\]'
STUB_RE='\b(TODO|FIXME|XXX|HACK)\b|not implemented|NotImplementedError|unimplemented!|todo!\('
MARKER_RE='^(<<<<<<<|>>>>>>>)( |$)|^=======$'

in_allowlist() {
  local f=$1 p
  [ -s "$IN/files.txt" ] || return 0
  while IFS= read -r p || [ -n "$p" ]; do
    [ -z "$p" ] && continue
    case $p in */) [[ $f == "$p"* ]] && return 0 ;; esac
    # shellcheck disable=SC2053  # unquoted on purpose: plan entries may be globs
    [[ $f == $p ]] && return 0
  done < "$IN/files.txt"
  return 1
}

flags='[]'
flag() { flags=$(jq --arg t "$1" --arg f "$2" --arg d "${3:-}" '. + [{type: $t, file: $f, detail: $d}]' <<<"$flags"); }

while IFS=$'\t' read -r st f f2; do
  [ -n "$f2" ] && f=$f2
  if [[ $st == D* ]] && [[ $f =~ $TEST_RE ]]; then flag deleted_test "$f"; fi
  in_allowlist "$f" && continue
  if [[ $f =~ $LOCK_RE ]]; then flag lockfile_unplanned "$f"
  elif [[ $f =~ $TEST_RE ]]; then flag test_unplanned "$f"
  elif [[ $f =~ $CONFIG_RE ]]; then flag config_unplanned "$f"
  else flag outside_files "$f"
  fi
done < "$RUN/namestatus.tsv"

# One pass over added and removed lines. Bash regex (glibc) understands \b, which awk may not.
declare -A tdef=() hits=()
while IFS=$'\t' read -r kind f line; do
  if [ "$kind" = A ]; then
    for check in "skipped_test:$SKIP_RE" "todo_or_stub:$STUB_RE" "conflict_marker:$MARKER_RE"; do
      t=${check%%:*} re=${check#*:}
      if [[ $line =~ $re ]] && (( ${hits[$t]:-0} < 20 )); then
        hits[$t]=$(( ${hits[$t]:-0} + 1 ))
        flag "$t" "$f" "$(sed 's/^[[:space:]]*//' <<<"$line" | cut -c1-160)"
      fi
    done
  fi
  # Test cases removed: more test definitions deleted than added in a file.
  if [[ $line =~ $TESTDEF_RE ]]; then
    d=-1; [ "$kind" = D ] && d=1
    tdef[$f]=$(( ${tdef[$f]:-0} + d ))
  fi
done < "$RUN/difflines.tsv"
for f in "${!tdef[@]}"; do
  (( tdef[$f] > 0 )) && flag removed_test_cases "$f" "${tdef[$f]} more test definitions removed than added"
done

read -r files added removed < <(awk '{ n++; if ($1 != "-") a += $1; if ($2 != "-") r += $2 } END { print n + 0, a + 0, r + 0 }' "$RUN/numstat.tsv")
(( added + removed > 300 )) && flag diff_size "" "$((added + removed)) changed lines (plan limit ~300)"
(( files == 0 )) && flag empty_diff "" "no changes"
GUARD=$(jq --argjson n "$files" --argjson a "$added" --argjson r "$removed" \
  '{flags: ., files_changed: $n, lines_added: $a, lines_removed: $r}' <<<"$flags")

# ---- commit: squash everything into one commit on the agent branch ----
phase commit
if (( files > 0 )); then
  g merge --quit 2>/dev/null || rm -f "$REPO/.git/MERGE_HEAD" "$REPO/.git/MERGE_MSG" "$REPO/.git/MERGE_MODE"
  g reset -q --soft "$BASE"
  if g -c user.name=subagent -c user.email=subagent@localhost commit -q --no-verify -m "$TITLE" \
     && g push -q -f origin "HEAD:refs/heads/$BRANCH" 2>> "$RUN/remote.log"; then
    COMMIT=$(jq -n --arg s "$(g rev-parse HEAD)" '$s')
  else
    finish infra_error "commit or push failed"; exit 0
  fi
fi

finish "$STATUS"
exit 0
