#!/usr/bin/env bash
# Usage: analyze-repo.sh <repo>   (read-only)
set -uo pipefail
R="${1:?repo}"; cd "$R"; echo "== Repository: $(pwd)"
IS_GIT=0; git rev-parse --git-dir >/dev/null 2>&1 && IS_GIT=1
echo; echo "== Git"
if [ $IS_GIT = 1 ]; then
  echo "branch:   $(git branch --show-current)"
  echo "commits:  $(git rev-list --count HEAD 2>/dev/null || echo 0)"
  echo "HEAD:     $(git rev-parse --short HEAD 2>/dev/null)"
  echo "branches: $(git branch --format='%(refname:short)' | tr '\n' ' ')"
  echo "tags:     $(git tag | tr '\n' ' ')"
  echo "remote:   $(git remote -v | awk '{print $1" "$2}' | sort -u | tr '\n' ';')"
  UP=$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null || true)
  [ -n "$UP" ] && echo "upstream: $UP (ahead/behind: $(git rev-list --left-right --count HEAD...$UP 2>/dev/null | tr '\t' '/'))" || echo "upstream: none (not pushed or no tracking)"
  echo "working tree: $( [ -z "$(git status --porcelain)" ] && echo clean || echo "DIRTY ($(git status --porcelain | wc -l) entries)")"
  echo "recent commits:"; git log --oneline -8 | sed 's/^/  /'
  echo "authors: $(git shortlog -sn HEAD | head -3 | tr '\n' ';' | tr -s ' ')"
  CONV=$(git log --format=%s | grep -Ec '^(feat|fix|docs|chore|refactor|test|ci|style|perf)(\(.+\))?!?:' || true); TOT=$(git rev-list --count HEAD 2>/dev/null || echo 1)
  echo "conventional-style messages: $CONV/$TOT"
else echo "Not a git repository. Git checks skipped."; fi

if [ $IS_GIT = 1 ]; then FILES=$(git ls-files --cached --others --exclude-standard); else FILES=$(find . -type f -not -path './.git/*' -not -path '*/node_modules/*' | sed 's|^\./||'); fi
echo; echo "== Stack indicators (files present)"
for m in package.json requirements.txt pyproject.toml setup.py Pipfile environment.yml pom.xml build.gradle build.gradle.kts Cargo.toml go.mod pubspec.yaml CMakeLists.txt Makefile composer.json Gemfile Dockerfile docker-compose.yml docker-compose.yaml '*.tf' 'Chart.yaml' AndroidManifest.xml; do
  echo "$FILES" | grep -E "(^|/)${m//\*/.*}$" | head -3 | sed 's/^/  /'
done
echo; echo "== Languages by file count"
echo "$FILES" | awk -F. 'NF>1{print tolower($NF)}' | grep -E '^(py|ipynb|js|jsx|ts|tsx|java|kt|c|h|cpp|hpp|cs|go|rs|rb|php|dart|swift|sh|sql|html|css|scss|vue|svelte|r|m|tf|yml|yaml|md)$' | sort | uniq -c | sort -rn | head -12
echo; echo "== Entry points / structure hints"
echo "$FILES" | grep -Ei '(^|/)(main|app|index|server|manage|cli|__main__)\.(py|js|ts|go|rs|java|dart|c|cpp)$' | head -8 | sed 's/^/  /'
echo "$FILES" | cut -d/ -f1 | sort -u | head -30 | tr '\n' ' '; echo
echo; echo "== Env vars referenced in code (names only)"
echo "$FILES" | grep -E '\.(py|js|ts|jsx|tsx|go|rs|java|kt|rb|php|dart|sh)$' | xargs -r grep -hoE "(os\.environ(\.get)?\[?\(?['\"][A-Z0-9_]+['\"]|os\.getenv\(['\"][A-Z0-9_]+['\"]|process\.env\.[A-Z0-9_]+|getenv\(['\"][A-Z0-9_]+['\"]|System\.getenv\(['\"][A-Z0-9_]+['\"])" 2>/dev/null | grep -oE "[A-Z][A-Z0-9_]{2,}" | sort -u | tr '\n' ' '; echo
echo; echo "== Tests / CI"
echo "tests: $(echo "$FILES" | grep -Eci '(^|/)(tests?|__tests__|spec)/|(_test|\.test|\.spec)\.|test_.*\.py')"
echo "CI:    $(echo "$FILES" | grep -E '^\.github/workflows/|\.gitlab-ci\.yml|Jenkinsfile|\.circleci/' | tr '\n' ' ')"
echo; echo "== Documentation audit (presence)"
chk(){ if echo "$FILES" | grep -qiE "$2"; then echo "  ✓ $1"; else echo "  ✗ $1"; fi; }
chk "README" '^readme(\.md|\.rst|\.txt)?$'; chk "LICENSE" '^(license|licence|copying)(\.md|\.txt)?$'
chk "CHANGELOG" '^changelog'; chk "CONTRIBUTING" '^(\.github/)?contributing'; chk "SECURITY" '^(\.github/)?security\.md$'
chk "CODE_OF_CONDUCT" 'code_of_conduct'; chk ".gitignore" '^\.gitignore$'; chk ".env.example" '(^|/)\.env\.(example|sample)$'
chk "docs/ directory" '^docs/'; chk "Issue/PR templates" '^\.github/(ISSUE_TEMPLATE|PULL_REQUEST_TEMPLATE)'
RD=$(echo "$FILES" | grep -iE '^readme' | head -1); [ -n "$RD" ] && echo "  README size: $(wc -l < "$RD") lines"
echo; echo "== Assets (possible screenshots/demos)"
echo "$FILES" | grep -Ei '\.(png|jpe?g|gif|webp|mp4|svg)$' | grep -Ei '(screenshot|demo|image|asset|docs|static|preview)' | head -10 | sed 's/^/  /'
echo; echo "== Cleanup candidates"
echo "tracked junk:"
echo "$FILES" | grep -E '(^|/)(__pycache__|node_modules|\.idea|\.vscode|\.DS_Store|dist|build|\.pytest_cache|\.ipynb_checkpoints)(/|$)|\.(pyc|log|swp|tmp)$|(^|/)\.env$' | head -15 | sed 's/^/  /'
echo "large files (>5MB):"
echo "$FILES" | while read -r f; do [ -f "$f" ] && [ "$(stat -c%s "$f" 2>/dev/null || echo 0)" -gt 5242880 ] && echo "  $f ($(du -h "$f" | cut -f1))"; done | head -10
echo; echo "Next: run scan-secrets.sh, then read the code before writing any docs."
