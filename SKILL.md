---
name: github-repo-professionalizer
description: Analyze an existing, already-developed (possibly already-pushed) Git repository and professionalize it - evidence-based README, docs, .gitignore, .env.example, GitHub templates/CI, cleanup, changelog from real history - without rewriting Git history. Use whenever the user wants to polish, document, clean up, audit, or make a repo portfolio-ready or GitHub-ready, asks for a README, architecture or API docs, or invokes /repo-professionalize, even if they don't say "skill". Modes - --analyze, --plan, --apply, --portfolio, --github, --full.
---

# GitHub Repo Professionalizer

Turns an existing repository into a clean, accurate, portfolio-ready one. Everything written must be backed by evidence in the repo. History is never rewritten.

## Invocation

`/repo-professionalize [path] [mode]` (path defaults to the current directory). Natural-language requests work too.

| Mode | Behavior | Modifies repo? |
|---|---|---|
| `--analyze` | Inspect and report only | No |
| `--plan` | Analyze, then propose a concrete change list | No |
| `--apply` | Apply a plan the user has approved | Yes |
| `--portfolio` | Optimize for recruiters, professors, visitors (see `references/portfolio-mode.md`) | After approval |
| `--github` | Metadata, templates, workflows, releases (see `references/github-metadata.md`) | After approval |
| `--full` | Analyze, plan, apply, validate, commit, optionally push | After approval |

**Default (no mode):** Analyze, then Plan, then ask for approval, then Apply, then Validate. Do not modify anything before approval unless the user explicitly asked for automatic application (`--full` with "don't ask", "auto", or equivalent).

## Ephemeral Workflows

If you do not want to keep the repository on your laptop:

1. Clone: `git clone <repo-url>`
2. Work: Run `/repo-professionalize . --full`
   - Using `--full` is best as it validates, commits, and pushes for you.
3. Verify: Log into GitHub to verify the changes arrived on the remote.
4. Delete: `rm -rf <local-repo-path>`

> ⚠️ **Critical Guardrail**
> NEVER delete the folder until you have verified the professionalized code is pushed to your remote GitHub repository.
>
> If you run `/repo-professionalize` without `--full`, you must run `git push` manually *after* the skill finishes its `apply` and `commit` phases before you delete the local directory.

## Hard rules

1. **Evidence only.** Never invent features, technologies, endpoints, benchmarks, metrics, screenshots, users, stars, integrations or deployment claims. Missing information is written as `TODO`, `Not documented`, `Not currently implemented`, or `Optional`, or asked of the user if essential. Every README claim should trace to a file you read.
2. **Never rewrite history.** No force push, reset, rebase of published commits, branch deletion, or author rewriting unless the user explicitly asks for it.
3. **Never expose secrets.** Report secret locations as `file:line (type)` only, never the value. If secrets are found, report them prominently, recommend rotation and history cleanup, and **stop before any push**.
4. **Don't delete blindly.** Before removing or untracking anything, establish that nothing references it. Prefer `.gitignore` plus `git rm --cached` over deletion, and get approval.
5. **Don't choose a license silently.** Report none found, list options (MIT, Apache-2.0, GPL-3.0), ask.
6. **Honest validation.** Only report commands that were actually run. Never say tests passed or a build works unless they did. Report failures plainly.
7. **Only what fits.** Skip docs, workflows, or README sections that don't apply (no API section without an API).

## Workflow

### Phase 1: Analyze (read-only)

```bash
bash scripts/analyze-repo.sh <repo>        # stack, git state, docs audit, cleanup candidates, tests/CI
bash scripts/scan-secrets.sh <repo>        # redacted secret scan, working tree and history filenames
```

Then read the actual code, not just manifests: entry points, routes, models, config loading, the existing README, tests. Build an internal picture of identity, architecture (frontend, backend, DB, ML pipeline, workers, CLI, infra), dependencies, configuration/env variables (grep the code for `os.environ`, `process.env`, `getenv`, `${...}`), and how to run and test it.

Record git facts: commit count, branches, tags, remote, current branch, whether pushed, commit-message quality. These shape the plan (e.g. CHANGELOG only from real history).

### Phase 2: Documentation audit

Produce a gap table (see format in `references/report-template.md`) covering README, install, configuration, architecture, API, testing, contributing, license, security. Rate each present / needs improvement / missing / not applicable.

### Phase 3: Plan

Choose documents by project type using `references/doc-sets-by-type.md`. Output the plan as:

```
Changes to be made
────────────────────────────
README.md                  rewrite (evidence: ...)
docs/ARCHITECTURE.md       new
.env.example               new (vars found in src/config.py)
.gitignore                 extend
```

Include for each item *why*, plus items intentionally **not** done and questions for the user (license, missing screenshots, unverifiable commands). Wait for approval unless auto mode was requested.

### Phase 4: Apply

- Work on the current branch, or a new branch if the user prefers a PR-style flow. Record the base commit first: `git rev-parse HEAD`.
- README: follow `references/readme-guide.md`. Include only sections the evidence supports.
- `.gitignore`: extend for the actual stack. Never ignore source or required config. Files already tracked need `git rm --cached` (with approval).
- `.env.example`: variable names found in code, blank or obviously placeholder values, one-line comment each. Never copy real values.
- Architecture diagrams: Mermaid representing the real components and flows only.
- API docs: only endpoints found in code. Mark anything uncertain `TODO: verify`.
- Test docs: only commands you ran or that are declared in the project's own scripts/config.
- CHANGELOG: derived from real `git log` and tags (Added / Changed / Fixed / Removed / Security). No invented releases.
- Screenshots: use existing assets only. Otherwise leave a clearly marked `TODO` and tell the user where one would go.
- Badges: only truthful ones (language, license, version from manifest, CI status if a workflow exists).
- GitHub templates/workflows: only if they match the project (`references/github-metadata.md`).

### Phase 5: Validate

```bash
bash scripts/validate.sh <repo> <base-commit>
```

Checks: base commit still an ancestor of HEAD (history preserved), no deleted files unintentionally, no secrets or `.env` in the change set, relative markdown links resolve, Mermaid blocks present (syntax check if `mmdc` exists), `git status`. Then run the project's real test/build commands where feasible (`pytest`, `npm test`, `npm run build`, `mvn test`, `cargo test`, ...). Report exactly what ran and what happened.

### Phase 6: Commit and optional push

Group into a few logical commits, never dozens:

```
docs: rewrite project README
docs: add architecture documentation
chore: improve gitignore and add env template
ci: add project validation workflow
```

Show the change list, get approval, commit normally. Push only on request: confirm branch, commits and remote first, push normally, never force. Abort if secrets were found.

### Phase 7: Report

Finish with the report from `references/report-template.md`, including **recommended future improvements that were intentionally not done**.

## Failure handling

- Not a git repo: analyze and document anyway, state that Git checks were skipped, and offer `git init` rather than doing it.
- Dirty working tree: show it, and do not mix the user's uncommitted work into your commits. Ask how to proceed.
- Unclear purpose: ask one concise question rather than guess.
- Tests/build fail before or after your changes: say so, distinguish pre-existing from new, never claim success.
- No remote or no `gh`: skip GitHub metadata and tell the user the manual steps.
- Huge repo: sample representative modules, state that the analysis was sampled.

## Examples

```
/repo-professionalize ~/projects/ARA_OCR_Final
/repo-professionalize ~/projects/VOXGUARD --portfolio
/repo-professionalize ~/projects/beru --analyze
/repo-professionalize ~/projects/my-project --full
```
