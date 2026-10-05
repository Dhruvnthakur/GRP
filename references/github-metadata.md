# GitHub-specific improvements

Apply only in `--github`, `--full`, or when the user asks. Never modify remote metadata without an explicit request.

## Files (only when they fit)
- `.github/workflows/ci.yml`: must match the real toolchain (setup action for the actual language/version, the project's real install/test/build commands). If tests don't exist, do not add a test job. Prefer a minimal lint/build job or none.
- `.github/ISSUE_TEMPLATE/bug_report.md`, `feature_request.md`, `.github/PULL_REQUEST_TEMPLATE.md`: reasonable for projects that accept issues/PRs.
- `.github/dependabot.yml`: only for ecosystems present (npm, pip, cargo, docker, github-actions).
- `release.yml`: only if the project already versions/releases.

Validate YAML syntax and that referenced commands exist in the repo.

## Metadata via `gh` (if installed and authenticated, and the user asked)
- Inspect: `gh repo view --json description,repositoryTopics,visibility,homepageUrl`; releases `gh release list`; workflows `gh workflow list`
- Propose: description (one line from the README), topics (languages, frameworks, domain, from evidence), homepage only if a real URL exists
- Modify only after approval: `gh repo edit --description "..." --add-topic ...`
- Releases: create from existing tags only; notes from the real changelog. Never create fictional versions.

## If `gh` is unavailable
Give the user the exact description/topics to paste into repository settings.
