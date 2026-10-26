# Harness adapter: omp (oh-my-pi, @oh-my-pi/pi-coding-agent), a pi fork with LSP tools.
# omp keeps pi's JSON event stream, so usage, turn counting and exit mapping are reused from pi.sh.

source "$(dirname "${BASH_SOURCE[0]}")/pi.sh"

OMP_VERSION=18.12.6
BUN_VERSION=1.3.14

# omp runs on Bun, not Node. LSP tools only help if the project image adds language servers.
adapter_install() {
  cat <<EOF
RUN curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash -s "bun-v${BUN_VERSION}" \\
 && BUN_INSTALL=/usr/local bun install -g @oh-my-pi/pi-coding-agent@${OMP_VERSION} \\
 && chmod -R a+rX /usr/local/install
EOF
}

adapter_isolate() {
  cat <<'EOF'
HOME=/tmp/home
PI_CONFIG_DIR=/tmp/home/.omp
PI_CODING_AGENT_DIR=/tmp/home/.omp/agent
EOF
}

adapter_list_models() { printf 'omp models find %q' "$1"; }

# --approval-mode yolo because nobody is there to approve; the container is the boundary.
adapter_run() {
  local brief=$1 provider=$2 model=$3 out=$4
  printf 'mkdir -p "$HOME" && omp -p --mode json --no-session --no-extensions --no-skills --no-rules --approval-mode yolo --model %q "$(cat %q)" > %q/transcript.jsonl 2> %q/agent.stderr' \
    "$provider/$model" "$brief" "$out" "$out"
}
