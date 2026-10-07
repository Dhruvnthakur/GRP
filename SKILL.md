---
name: github-repo-professionalizer
description: Turn an existing, already-developed (possibly already-pushed) Git repository into a professionally documented, portfolio-ready project. Core strength is evidence-based README generation - repository profiling, reading the actual code, auditing and correcting an existing README, architecture diagrams, tech-stack roles, verified install/usage, limitations - plus supporting docs/, .gitignore, .env.example, GitHub templates/CI, and secret checks, without rewriting Git history. Use whenever the user wants a README written or improved, wants a repo polished, documented, cleaned up, audited, made portfolio-ready or GitHub-ready, or invokes /repo-professionalize, even if they don't say "skill". Modes - --analyze, --plan, --apply, --portfolio, --github, --full.
---

# GitHub Repo Professionalizer

Builds a repository-understanding and documentation pipeline, not a prettier template. The README is the highest-priority output; everything else supports it. All content must be traceable to evidence in the repo. Git history is never rewritten.

## Invocation

`/repo-professionalize [path] [mode]` (path defaults to the current directory). Plain-language requests also trigger it. (In Claude Code the slash command is derived from the skill's folder/name; to get exactly `/repo-professionalize`, rename the skill folder and `name` field.)

| Mode | Behavior | Writes? |
|---|---|---|
| *(none)* | Analyze, Plan, **ask approval**, Apply, Validate | after approval |
| `--analyze` | Inspect and report only | no |
| `--plan` | Analyze, README strategy and change list | no |
| `--apply` | Apply an approved plan | yes |
| `--portfolio` | README optimized for recruiters/professors/visitors (`references/PORTFOLIO_README.md`) | after approval |
| `--github` | Templates, workflows, metadata, releases (`references/github-metadata.md`) | after approval |
| `--full` | Analyze, Plan, Professionalize, Validate, Commit, optionally Push | after approval |

Never modify the repo before approval unless the user explicitly asked for automatic application.

## Hard rules

1. **Evidence only.** Never invent capabilities, technologies, endpoints, benchmarks, metrics, integrations, screenshots, users, or deployment claims. Gaps are written `TODO`, `Not documented`, `Not currently implemented`, `Optional`, or `(unverified)`, or asked of the user when essential.
2. **No ledger row, no sentence.** Every README claim must map to a file/line or command output (see evidence ledger in `references/README_METHODOLOGY.md`).
3. **Never rewrite history.** No `reset --hard`, `push --force`, `--force-with-lease`, rebase of published commits, branch deletion, or author rewriting unless explicitly requested.
4. **Secrets:** report `file:line (type)` only, never values. If a likely secret is committed, stop before pushing, and recommend rotation, removal from the tree, history cleanup if needed, `.gitignore`, and env vars.
5. **No blind deletion.** Check references first; prefer `.gitignore` + `git rm --cached` with approval.
6. **License:** never choose silently; list MIT / Apache-2.0 / GPL-3.0 and ask.
7. **Honest validation.** Say what was run and what happened. Never claim tests, build, install, or deployment succeeded unless they did.
8. **Do not preserve false claims.** Correct or flag contradictions between README and code. Do preserve valuable links, examples, screenshots, commands.

## Workflow

### Phase 1: Analyze and profile (read-only)
```bash
bash scripts/analyze_repo.sh <repo>
bash scripts/detect_secrets.sh <repo>
```
The analyzer gives git state, stack, profile signals, declared run commands, routes, data-model hints, TODOs, existing-README inventory, and a README-vs-code claim check. It is a map. **Then read the code** following `references/README_METHODOLOGY.md` section 2: entry points, core pipeline, routes, models, auth, training/inference, tests. You must be able to explain the data flow before writing.

Classify into one or more profiles using `references/README_PROFILES.md`.

### Phase 2: Audit existing documentation
Rate README, install, config, architecture, API, testing, contributing, license, security (present / weak / missing / n/a; format in `references/report-template.md`). For an existing README: build the **preservation inventory** (links, images, commands, examples, history) and run **contradiction detection** (each claim: verified / incorrect / outdated / unclear).

### Phase 3: README strategy and plan
Produce: the evidence ledger, the **README blueprint** (profile, audience, sections, omissions with reasons, docs/ split, open questions), and the change list:

```
Changes to be made
────────────────────────────
README.md                  rewrite (keeps: <links/examples>; fixes: <contradictions>)
docs/ARCHITECTURE.md       new
docs/API.md                new (N endpoints found in app/routes.py)
.env.example               new (vars: ...)
.gitignore                 extend
```
Include what you are intentionally not doing and any questions (problem statement, audience, results, screenshots, license). If essential context is missing, ask one concise batch (max 4 questions). Wait for approval.

### Phase 4: Generate the README
Follow `references/README_METHODOLOGY.md` sections 7-9 and `references/README_CHECKLIST.md`. Key points:
- Structure comes from the blueprint, not a fixed template. Use only relevant sections.
- Hero: one-line what/for-whom/main tech, truthful badges, visual or recommendation.
- Problem then Solution for significant projects; How It Works with the real pipeline; Mermaid diagrams with only real components.
- Tech stack as a table with each technology's role in this repo.
- Install/config/usage from real project scripts or verified runs; `.env.example` and a config table.
- Real API endpoints/schemas, model/algorithm details, tests, limitations and roadmap only from evidence. Performance only with sourced numbers, else "Formal benchmarking has not yet been performed."
- Screenshots only from existing assets; otherwise recommend 2-4 (main interface, key workflow, results, dashboard).
- Length follows complexity (a small CLI ~100 lines; a complex ML platform 300+ lines plus docs/).
- `--portfolio`: apply `references/PORTFOLIO_README.md`.

### Phase 5: Strict review (do not skip)
Run `references/README_REVIEW.md`: reader tests, accuracy re-check, quality tests, scoring. Rewrite weak sections; at least one full revise cycle.

### Phase 6: Supporting docs and repo hygiene
Move depth into `docs/` (ARCHITECTURE, API, DEVELOPMENT, DEPLOYMENT, MODEL, TRAINING, DATABASE, TROUBLESHOOTING) only where warranted, and link from the README. Then, as appropriate: `.gitignore` (actual stack), `.env.example`, CHANGELOG from real history (Added/Changed/Fixed/Removed/Security; no invented releases), CONTRIBUTING/SECURITY/CODE_OF_CONDUCT for projects that want contributors, and `.github/` templates/workflows that match the real toolchain. See `references/github-metadata.md`.

### Phase 7: Validate
```bash
git rev-parse HEAD                              # record base commit BEFORE applying
bash scripts/validate_docs.sh <repo> <base>     # history, deletions, secrets, links, README commands/images/placeholders/generic phrasing/numeric claims/badges
```
Also run the project's real commands (`pytest`, `npm test`, `npm run build`, `mvn test`, `cargo test`, ...) where feasible, and the README's install/run commands where safe. Render or manually review Mermaid. Report failures honestly and separate pre-existing failures from new ones.

### Phase 8: Commit and optional push
Few logical commits, e.g. `docs: overhaul repository documentation`, `docs: add architecture documentation`, `docs: add API reference`, `chore: improve repository configuration`, `ci: add automated validation`. Show the file list, get approval, commit normally. Do not mix the user's uncommitted work into your commits. Push only on request, normally (never force), after confirming branch, commits, remote, and a clean secret scan.

### Phase 9: Report
Use `references/report-template.md`. Include contradictions fixed, unverified commands, open TODOs for the user, and recommendations intentionally not performed.

## Failure handling
- Not a git repo: analyze and document; skip git checks; offer `git init`, don't do it.
- Dirty tree: show it and ask how to proceed.
- Purpose unclear: ask rather than guess.
- Failing tests/build: report, distinguish pre-existing from new, never claim success.
- Large repo: read the core path fully, sample the rest, say so.
- No `gh`/remote: give manual steps for GitHub metadata.
- README contradicts code and you are unsure which is right: flag it for the user instead of choosing silently.

## Examples
```
/repo-professionalize ~/projects/ARA_OCR_Final
/repo-professionalize ~/projects/VOXGUARD --portfolio
/repo-professionalize ~/projects/beru --analyze
/repo-professionalize ~/projects/my-project --full
```

## References (load as needed)
- `references/README_METHODOLOGY.md`: the pipeline, evidence ledger, blueprint, writing principles
- `references/README_PROFILES.md`: per-profile reading order, sections, docs/, traps
- `references/README_CHECKLIST.md`: gates, section acceptance, anti-patterns
- `references/README_REVIEW.md`: strict second-pass review
- `references/PORTFOLIO_README.md`: recruiter/professor-oriented mode
- `references/github-metadata.md`: templates, CI, `gh` metadata
- `references/report-template.md`: audit and final report formats
