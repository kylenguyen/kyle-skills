#!/usr/bin/env bash
# check-invariants.sh: snapshot files before tighten-docs edits them, then report exact strings that
# were lost (code, paths, numbers, placeholders, URLs, headings), code lines that changed and links
# that no longer resolve. It checks strings, not meaning; the Stage 5 reviewer checks meaning.
# Run from anywhere inside the target repo. File paths are relative to the repo root.
# Written for bash 3.2 (the macOS default): no associative arrays, mapfile or ${x,,}.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
Usage: check-invariants.sh snapshot RUN_DIR (FILE... | -)
       check-invariants.sh compare RUN_DIR [--current DIR]

  snapshot   Copy FILEs (or paths read from stdin with -) to RUN_DIR/baseline/ and record them in
             RUN_DIR/files.txt. Adds the run directory to .git/info/exclude.
  compare    Compare each baseline file with its current version (in the repo, or under DIR for
             report-only runs). Exit 0: nothing lost. Exit 2: findings to resolve.
EOF
}

die() { echo "check-invariants: $*" >&2; exit 1; }

[ $# -ge 2 ] || { usage >&2; exit 1; }
cmd=$1; run=$2; shift 2
case "$run" in /*) ;; *) run="$PWD/$run" ;; esac

if root=$(git rev-parse --show-toplevel 2>/dev/null); then in_git=1; else root=$PWD; in_git=0; fi
cd "$root"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

tag() { awk -v t="$1" '{ print t "\t" $0 }'; }

# facts FILE CATEGORY: print "kind<TAB>value" lines, sorted and unique.
facts() {
  local f=$1 cat=$2
  : > "$WORK/prose"
  {
    if is_code "$cat"; then
      grep -E "$COMMENT_RE" "$f" > "$WORK/prose" || true
    else
      # Lines inside fenced code blocks must survive exactly; everything else is prose.
      awk -v prose="$WORK/prose" '
        /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
        infence { if ($0 ~ /[^[:space:]]/) print "code-line\t" $0; next }
        { print > prose }' "$f"
      grep -E '^#{1,6}[[:space:]]' "$WORK/prose" | sed -E 's/[[:space:]]+$//' | tag heading || true
      # Frontmatter keys, and quoted phrases in it: a SKILL.md description's trigger phrases.
      awk 'NR == 1 && /^---[[:space:]]*$/ { fm = 1; next } fm && /^---[[:space:]]*$/ { exit } fm' "$f" \
        > "$WORK/frontmatter"
      grep -oE '^[A-Za-z_][A-Za-z0-9_-]*:' "$WORK/frontmatter" | tag frontmatter-key || true
      grep -oE '"[^"]+"' "$WORK/frontmatter" | tag trigger || true
    fi
    grep -oE '`[^`]+`' "$WORK/prose" | tag span || true
    grep -oE 'https?://[^[:space:]<>()"`]+' "$WORK/prose" | sed -E 's/[.,;:]+$//' | tag url || true

    # Placeholders, numbers and paths outside code spans and URLs. List markers ("1. ") are not facts.
    sed -E 's/`[^`]*`//g; s#https?://[^[:space:]<>()"]+##g; s/^[[:space:]]*[0-9]+[.)][[:space:]]+//' \
      "$WORK/prose" > "$WORK/stripped"
    grep -oE '\{[A-Z][A-Z0-9_]*\}' "$WORK/stripped" | tag placeholder || true
    grep -oE '[0-9]+([.,][0-9]+)*%?' "$WORK/stripped" | tag number || true
    tr -s '\050\051\074\076\054\073\042\047\174\040\011\133\135' '\n' < "$WORK/stripped" \
      | sed -E 's/^[*_]+//; s/[*_.:!?]+$//' \
      | grep -E '[[:alnum:]_}*-]/|/[[:alnum:]_{.*-]|\.(md|mdc|sh|json|ya?ml|toml|py|js|ts|tsx|txt|csv|html|ipynb)$' \
      | tag path || true
  } | LC_ALL=C sort -u
}

# broken_links FILE CURRENT_ROOT: relative Markdown links whose target does not exist.
broken_links() {
  local f=$1 cur_root=$2 t target d
  d=$(dirname "$f")
  { grep -oE '\]\([^)[:space:]]+' "$cur_root/$f" || true; } | sed 's/^](//' | while IFS= read -r t; do
    case "$t" in http://*|https://*|mailto:*|\#*) continue ;; esac
    t=${t%%#*}
    [ -n "$t" ] || continue
    case "$t" in
      /*) target=${t#/} ;;
      *) target="$d/$t" ;;
    esac
    # In report-only runs, links may point at files that only exist in the repo.
    [ -e "$cur_root/$target" ] || [ -e "$target" ] || echo "  broken link: $t"
  done
}

snapshot() {
  [ $# -gt 0 ] || die "snapshot needs files, or - to read them from stdin"
  if [ "$1" = - ]; then cat > "$WORK/list"; else printf '%s\n' "$@" > "$WORK/list"; fi
  mkdir -p "$run/baseline"
  : > "$run/files.txt"
  local n=0 f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ -f "$f" ] || die "not a file (paths must be relative to $root): $f"
    mkdir -p "$run/baseline/$(dirname "$f")"
    cp "$f" "$run/baseline/$f"
    echo "$f" >> "$run/files.txt"
    n=$((n + 1))
  done < "$WORK/list"

  if [ "$in_git" = 1 ]; then
    case "$run" in
      "$root"/*)
        local rel top exclude
        rel=${run#"$root"/}; top=${rel%%/*}
        exclude=$(git rev-parse --git-path info/exclude)
        mkdir -p "$(dirname "$exclude")"
        grep -qxF "/$top/" "$exclude" 2>/dev/null || echo "/$top/" >> "$exclude"
        ;;
    esac
  fi
  echo "Snapshot: $n files -> $run/baseline"
}

compare() {
  local cur_root=.
  while [ $# -gt 0 ]; do
    case "$1" in
      --current) cur_root=$2; shift 2 ;;
      *) die "unknown option $1" ;;
    esac
  done
  [ -f "$run/files.txt" ] || die "no snapshot in $run (run snapshot first)"

  local f cat base cur wb wa nfind tb=0 ta=0 nfiles=0 total_find=0
  while IFS= read -r f; do
    base="$run/baseline/$f"; cur="$cur_root/$f"
    cat=$(classify "$f")
    nfiles=$((nfiles + 1))
    : > "$WORK/section"
    if [ ! -f "$cur" ]; then
      echo "  deleted file" >> "$WORK/section"
      wa=0
    else
      facts "$base" "$cat" > "$WORK/before"
      facts "$cur" "$cat" > "$WORK/after"
      LC_ALL=C comm -23 "$WORK/before" "$WORK/after" \
        | awk '{ sub(/\t/, ": "); print "  lost " $0 }' >> "$WORK/section"
      if is_code "$cat"; then
        { diff "$base" "$cur" || true; } \
          | awk '/^< /{ print "removed: " substr($0, 3) } /^> /{ print "added: " substr($0, 3) }' \
          | while IFS= read -r line; do
              body=${line#*: }
              [ -n "$(printf '%s' "$body" | tr -d '[:space:]')" ] || continue
              if printf '%s\n' "$body" | grep -qE "$DIRECTIVE_RE"; then
                echo "  directive changed, $line"
              elif ! printf '%s\n' "$body" | grep -qE "$COMMENT_RE"; then
                echo "  non-comment line changed (confirm only comment or docstring text differs), $line"
              fi
            done >> "$WORK/section"
      else
        broken_links "$f" "$cur_root" >> "$WORK/section"
      fi
      wa=$(count_words "$cur" "$cat")
    fi
    wb=$(count_words "$base" "$cat")
    tb=$((tb + wb)); ta=$((ta + wa))
    nfind=$(wc -l < "$WORK/section" | tr -d ' ')
    total_find=$((total_find + nfind))
    echo "== $f ($cat): $wb -> $wa words, $nfind findings"
    cat "$WORK/section"
  done < "$run/files.txt"

  local pct=0
  [ "$tb" -eq 0 ] || pct=$(( (ta - tb) * 100 / tb ))
  echo
  echo "Total: $nfiles files, $tb -> $ta words (${pct}%), $total_find findings"
  [ "$total_find" -eq 0 ] || exit 2
}

case "$cmd" in
  snapshot) snapshot "$@" ;;
  compare) compare "$@" ;;
  -h|--help) usage ;;
  *) usage >&2; exit 1 ;;
esac
