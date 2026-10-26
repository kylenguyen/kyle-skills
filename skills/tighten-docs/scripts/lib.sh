# lib.sh: helpers shared by inventory.sh and check-invariants.sh. Sourced, not run.
# Written for bash 3.2 (the macOS default): no associative arrays, mapfile or ${x,,}.

# Lines that are comments in most languages. Python docstring bodies don't match, so edits to them
# show up as non-comment changes for the agent to confirm.
COMMENT_RE='^[[:space:]]*(#|//|/\*|\*|--|;|"""|'"'''"'|<!--)'

# Comments that tools read. Changing one changes behaviour, so every change is reported.
DIRECTIVE_RE='^#!|noqa|eslint-|pylint:|type: ?ignore|@ts-|prettier-ignore|shellcheck|hadolint|yamllint|renovate:|^[[:space:]]*# ?syntax=|SPDX-|[Cc]opyright|go:generate|go:build|nolint|rubocop:|istanbul ignore|pragma'

# classify PATH: print the category of a repo-relative path. Run from the repo root, because agent
# files are detected by a SKILL.md next to or one level above them.
classify() {
  local p=$1 dir lower
  dir=$(dirname "$p")
  lower=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')

  case "/$lower" in
    */node_modules/*|*/vendor/*|*/third_party/*|*/dist/*|*/build/*|*/site/*|*/_site/*|*/.git/*|\
    */__snapshots__/*|*/fixtures/*|*/testdata/*|*/test-data/*|*/adr/*|*/adrs/*|*/decisions/*|\
    */changelog*|*/history.md|*/license*|*/licence*|*/notice*|*/copying*|*/security.md|*/code_of_conduct*|\
    *.lock|*/package-lock.json|*/pnpm-lock.yaml|*/go.sum|*.min.js|*.min.css|*.snap|*.map|*.generated.*|*_pb2.py|*.pb.go)
      echo exclude; return ;;
  esac

  case "/$lower" in
    */agents.md|*/claude.md|*/gemini.md|*/.cursorrules|*.mdc|*/copilot-instructions.md|*/skill.md|\
    */.claude/agents/*.md|*/.claude/commands/*.md)
      echo agent; return ;;
  esac
  case "$lower" in
    *.md)
      if [ -f "$dir/SKILL.md" ] || [ -f "$(dirname "$dir")/SKILL.md" ]; then echo agent; return; fi ;;
  esac

  case "/$lower" in
    */.github/issue_template/*|*pull_request_template*) echo template; return ;;
  esac

  case "/$lower" in
    *.po|*.pot|*.strings|*.xliff|*.xlf|*.arb) echo strings; return ;;
    */locales/*|*/locale/*|*/i18n/*|*/translations/*)
      case "$lower" in *.json|*.yml|*.yaml|*.properties) echo strings; return ;; esac ;;
  esac

  case "/$lower" in
    *.md|*.mdx|*.rst|*.adoc|*/readme*|*/contributing*) echo doc; return ;;
    *.ipynb) echo notebook; return ;;
    */package.json|*/composer.json|*openapi*.json|*openapi*.yaml|*openapi*.yml|*swagger*.json|\
    *swagger*.yaml|*swagger*.yml|*asyncapi*.yaml|*asyncapi*.yml|*.schema.json)
      echo schema; return ;;
    *.py|*.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.go|*.rs|*.java|*.kt|*.kts|*.rb|*.sh|*.bash|*.zsh|\
    *.c|*.h|*.cc|*.cpp|*.hpp|*.cs|*.swift|*.php|*.scala|*.lua|*.sql|*.r|*.dart|*.vue|*.svelte|\
    *.ex|*.exs|*.erl|*.hs|*.clj|*.pl|*.ps1)
      echo comments; return ;;
    *.yml|*.yaml|*.toml|*.ini|*.cfg|*.conf|*/dockerfile*|*.dockerfile|*/makefile|*.mk|*.tf|*.hcl|\
    */.env.example|*.env.sample|*/.gitignore|*/.dockerignore|*/.editorconfig)
      echo config; return ;;
  esac

  # Extensionless scripts (bin/foo) are code if they start with a shebang.
  case "$(basename "$lower")" in
    *.*) ;;
    *) if [ "$(head -c 2 "$p" 2>/dev/null)" = '#!' ]; then echo comments; return; fi ;;
  esac
  echo other
}

# is_code CATEGORY: true for categories where only comment text may change.
is_code() {
  case "$1" in comments|config) return 0 ;; esac
  return 1
}

# count_words FILE CATEGORY: words a reader sees. For code and config, comment lines only.
count_words() {
  if is_code "$2"; then
    { grep -E "$COMMENT_RE" "$1" || true; } | wc -w | tr -d ' '
  else
    wc -w < "$1" | tr -d ' '
  fi
}
