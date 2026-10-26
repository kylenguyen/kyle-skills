# Harness adapter: pi (@earendil-works/pi-coding-agent).
# Sourced by delegate.sh (adapter_install) and remote-run.sh (everything else).
# Every adapter defines the same five functions so the wrapper stays harness-agnostic.

PI_VERSION=1.4.0

# Dockerfile snippet appended to the base image. Pinned so a pi release can't change behaviour mid-run.
adapter_install() {
  cat <<EOF
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent@${PI_VERSION}
EOF
}

# Env lines for the agent container. An empty HOME and agent dir mean no host config,
# extensions, sessions or skills can load; the version check and telemetry stay off.
adapter_isolate() {
  cat <<'EOF'
HOME=/tmp/home
PI_CODING_AGENT_DIR=/tmp/home/.pi/agent
PI_SKIP_VERSION_CHECK=1
PI_TELEMETRY=0
EOF
}

# Headless command run inside the container with bash -c. $1 brief path, $2 provider, $3 model,
# $4 output dir. stdout is the JSONL transcript; nothing in it is interactive.
adapter_run() {
  local brief=$1 provider=$2 model=$3 out=$4
  printf 'mkdir -p "$HOME" && pi --mode json --no-session --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files --no-approve --provider %q --model %q "$(cat %q)" > %q/transcript.jsonl 2> %q/agent.stderr' \
    "$provider" "$model" "$brief" "$out" "$out"
}

# Model listing command for `delegate.sh doctor`; pi only lists providers whose key env var is set.
adapter_list_models() { printf 'pi --list-models %q' "$1"; }

# Turns so far; remote-run.sh polls this to enforce max_turns, which pi has no flag for.
adapter_turns() {
  [ -s "$1" ] || { echo 0; return; }
  grep -c '"type":"turn_end"' "$1" 2>/dev/null || echo 0
}

# Tokens, cost and turns from the transcript, as JSON for result.json. Nulls if unparseable.
adapter_parse_usage() {
  local t=$1
  [ -s "$t" ] || { echo '{"tokens_in":null,"tokens_out":null,"cost_usd":null,"turns":0}'; return; }
  jq -R 'fromjson? // empty' "$t" | jq -s '
    [ .[] | select(.type == "message_end" and .message.role == "assistant") | .message.usage // empty ] as $u
    | { tokens_in: ([ $u[] | (.input // 0) + (.cacheRead // 0) + (.cacheWrite // 0) ] | add // 0),
        tokens_out: ([ $u[] | .output // 0 ] | add // 0),
        cost_usd: ([ $u[] | .cost.total // 0 ] | add // 0),
        turns: ([ .[] | select(.type == "turn_end") ] | length) }' 2>/dev/null \
    || echo '{"tokens_in":null,"tokens_out":null,"cost_usd":null,"turns":null}'
}

# Maps the harness exit code plus the transcript to ok | agent_error | api_error.
# remote-run.sh decides timeout itself, because it is the one that kills the container.
PI_API_ERROR_RE='40[13]|429|5[0-9][0-9]|unauthori[sz]ed|api[ _-]?key|rate limit|balance|quota|overloaded|ECONNRESET|ENOTFOUND|fetch failed'

adapter_exit_map() {
  local code=$1 t=$2 err
  err=$(jq -R 'fromjson? // empty' "$t" 2>/dev/null | jq -rs '
    [ .[] | select(.type == "message_end" and .message.role == "assistant") ] | last
    | if . != null and .message.stopReason == "error" then (.message.errorMessage // "error") else "" end' 2>/dev/null)
  if [ -n "$err" ]; then
    printf '%s' "$err" | grep -qiE "$PI_API_ERROR_RE" && echo api_error || echo agent_error
  elif [ "$code" != 0 ]; then
    grep -qiE "$PI_API_ERROR_RE" "$(dirname "$t")/agent.stderr" 2>/dev/null && echo api_error || echo agent_error
  else
    echo ok
  fi
}
