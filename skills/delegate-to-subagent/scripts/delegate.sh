#!/usr/bin/env bash
# delegate.sh: run sub-agent tasks in throwaway containers on a remote Docker host.
# Runs on the user's machine from inside the project's git repo (any worktree), or on the Docker
# host itself with server "local".
# Written for bash 3.2 (the macOS default): no associative arrays, mapfile or ${x,,}.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

usage() {
  cat <<'EOF'
Usage: delegate.sh <command> [args]

  doctor                       Check ssh, Docker, image, harness, model, API key and disk
  config --explain [flags]     Print each resolved setting and where it came from
  image build                  Build the base image (Dockerfile + adapter installs) on the server
  run <id> --brief F --title T [options]
                               Run one task; blocks until done, then fetches and prints a summary
  status <id>                  Show the phase of a run
  fetch <id>                   Fetch the branch and outputs of a finished run
  cancel <id>                  Kill a running job
  verify <ref> --verify CMD... Run commands against any ref in a fresh container, network off

run options:
  --verify CMD       Verify command (repeatable). The wrapper runs these after the agent.
  --files GLOB       Expected file or glob (repeatable); the guard allowlist.
  --base REF         Diff and squash base (default HEAD)
  --start REF        Where the agent starts (default: base). Fix-ups start from the agent branch.
  --merge REF        Merge REF into start with conflicts left in place (conflict and rebase fix-ups)
  --branch NAME      Branch to write (default agent/<id>)
  --fake-patch F     Patch for the fake adapter
  --no-wait          Launch and return; use status/fetch later
  --force            Rerun an id whose results already exist locally

Overrides (any command): --harness H --provider P --model M --server S|local --image I
  --timeout-min N --max-turns N --set key=value (flag layer) --plan key=value (plan layer)
EOF
}

die() { echo "delegate: $*" >&2; exit 1; }

# ---- repo locations -------------------------------------------------------------------------
TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null) || die "run inside a git repository"
MAIN_ROOT=$(cd "$(git rev-parse --git-common-dir)/.." && pwd)
RUNS=$MAIN_ROOT/.subagent-runs
EXCLUDE=$(git rev-parse --git-common-dir)/info/exclude
mkdir -p "$(dirname "$EXCLUDE")" "$RUNS"
grep -qx '.subagent-runs/' "$EXCLUDE" 2>/dev/null || echo '.subagent-runs/' >> "$EXCLUDE"

# ---- configuration --------------------------------------------------------------------------
# LAYERS holds "source<TAB>key<TAB>value" lines, highest precedence first; cfg returns the first hit.
LAYERS=
FLAG_LINES= PLAN_LINES=
add_layer() { # add_layer <source> <lines of key=value>
  local src=$1 line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    LAYERS="$LAYERS$src	${line%%=*}	${line#*=}
"
  done <<EOF
$2
EOF
}

