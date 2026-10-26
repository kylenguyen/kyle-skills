#!/usr/bin/env bash
# inventory.sh: list the files tighten-docs can edit under a scope, by category, with word counts.
# Run from anywhere inside the target repo. Output paths are relative to the repo root.
# Written for bash 3.2 (the macOS default): no associative arrays, mapfile or ${x,,}.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPT_DIR/lib.sh"

ALL_CATS="agent doc template comments config schema notebook strings"

usage() {
  cat <<'EOF'
Usage: inventory.sh [--include CATS] [--paths-only] [PATH...]

Lists files under PATH (default: current directory) that tighten-docs can edit.

  --include CATS   Comma-separated categories to include (default: agent,doc,template).
                   All: agent,doc,template,comments,config,schema,notebook,strings
  --paths-only     Print included paths only, one per line (feeds check-invariants.sh snapshot -)

Categories left out are summarised as "available on request". Excluded files (changelogs,
licences, ADRs, fixtures, generated and vendored files) are listed so the user sees what is skipped.
EOF
}

include="agent,doc,template"
paths_only=0
while [ $# -gt 0 ]; do
  case "$1" in
    --include) include=$2; shift 2 ;;
    --paths-only) paths_only=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "inventory: unknown option $1" >&2; usage >&2; exit 1 ;;
    *) break ;;
  esac
done
[ $# -gt 0 ] || set -- .

in_list() { case ",$2," in *",$1,"*) return 0 ;; esac; return 1; }

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# List candidate files, then work from the repo root so paths and SKILL.md detection line up.
if root=$(git rev-parse --show-toplevel 2>/dev/null); then
  git ls-files --cached --others --exclude-standard --full-name -- "$@" | sort -u > "$WORK/files"
  git status --porcelain -- "$@" > "$WORK/dirty"
  cd "$root"
  in_git=1
else
  root=$PWD
  find "$@" \( -name .git -o -name node_modules -o -name .venv -o -name venv \) -prune -o -type f -print \
    | sed 's|^\./||' | sort -u > "$WORK/files"
  : > "$WORK/dirty"
  in_git=0
fi

: > "$WORK/rows"
: > "$WORK/excluded"
while IFS= read -r f; do
  [ -f "$f" ] || continue
  cat=$(classify "$f")
  case "$cat" in
    other) continue ;;
    exclude) echo "$f" >> "$WORK/excluded"; continue ;;
  esac
  printf '%s\t%s\t%s\n' "$cat" "$(count_words "$f" "$cat")" "$f" >> "$WORK/rows"
done < "$WORK/files"

if [ "$paths_only" = 1 ]; then
  while IFS="$(printf '\t')" read -r cat words f; do
    if in_list "$cat" "$include"; then echo "$f"; fi
  done < "$WORK/rows"
  exit 0
fi

if [ "$in_git" = 1 ]; then
  echo "Repo root: $root"
else
  echo "Repo root: $root (not a git repo: no undo, use report-only mode)"
fi
echo "Scope: $*"
echo
echo "Included ($include):"
printf '%-9s %7s  %s\n' category words path
n=0; total=0
for c in $ALL_CATS; do
  in_list "$c" "$include" || continue
  while IFS="$(printf '\t')" read -r cat words f; do
    [ "$cat" = "$c" ] || continue
    printf '%-9s %7s  %s\n' "$cat" "$words" "$f"
    n=$((n + 1)); total=$((total + words))
  done < "$WORK/rows"
done
echo "Total: $n files, $total words"

echo
echo "Available on request (not included):"
any=0
for c in $ALL_CATS; do
  in_list "$c" "$include" && continue
  cn=0; cw=0
  while IFS="$(printf '\t')" read -r cat words f; do
    [ "$cat" = "$c" ] || continue
    cn=$((cn + 1)); cw=$((cw + words))
  done < "$WORK/rows"
  [ "$cn" -gt 0 ] || continue
  printf '%-9s %4s files %7s words\n' "$c" "$cn" "$cw"
  any=1
done
[ "$any" = 1 ] || echo "(none)"

ne=$(wc -l < "$WORK/excluded" | tr -d ' ')
echo
echo "Excluded (always): $ne files"
head -20 "$WORK/excluded" | sed 's/^/  /'
[ "$ne" -le 20 ] || echo "  ... and $((ne - 20)) more"

if [ -s "$WORK/dirty" ]; then
  echo
  echo "Warning: uncommitted changes in scope (git diff will mix them with tighten-docs edits):"
  sed 's/^/  /' "$WORK/dirty"
fi
