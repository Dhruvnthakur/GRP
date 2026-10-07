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
  bash "$SD/detect_secrets.sh" . --changed "$BASE" >/tmp/secrets.out 2>&1 && ok "no secrets in changed files" || { fail "secret scan flagged changed files"; cat /tmp/secrets.out; }
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
# ---- README-specific checks
RD=$(ls README.md README README.rst 2>/dev/null | head -1)
if [ -n "$RD" ]; then
  echo; echo "== README checks ($RD, $(wc -l < "$RD") lines)"
  # npm run / make commands exist
  for c in $(grep -oE 'npm (run )?[a-zA-Z0-9:_-]+' "$RD" | awk '{print $NF}' | sort -u); do
    case "$c" in install|i|ci|test|start|run|init|publish) [ "$c" = test -o "$c" = start ] && { [ -f package.json ] && grep -q "\"$c\"" package.json || warn "README uses 'npm $c' but package.json has no such script"; };; *) [ -f package.json ] && grep -q "\"$c\"[[:space:]]*:" package.json || warn "README uses 'npm run $c' but package.json has no such script";; esac
  done
  for c in $(grep -oE '(^|[[:space:]])make [a-zA-Z0-9_.-]+' "$RD" | awk '{print $2}' | sort -u); do
    [ -f Makefile ] && grep -qE "^$c:" Makefile || warn "README uses 'make $c' but Makefile has no such target"
  done
  # referenced scripts / paths inside code blocks
  for f in $(grep -oE '(python3?|bash|sh|node) [./a-zA-Z0-9_-]+\.(py|sh|js)' "$RD" | awk '{print $2}' | sort -u); do [ -e "$f" ] || fail "README runs '$f' which does not exist"; done
  for f in $(grep -oE '(cp|source) [./a-zA-Z0-9_-]*\.env[a-zA-Z.]*' "$RD" | awk '{print $2}' | sort -u); do [ -e "$f" ] || warn "README mentions '$f' which does not exist (add .env.example?)"; done
  # images exist
  for f in $(grep -oE '!\[[^]]*\]\([^)]+\)' "$RD" | sed -E 's/.*\(//; s/\)$//' | grep -v '^http'); do [ -e "$f" ] || fail "README image missing: $f"; done
  # placeholders and generic phrasing
  PH=$(grep -nEi '(your-username|yourusername|<project[-_ ]name>|<repo>|lorem ipsum|TODO: fill|\[INSERT|example\.com/repo)' "$RD" | head -5); [ -n "$PH" ] && { warn "placeholders left in README:"; echo "$PH" | sed 's/^/    /'; }
  GEN=$(grep -nEi '(cutting-edge|state-of-the-art|seamless(ly)?|robust and scalable|leverag(e|es|ing) the power|revolutioniz|game-chang|next-generation|blazing[- ]fast|powerful and flexible|comprehensive solution|empower(s|ing)? (users|developers))' "$RD" | head -8); [ -n "$GEN" ] && { warn "marketing/generic phrasing (rewrite with concrete facts):"; echo "$GEN" | sed 's/^/    /'; }
  # numbers that need evidence
  NUM=$(grep -nE '[0-9]+(\.[0-9]+)?[[:space:]]?(%|ms|x faster|fps|samples|users|stars|downloads)' "$RD" | head -8); [ -n "$NUM" ] && { warn "numeric claims: each must trace to a committed result/log/source:"; echo "$NUM" | sed 's/^/    /'; }
  # badges
  B=$(grep -oE 'https://(img\.shields\.io|github\.com/[^)]*/workflows|codecov\.io|badge\.fury\.io)[^)]*' "$RD" | head -8); [ -n "$B" ] && { warn "badges to verify are truthful (license/CI/version must exist):"; echo "$B" | sed 's/^/    /'; }
  # headings sanity
  H1=$(grep -c '^# ' "$RD"); [ "$H1" -eq 1 ] && ok "single H1" || warn "README has $H1 top-level headings"
  sed -n '1,25p' "$RD" | grep -qiE '^(#|>|[A-Za-z])' && ok "hero region present (verify manually it answers what/why/main tech in the first screen)"
  [ "$(wc -l < "$RD")" -lt 25 ] && warn "README is very short; check depth against project complexity"
  grep -qE '^#{2,3} .*(Limitation|Known Issues|Not (yet )?(implemented|supported))' "$RD" || warn "no Limitations section (usually valuable for credibility; include only if evidenced)"
fi
git rev-parse --git-dir >/dev/null 2>&1 && { echo; echo "== git status"; git status --short | head -20; }
echo; [ $BAD -eq 0 ] && echo "VALIDATE: no blocking problems (project tests/build must still be run and reported separately)" || echo "VALIDATE: blocking problems found"
exit $BAD