# Reads the small YAML subset the config files use: "key: value" and one level of nesting.
yaml_flat() {
  [ -f "$1" ] || return 0
  awk '
    /^[[:space:]]*(#|$)/ { next }
    {
      match($0, /^ */); ind = RLENGTH; line = substr($0, ind + 1)
      sub(/[[:space:]]+#.*$/, "", line)
      k = line; sub(/:.*/, "", k)
      v = line; sub(/^[^:]*:[[:space:]]*/, "", v)
      if (v ~ /^".*"$/ || v ~ /^'\''.*'\''$/) v = substr(v, 2, length(v) - 2)
      if (ind == 0) { parent = ""; if (v == "") { parent = k; next } print k "=" v }
      else if (parent != "") print parent "." k "=" v
    }' "$1"
}

defaults() {
  cat <<EOF
harness=pi
provider=deepseek
model=deepseek-flash
server=as1.manee-goby.ts.net
project=$(basename "$MAIN_ROOT")
image=subagent-base:v1
setup=
timeout_min=20
max_turns=60
max_parallel=2
max_fixup_rounds=2
max_run_spend_usd=5
resources.cpus=4
resources.memory=8g
resources.pids=512
egress_hosts=
api_key_env.deepseek=DEEPSEEK_API_KEY
api_key_env.fake=
EOF
}

resolve_config() {
  local envs=
  [ -n "${SUBAGENT_HARNESS:-}" ] && envs="${envs}harness=$SUBAGENT_HARNESS
"
  [ -n "${SUBAGENT_PROVIDER:-}" ] && envs="${envs}provider=$SUBAGENT_PROVIDER
"
  [ -n "${SUBAGENT_MODEL:-}" ] && envs="${envs}model=$SUBAGENT_MODEL
"
  LAYERS=
  add_layer flag "$FLAG_LINES"
  add_layer plan "$PLAN_LINES"
  add_layer env "$envs"
  add_layer "project:.claude/subagent.yaml" "$(yaml_flat "$TOPLEVEL/.claude/subagent.yaml")"
  add_layer "user:~/.claude/subagent.yaml" "$(yaml_flat "$HOME/.claude/subagent.yaml")"
  add_layer default "$(defaults)"
  if printf '%s' "$LAYERS" | awk -F'\t' '$2 ~ /^api_key_env\./ && $3 != "" && $3 !~ /^[A-Z_][A-Z0-9_]*$/ { bad = 1 } END { exit !bad }'; then
    die "api_key_env must name an environment variable, not hold a key"
  fi
}

cfg() { printf '%s' "$LAYERS" | awk -F'\t' -v k="$1" '$2 == k { print $3; found = 1; exit } END { exit !found }' || true; }
cfg_src() { printf '%s' "$LAYERS" | awk -F'\t' -v k="$1" '$2 == k { print $1; exit }'; }

key_var() { # env var holding the API key for the resolved provider ("" for none)
  local h p v
  h=$(cfg harness) p=$(cfg provider)
  [ "$h" = fake ] && return 0
  v=$(cfg "api_key_env.$p")
  if [ -z "$v" ] && ! printf '%s' "$LAYERS" | awk -F'\t' -v k="api_key_env.$p" '$2 == k { f = 1 } END { exit !f }'; then
    v=$(printf '%s_API_KEY' "$p" | tr 'a-z-' 'A-Z_')
  fi
  printf '%s' "$v"
}

# ---- ssh helpers ----------------------------------------------------------------------------
SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=15 -o ServerAliveCountMax=4"
# server "local" means this machine is the Docker host (Claude Code running on the server itself):
# the same command strings run under bash instead of ssh, and git uses the bare repo's path.
is_local() { [ "$(cfg server)" = local ]; }
rsh() { if is_local; then bash -c "$*"; else ssh $SSH_OPTS "$(cfg server)" "$@"; fi; }
bare_url() {
  if is_local; then printf '%s/subagent/repos/%s.git' "$HOME" "$(cfg project)"
  else printf 'ssh://%s/~/subagent/repos/%s.git' "$(cfg server)" "$(cfg project)"; fi
}
export GIT_SSH_COMMAND="ssh $SSH_OPTS"

# macOS bsdtar adds xattr headers that GNU tar on the server warns about.
tar_c() {
  if tar --version 2>/dev/null | grep -q bsdtar; then COPYFILE_DISABLE=1 tar --no-xattrs --no-mac-metadata -c "$@"
  else tar -c "$@"; fi
}

# Copies remote-run.sh and the adapters (every run, so the server copy never goes stale) plus any
# extra staged tree, and makes sure the bare repo exists. One ssh connection.
sync_server() { # sync_server [staging-dir containing runs/<id>/in]
  local stage
  stage=$(mktemp -d)
  mkdir -p "$stage/bin"
  cp "$SCRIPT_DIR/remote-run.sh" "$stage/bin/"
  cp -R "$SCRIPT_DIR/adapters" "$stage/bin/"
  [ -n "${1:-}" ] && cp -R "$1/." "$stage/"
  tar_c -C "$stage" -f - . | rsh "mkdir -p ~/subagent/repos ~/subagent/runs ~/subagent/cache \
    && tar -C ~/subagent -xf - \
    && { test -d ~/subagent/repos/$(cfg project).git || git init -q --bare ~/subagent/repos/$(cfg project).git; }"
  rm -rf "$stage"
}

# ---- argument parsing -----------------------------------------------------------------------
POS=() VERIFY_CMDS=() FILES=()
BRIEF= TITLE= BASE_REF=HEAD START_REF= MERGE_REF= BRANCH= FAKE_PATCH= NO_WAIT= FORCE= EXPLAIN=
parse_args() {
  while [ $# -gt 0 ]; do
    case $1 in
      --harness|--provider|--model|--server|--image)
        FLAG_LINES="$FLAG_LINES${1#--}=$2
"; shift ;;
      --timeout-min) FLAG_LINES="${FLAG_LINES}timeout_min=$2
"; shift ;;
      --max-turns) FLAG_LINES="${FLAG_LINES}max_turns=$2
"; shift ;;
      --set) FLAG_LINES="$FLAG_LINES$2
