# Harness adapter: fake. Applies a canned patch instead of calling a model, so the pipeline,
# guard checks and resume can be tested without API spend.
#
# Inputs (copied into /in by delegate.sh run --fake-patch FILE): /in/fake.patch.
# FAKE_MODE in the brief's first line, e.g. "<!-- FAKE_MODE=timeout -->", simulates failures:
#   ok (default) | timeout (sleeps forever) | turns (one turn a second, forever) |
#   api_error (exits 1 with a 401) | empty (changes nothing)

adapter_install() { :; }

adapter_isolate() {
  echo HOME=/tmp/home
}

adapter_run() {
  local brief=$1 out=$4
  cat <<EOF
set -u
mode=\$(sed -n '1s/.*FAKE_MODE=\([a-z_]*\).*/\1/p' $brief); mode=\${mode:-ok}
emit() { printf '%s\n' "\$1" >> $out/transcript.jsonl; }
emit '{"type":"session","version":3}'
emit '{"type":"agent_start"}'
case \$mode in
  timeout) exec sleep 100000 ;;
  turns) while :; do emit '{"type":"turn_start"}'; emit '{"type":"turn_end"}'; sleep 1; done ;;
  api_error)
    emit '{"type":"message_end","message":{"role":"assistant","stopReason":"error","errorMessage":"401 Unauthorized: invalid api key","usage":{"input":0,"output":0,"cost":{"total":0}}}}'
    echo "401 Unauthorized" >&2; exit 1 ;;
esac
if [ "\$mode" = ok ] && [ -f /in/fake.patch ]; then
  git apply --whitespace=nowarn /in/fake.patch || { echo "fake.patch did not apply" >&2; exit 2; }
fi
for i in 1 2; do
  emit '{"type":"turn_start"}'
  emit '{"type":"message_end","message":{"role":"assistant","stopReason":"stop","usage":{"input":1000,"output":200,"cacheRead":0,"cacheWrite":0,"cost":{"total":0.0005}}}}'
  emit '{"type":"turn_end"}'
done
emit '{"type":"agent_end"}'
cat > $out/REPORT.md <<'REPORT'
## Summary
Fake adapter applied the canned patch.

## Verify
Not run by the fake adapter.

## Deviations
None.

## Open issues
None.
REPORT
EOF
}

adapter_list_models() { printf 'echo %q' "$1"; }

adapter_turns() {
  [ -s "$1" ] || { echo 0; return; }
  grep -c '"type":"turn_end"' "$1" 2>/dev/null || echo 0
}

adapter_parse_usage() {
  local t=$1
  [ -s "$t" ] || { echo '{"tokens_in":null,"tokens_out":null,"cost_usd":null,"turns":0}'; return; }
  jq -R 'fromjson? // empty' "$t" | jq -s '
    [ .[] | select(.type == "message_end") | .message.usage // empty ] as $u
    | { tokens_in: ([ $u[] | .input // 0 ] | add // 0), tokens_out: ([ $u[] | .output // 0 ] | add // 0),
        cost_usd: ([ $u[] | .cost.total // 0 ] | add // 0), turns: ([ .[] | select(.type == "turn_end") ] | length) }'
}

adapter_exit_map() {
  case $1 in
    0) echo ok ;;
    1) echo api_error ;;
    *) echo agent_error ;;
  esac
}
