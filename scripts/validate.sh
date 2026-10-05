#!/usr/bin/env bash
# Usage: validate.sh <repo> [base-commit]
# Reports facts; exit code 1 if a blocking problem is found. Does not run project tests (do that explicitly and report honestly).
set -uo pipefail
SD="$(cd "$(dirname "$0")" && pwd)"; R="${1:?repo}"; BASE="${2:-}"; cd "$R"; BAD=0
ok(){ echo "✓ $1"; }; warn(){ echo "⚠ $1"; }; fail(){ echo "✗ $1"; BAD=1; }
git rev-parse --git-dir >/dev/null 2>&1 || { warn "not a git repo; git checks skipped"; }
if git rev-parse --git-dir >/dev/null 2>&1 && [ -n "$BASE" ]; then
  git merge-base --is-ancestor "$BASE" HEAD 2>/dev/null && ok "history preserved (base $BASE is an ancestor of HEAD)" || fail "base commit is NOT an ancestor of HEAD: history was rewritten"
  DEL=$(git diff --name-only --diff-filter=D "$BASE" 2>/dev/null); [ -z "$DEL" ] && ok "no files deleted since base" || { warn "files deleted since base (confirm each was approved):"; echo "$DEL" | sed 's/^/    /'; }
  git ls-files | grep -Eq '(^|/)\.env$' && fail ".env is tracked" || ok ".env not tracked"
  bash "$SD/scan-secrets.sh" . --changed "$BASE" >/tmp/secrets.out 2>&1 && ok "no secrets in changed files" || { fail "secret scan flagged changed files"; cat /tmp/secrets.out; }
fi
# relative markdown links
MD=$( (git ls-files '*.md' 2>/dev/null || find . -name '*.md' -not -path './node_modules/*') | grep -v '^node_modules/' )
BROKEN=0
for f in $MD; do
  d=$(dirname "$f")
  while read -r l; do
    t="${l%%#*}"; t="${t%% *}"; [ -z "$t" ] && continue
    case "$t" in http*|mailto:*|\#*|/*) continue;; esac
    [ -e "$d/$t" ] || { echo "    broken link in $f -> $t"; BROKEN=$((BROKEN+1)); }
  done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done
[ $BROKEN -eq 0 ] && ok "relative markdown links resolve" || fail "$BROKEN broken relative link(s)"
# mermaid
MB=$(grep -l '```mermaid' $MD 2>/dev/null | wc -l)
if [ "$MB" -gt 0 ]; then command -v mmdc >/dev/null && warn "mermaid present in $MB file(s); run mmdc to render-check" || warn "mermaid present in $MB file(s); syntax NOT machine-checked (mmdc not installed): review manually"; fi
# yaml workflows
if ls .github/workflows/*.y*ml >/dev/null 2>&1 && command -v python3 >/dev/null; then
  python3 - <<'PY' && ok "workflow YAML parses" || warn "workflow YAML check failed or PyYAML missing"
import glob,sys
import yaml
for f in glob.glob('.github/workflows/*.y*ml'): yaml.safe_load(open(f))
PY
fi
git rev-parse --git-dir >/dev/null 2>&1 && { echo; echo "== git status"; git status --short | head -20; }
echo; [ $BAD -eq 0 ] && echo "VALIDATE: no blocking problems (project tests/build must still be run and reported separately)" || echo "VALIDATE: blocking problems found"
exit $BAD