"; shift ;;
      --plan) PLAN_LINES="$PLAN_LINES$2
"; shift ;;
      --brief) BRIEF=$2; shift ;;
      --title) TITLE=$2; shift ;;
      --verify) VERIFY_CMDS+=("$2"); shift ;;
      --files) FILES+=("$2"); shift ;;
      --base) BASE_REF=$2; shift ;;
      --start) START_REF=$2; shift ;;
      --merge) MERGE_REF=$2; shift ;;
      --branch) BRANCH=$2; shift ;;
      --fake-patch) FAKE_PATCH=$2; shift ;;
      --no-wait) NO_WAIT=1 ;;
      --force) FORCE=1 ;;
      --explain) EXPLAIN=1 ;;
      -h|--help) usage; exit 0 ;;
      -*) die "unknown option $1" ;;
      *) POS+=("$1") ;;
    esac
    shift
  done
}

check_id() {
  printf '%s' "$1" | grep -Eq '^[a-z0-9][a-z0-9._-]{0,80}$' \
    || die "run id must be lowercase letters, digits, '.', '_' or '-' (got '$1')"
}

sha_of() { git rev-parse --verify --quiet "$1^{commit}" || die "unknown ref $1"; }

# ---- commands -------------------------------------------------------------------------------
cmd_config() {
  local k
  printf '%-24s %-36s %s\n' KEY VALUE SOURCE
  for k in harness provider model server project image setup timeout_min max_turns max_parallel \
           max_fixup_rounds max_run_spend_usd resources.cpus resources.memory resources.pids egress_hosts; do
    printf '%-24s %-36s %s\n' "$k" "$(cfg "$k")" "$(cfg_src "$k")"
  done
  printf '%-24s %-36s %s\n' "api key env var" "$(key_var)" "api_key_env.$(cfg provider)"
}

