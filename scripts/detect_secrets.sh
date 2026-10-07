#!/usr/bin/env bash
# Usage: scan-secrets.sh <repo> [--changed <base-ref>]
# Redacted: prints file:line and type only, NEVER the matched value.
set -uo pipefail
R="${1:?repo}"; cd "$R"
MODE="all"; BASE=""; [ "${2:-}" = "--changed" ] && { MODE="changed"; BASE="${3:?base-ref}"; }
if git rev-parse --git-dir >/dev/null 2>&1; then
  if [ "$MODE" = changed ]; then
    mapfile -t FILES < <( { git diff --name-only --diff-filter=AM "$BASE" 2>/dev/null; git ls-files --others --exclude-standard; } | sort -u)
  else
    mapfile -t FILES < <(git ls-files --cached --others --exclude-standard)
  fi
else
  mapfile -t FILES < <(find . -type f -not -path './.git/*' -not -path '*/node_modules/*' | sed 's|^\./||')
fi
declare -A PAT=(
 [aws-access-key]='AKIA[0-9A-Z]{16}'
 [github-token]='gh[pousr]_[A-Za-z0-9]{30,}'
 [openai-style-key]='sk-[A-Za-z0-9_-]{20,}'
 [slack-token]='xox[baprs]-[A-Za-z0-9-]{10,}'
 [google-api-key]='AIza[0-9A-Za-z_-]{35}'
 [private-key]='-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'
 [connection-string-with-password]='[a-z]+://[^/[:space:]:@]+:[^/[:space:]@]{3,}@'
 [hardcoded-credential]='(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'$<{ ]{8,}["'"'"']'
)
FOUND=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || continue
  case "$f" in *.lock|*package-lock.json|*.png|*.jpg|*.jpeg|*.gif|*.pdf|*.zip|*.ico|*.woff*|*.ttf|*.svg) continue;; esac
  case "$(basename "$f")" in .env.example|*.example|*.sample) continue;; esac
  grep -Iq . "$f" 2>/dev/null || continue
  for t in "${!PAT[@]}"; do
    while IFS=: read -r ln _; do
      [ -n "$ln" ] && { echo "SECRET? $f:$ln ($t)"; FOUND=$((FOUND+1)); }
    done < <(grep -nEi "${PAT[$t]}" "$f" 2>/dev/null | cut -c1-12)
  done
done
for f in "${FILES[@]}"; do
  case "$(basename "$f")" in .env|.env.*|*.pem|*.key|id_rsa|id_ed25519|*.p12|*.pfx)
    case "$(basename "$f")" in .env.example|.env.sample) ;; *) echo "SENSITIVE FILE tracked/untracked-unignored: $f"; FOUND=$((FOUND+1));; esac;;
  esac
done
if [ "$MODE" = all ] && git rev-parse --git-dir >/dev/null 2>&1; then
  H=$(git log --all --diff-filter=A --name-only --format= -- '.env' '*/.env' '*.pem' '*.key' 'id_rsa' 2>/dev/null | sort -u)
  [ -n "$H" ] && { echo "HISTORY: sensitive filenames appear in past commits (values may still be recoverable):"; echo "$H" | sed 's/^/  /'; FOUND=$((FOUND+1)); }
fi
if [ "$FOUND" -gt 0 ]; then
  echo; echo "RESULT: $FOUND potential issue(s). Values intentionally not printed. Rotate any real credentials; do NOT push until resolved."; exit 3
else echo "RESULT: no secrets detected by pattern scan (not a guarantee)."; fi
