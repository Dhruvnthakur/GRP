#!/usr/bin/env bash
# Usage: analyze_repo.sh <repo>   (read-only)
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

echo; echo "== Run/build commands declared by the project (verified sources for README)"
[ -f package.json ] && { echo "npm scripts:"; python3 -c "import json;[print('  '+k+': '+v) for k,v in json.load(open('package.json')).get('scripts',{}).items()]" 2>/dev/null; }
[ -f Makefile ] && { echo "make targets:"; grep -E '^[a-zA-Z0-9_.-]+:([^=]|$)' Makefile | cut -d: -f1 | sort -u | sed 's/^/  /' | head -15; }
[ -f pyproject.toml ] && { echo "pyproject scripts/entry points:"; grep -A6 -E '^\[(project\.scripts|tool\.poetry\.scripts)\]' pyproject.toml | sed 's/^/  /'; }
for c in docker-compose.yml docker-compose.yaml; do [ -f $c ] && echo "compose services: $(grep -E '^  [a-zA-Z0-9_-]+:$' $c | tr -d ' :' | tr '\n' ' ')"; done
[ -f Dockerfile ] && echo "Dockerfile: base=$(grep -m1 -i '^FROM' Dockerfile | cut -d' ' -f2) expose=$(grep -i '^EXPOSE' Dockerfile | tr '\n' ' ') cmd=$(grep -iE '^(CMD|ENTRYPOINT)' Dockerfile | head -1)"

echo; echo "== Profile signals (evidence for classification)"
sig(){ n=$(echo "$FILES" | grep -E '\.(py|js|ts|jsx|tsx|java|kt|dart|go|rs|rb|php|cs|cpp|c|ipynb|toml|json|txt|gradle|xml|yml|yaml)$' | xargs -r grep -lEi "$2" 2>/dev/null | wc -l); [ "$n" -gt 0 ] && echo "  $1: $n file(s)"; }
sig "web API (FastAPI/Flask/Django/Express/Spring/Gin/Actix)" '(from fastapi|import fastapi|from flask|import flask|django\.|express\(\)|require\(.express.\)|@RestController|@SpringBootApplication|gin\.Default|actix_web)'
sig "frontend (React/Vue/Angular/Svelte/Next)" '("react"|"vue"|"@angular/core"|"svelte"|"next")'
sig "mobile (Flutter/React Native/Android/iOS)" '(package:flutter|react-native|androidx\.|SwiftUI|UIKit)'
sig "ML/DL (torch/tensorflow/keras/sklearn/xgboost/transformers/jax)" '(import torch|from torch|tensorflow|keras|sklearn|xgboost|lightgbm|transformers|jax)'
sig "computer vision (cv2/torchvision/ultralytics/OCR)" '(import cv2|torchvision|ultralytics|paddleocr|easyocr|pytesseract|mediapipe)'
sig "NLP/LLM (transformers/langchain/openai/anthropic/spacy/nltk)" '(langchain|openai|anthropic|spacy|nltk|sentence_transformers|llama)'
sig "audio/speech (librosa/torchaudio/whisper/pydub)" '(librosa|torchaudio|whisper|pydub|soundfile|wav2vec)'
sig "data science (pandas/numpy/matplotlib/seaborn/jupyter)" '(import pandas|import numpy|matplotlib|seaborn|plotly)'
sig "CLI (argparse/click/typer/cobra/clap/commander)" '(argparse|import click|typer|cobra\.|clap::|commander)'
sig "database (SQLAlchemy/Prisma/Mongo/Redis/psycopg/JPA/sqlite)" '(sqlalchemy|prisma|mongoose|pymongo|redis|psycopg|@Entity|sqlite3|CREATE TABLE)'
sig "auth (JWT/OAuth/passlib/bcrypt/session)" '(jwt|oauth|passlib|bcrypt|flask_login|passport|next-auth|firebase_auth)'
sig "blockchain (solidity/web3/ethers)" '(pragma solidity|web3|ethers|hardhat)'
sig "game/desktop (pygame/unity/godot/electron/tauri/PyQt)" '(pygame|UnityEngine|godot|electron|tauri|PyQt|tkinter)'
sig "infra (terraform/k8s/ansible/helm)" '(resource "aws_|apiVersion: apps/v1|ansible|helm)'
echo "model/data artifacts:"; echo "$FILES" | grep -Ei '\.(pt|pth|h5|onnx|pkl|joblib|ckpt|safetensors|tflite|csv|parquet|npz)$' | head -8 | sed 's/^/  /'
echo "notebooks: $(echo "$FILES" | grep -c '\.ipynb$')"