# The server-side half of doctor. Each check prints "ok|msg" or "FAIL|msg".
doctor_script() {
  local h=$1 k=$2 img=$3 model=$4 provider=$5
  cat <<EOF
check() { if eval "\$2" >/dev/null 2>&1; then echo "ok|\$1"; else echo "FAIL|\$1"; fi; }
check "docker without sudo" "docker info"
check "git" "command -v git"
check "jq" "command -v jq"
check "image $img" "docker image inspect '$img'"
if [ "$h" != fake ]; then
  check "harness $h in image" "docker run --rm '$img' sh -c 'command -v $h'"
  source ~/subagent/bin/adapters/$h.sh
  # A placeholder key makes the harness list the provider's catalog without the real secret.
  if docker run --rm -e HOME=/tmp -e '${k:-NO_KEY}=placeholder' '$img' bash -c "\$(adapter_list_models '$model')" 2>/dev/null | grep -qw -- '$model'; then
    echo "ok|model $provider/$model listed by $h"
  else
    echo "FAIL|model $model not listed by $h; run: docker run --rm -e ${k:-NO_KEY}=x $img \$(adapter_list_models $provider)"
  fi
fi
if [ -n "$k" ]; then
  f=~/subagent/secrets.env
  if [ ! -f \$f ]; then echo "FAIL|\$f missing (see references/server-setup.md)"
  elif [ "\$(stat -c %a \$f)" != 600 ]; then echo "FAIL|\$f must be mode 600"
  elif grep -q '^$k=.' \$f; then echo "ok|$k set in \$f"
  else echo "FAIL|$k not set in \$f"; fi
fi
free=\$(df -Pk ~ | awk 'NR == 2 { print int(\$4 / 1048576) }')
if [ "\$free" -ge 10 ]; then echo "ok|disk \${free} GB free"; else echo "FAIL|disk only \${free} GB free (need 10)"; fi
EOF
}

cmd_doctor() {
  local fails=0 out tmp
  ok() { printf '  ok    %s\n' "$*"; }
  bad() { printf '  FAIL  %s\n' "$*"; fails=$((fails + 1)); }
  warn() { printf '  warn  %s\n' "$*"; }
  echo "local"
  command -v jq >/dev/null && ok "jq" || bad "jq not found locally (brew install jq)"
  [ -z "$(git status --porcelain)" ] && ok "working tree clean" || warn "working tree has uncommitted changes"
  if is_local; then
    echo "server local (this machine)"
    sync_server 2>/dev/null || { bad "setting up ~/subagent failed"; echo "$fails check(s) failed"; return 1; }
  else
    echo "server $(cfg server)"
    sync_server 2>/dev/null || { bad "ssh to $(cfg server) failed"; echo "$fails check(s) failed"; return 1; }
  fi
  tmp=$(mktemp)
  doctor_script "$(cfg harness)" "$(key_var)" "$(cfg image)" "$(cfg model)" "$(cfg provider)" > "$tmp"
  if ! out=$(rsh "bash -s" < "$tmp" 2>&1); then
    rm -f "$tmp"; bad "ssh: $out"; echo "$fails check(s) failed"; return 1
  fi
  rm -f "$tmp"
  while IFS='|' read -r st msg; do
    case $st in ok) ok "$msg" ;; FAIL) bad "$msg" ;; *) [ -n "$st" ] && warn "$st $msg" ;; esac
  done <<EOF
$out
EOF
  if [ "$fails" = 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; return 1; fi
}

cmd_image() {
  [ "${POS[1]:-}" = build ] || die "usage: delegate.sh image build"
  local stage a
  stage=$(mktemp -d)
  mkdir -p "$stage/image"
  {
    cat "$SCRIPT_DIR/Dockerfile"
    for a in "$SCRIPT_DIR"/adapters/*.sh; do
      ( source "$a"; adapter_install )
    done
  } > "$stage/image/Dockerfile"
  sync_server "$stage"
  rm -rf "$stage"
  rsh "docker build -q -t '$(cfg image)' ~/subagent/image" && echo "built $(cfg image) on $(cfg server)"
}

# Writes in/ for a run, pushes the refs it needs, starts remote-run.sh under nohup.
launch() { # launch <id> <mode> <base-sha> <start-sha> <merge-sha>
  local id=$1 mode=$2 base=$3 start=$4 merge=$5 dir stage in refs
  dir=$RUNS/$id
  stage=$(mktemp -d)
  in=$stage/runs/$id/in
  mkdir -p "$in"
  if [ "$mode" = task ]; then cp "$BRIEF" "$in/brief.md"; else : > "$in/brief.md"; fi
  : > "$in/verify.txt"; : > "$in/files.txt"
  for c in ${VERIFY_CMDS[@]+"${VERIFY_CMDS[@]}"}; do printf '%s\n' "$c" >> "$in/verify.txt"; done
  for f in ${FILES[@]+"${FILES[@]}"}; do printf '%s\n' "$f" >> "$in/files.txt"; done
  [ -n "$FAKE_PATCH" ] && cp "$FAKE_PATCH" "$in/fake.patch"
  {
    printf '%s=%q\n' MODE "$mode" HARNESS "$(cfg harness)" PROVIDER "$(cfg provider)" MODEL "$(cfg model)" \
      IMAGE "$(cfg image)" SETUP "$(cfg setup)" TIMEOUT_MIN "$(cfg timeout_min)" MAX_TURNS "$(cfg max_turns)" \
      CPUS "$(cfg resources.cpus)" MEMORY "$(cfg resources.memory)" PIDS "$(cfg resources.pids)" \
      BASE "$base" START "$start" MERGE "$merge" BRANCH "$BRANCH" TITLE "$TITLE" \
      PROJECT "$(cfg project)" KEY_VAR "$(key_var)"
  } > "$in/job.env"
  rm -rf "$dir"; mkdir -p "$dir"
  cp -R "$in" "$dir/in"
  sync_server "$stage"
  rm -rf "$stage"
  refs="$base:refs/heads/base/$id $start:refs/heads/start/$id"
  [ -n "$merge" ] && refs="$refs $merge:refs/heads/merge/$id"
  # shellcheck disable=SC2086
  git push -q -f "$(bare_url)" $refs
  # setsid detaches the job from the caller's process group, which a local caller may kill on exit.
  rsh "cd ~/subagent && setsid nohup bash bin/remote-run.sh '$id' > runs/'$id'/remote.out 2>&1 < /dev/null &"
  if [ "$mode" = task ]; then
    echo "launched $id ($(cfg harness) $(cfg provider)/$(cfg model)) on $(cfg server)"
  else
    echo "launched $id (verify) on $(cfg server)"
  fi
}

remote_state() { # prints done:<status> | running:<phase> | missing
  rsh "d=~/subagent/runs/'$1'; if [ -f \$d/done ]; then echo done:\$(cat \$d/done); elif [ -d \$d ]; then echo running:\$(cat \$d/phase 2>/dev/null || echo starting); else echo missing; fi"
}

# Polls until done. Tolerates ssh drops for about ten minutes, then hands back to status/fetch.
wait_for() {
  local id=$1 s last= drops=0
  while :; do
    if s=$(remote_state "$id" 2>/dev/null); then
      drops=0
      case $s in
        done:*) echo "finished: ${s#done:}"; return 0 ;;
        *) [ "$s" != "$last" ] && echo "$s" && last=$s ;;
      esac
    else
      drops=$((drops + 1))
      [ $drops -ge 40 ] && die "lost ssh for 10 minutes; the job keeps running. Reconnect with: delegate.sh status $id / fetch $id"
    fi
    sleep 15
  done
}

summary() { # one-line digest of result.json so Opus rarely needs to open it
  jq -r '
    def vs: if .verify.passed == null then "none" elif .verify.passed then "pass" else "FAIL" end
      + " (\([.verify.commands[] | select(.exit == 0)] | length)/\(.verify.commands | length))";
    "status=\(.status)\(if .note != "" then " (\(.note))" else "" end) verify=\(vs)"
    + (if .mode == "task" then
        " guard=\(.guard.flags | length) flags diff=+\(.guard.lines_added)/-\(.guard.lines_removed) in \(.guard.files_changed) files"
        + " commit=\(.commit // "none" | .[0:10]) cost=$\(.usage.cost_usd // "?") turns=\(.usage.turns // "?")"
       else "" end),
    (.guard.flags // [] | group_by(.type)[] | "  \(.[0].type): \([.[] | .file + (if .detail != "" then " \(.detail)" else "" end)] | join("; ") | .[0:300])"),
    (.verify.commands[] | select(.exit != 0) | "  failed: \(.cmd) (exit \(.exit))")' "$1"
}

cmd_fetch() {
  local id=$1 dir=$RUNS/$1 branch mode
  [ -f "$dir/in/job.env" ] || die "no local record of $id"
  branch=$(sed -n 's/^BRANCH=//p' "$dir/in/job.env") mode=$(sed -n 's/^MODE=//p' "$dir/in/job.env")
  rsh "test -f ~/subagent/runs/'$id'/done" || die "$id has not finished; see delegate.sh status $id"
  mkdir -p "$dir"
  rsh "tar -C ~/subagent/runs/'$id'/out -cf - ." | tar -C "$dir" -xf -
  if [ "$mode" = task ] && [ "$(jq -r '.commit // empty' "$dir/result.json")" != "" ]; then
    git fetch -q -f "$(bare_url)" "+refs/heads/$branch:refs/heads/$branch"
  fi
  echo "results in ${dir#$MAIN_ROOT/}/"
  summary "$dir/result.json"
}

cmd_run() {
  local id=${POS[1]:-} base start merge=
  [ -n "$id" ] || die "usage: delegate.sh run <id> --brief F --title T ..."
  check_id "$id"
  [ -f "$BRIEF" ] || die "--brief file not found"
  [ -n "$TITLE" ] || die "--title is required (becomes the commit message)"
  [ -n "$FAKE_PATCH" ] && [ ! -f "$FAKE_PATCH" ] && die "--fake-patch file not found"
  if [ -f "$RUNS/$id/result.json" ] && [ -z "$FORCE" ]; then
    die "$id already has results; use a new id (e.g. $id-fix1) or --force"
  fi
  if [ -z "$FORCE" ] && rsh "test -d ~/subagent/runs/'$id' && ! test -f ~/subagent/runs/'$id'/done" 2>/dev/null; then
    die "$id is already running on the server; use status/fetch/cancel"
  fi
  base=$(sha_of "$BASE_REF")
  start=$(sha_of "${START_REF:-$BASE_REF}")
  [ -n "$MERGE_REF" ] && merge=$(sha_of "$MERGE_REF")
  BRANCH=${BRANCH:-agent/$id}
  launch "$id" task "$base" "$start" "$merge"
  [ -n "$NO_WAIT" ] && return 0
  wait_for "$id"
  cmd_fetch "$id"
}

cmd_verify() {
  local ref=${POS[1]:-} sha id
  [ -n "$ref" ] || die "usage: delegate.sh verify <ref> --verify CMD..."
  [ ${#VERIFY_CMDS[@]} -gt 0 ] || die "give at least one --verify command"
  sha=$(sha_of "$ref")
  id=verify-$(printf '%s' "$sha" | cut -c1-10)-$(date +%s)
  BRANCH= TITLE="verify $ref"
  launch "$id" verify "$sha" "$sha" ""
  wait_for "$id"
  cmd_fetch "$id"
}

main() {
  [ $# -gt 0 ] || { usage; exit 1; }
  parse_args "$@"
  resolve_config
  case ${POS[0]:-} in
    doctor) cmd_doctor ;;
    config) cmd_config ;;
    image) cmd_image ;;
    run) cmd_run ;;
    status)
      [ -n "${POS[1]:-}" ] || die "usage: delegate.sh status <id>"
      remote_state "${POS[1]}" ;;
    fetch)
      [ -n "${POS[1]:-}" ] || die "usage: delegate.sh fetch <id>"
      cmd_fetch "${POS[1]}" ;;
    cancel)
      [ -n "${POS[1]:-}" ] || die "usage: delegate.sh cancel <id>"
      rsh "touch ~/subagent/runs/'${POS[1]}'/cancel" && echo "cancel requested for ${POS[1]}" ;;
    verify) cmd_verify ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