echo; echo "== API routes found (verify by reading handlers)"
echo "$FILES" | grep -E '\.(py|js|ts|java|kt|go|rs|rb|php)$' | xargs -r grep -nE '(@(app|router|bp|blueprint)\.(get|post|put|delete|patch|route)\(|@(Get|Post|Put|Delete|Patch|Request)Mapping|\b(app|router)\.(get|post|put|delete|patch)\(|r\.(GET|POST|PUT|DELETE)\()' 2>/dev/null | cut -c1-140 | head -30
echo; echo "== Data model hints"
echo "$FILES" | grep -Ei '(models?|schemas?|entities|migrations?)/|\.sql$|schema\.prisma$' | head -12 | sed 's/^/  /'
echo; echo "== TODO/FIXME/HACK in code (roadmap evidence)"
echo "$FILES" | grep -E '\.(py|js|ts|jsx|tsx|java|kt|go|rs|dart|c|cpp|rb|php)$' | xargs -r grep -nE '(TODO|FIXME|HACK|XXX)' 2>/dev/null | cut -c1-130 | head -15
echo; echo "== Existing README: links, images, commands (PRESERVATION INVENTORY)"
if [ -n "${RD:-}" ] && [ -f "$RD" ]; then
  echo "headings:"; grep -E '^#{1,3} ' "$RD" | sed 's/^/  /'
  echo "links/images: $(grep -oE '!?\[[^]]*\]\([^)]+\)' "$RD" | wc -l)  (list: grep -oE '!?\[[^]]*\]\([^)]+\)' $RD)"
  echo "code blocks: $(grep -c '^```' "$RD" | awk '{print int($1/2)}')"
  echo; echo "== README claim check: technologies named in README but absent from manifests/code"
  DEPS=$(cat package.json requirements*.txt pyproject.toml pom.xml build.gradle* Cargo.toml go.mod pubspec.yaml Gemfile composer.json Dockerfile docker-compose.y*ml 2>/dev/null | tr 'A-Z' 'a-z')
  CODE=$(echo "$FILES" | grep -E '\.(py|js|ts|jsx|tsx|java|kt|go|rs|dart|rb|php|cs|cpp|c)$' | xargs -r cat 2>/dev/null | tr 'A-Z' 'a-z' | head -c 4000000)
  for t in postgresql postgres mysql mongodb redis sqlite firebase supabase docker kubernetes pytorch tensorflow keras scikit-learn fastapi flask django express react vue angular flutter spring graphql websocket jwt oauth openai langchain celery kafka rabbitmq tailwind typescript; do
    if grep -qiE "(^|[^a-z])${t}([^a-z]|$)" "$RD"; then
      if ! echo "$DEPS" | grep -q "${t//-/.}" && ! echo "$CODE" | grep -q "${t}"; then echo "  ⚠ README mentions '$t' but no evidence in dependencies or source"; fi
    fi
  done
  for f in $(grep -oE '\]\(([^)#h][^)]*)\)' "$RD" | sed -E 's/^\]\(//; s/\)$//' | cut -d' ' -f1); do [ -e "$f" ] || echo "  ⚠ README references missing path: $f"; done
else echo "  (no README)"; fi
echo; echo "Next: run detect_secrets.sh, then READ THE CODE (entry points, routes, models, pipeline). The scan above is a map, not understanding."
