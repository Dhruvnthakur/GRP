# GRP (GitHub Repo Professionalizer)

**GRP** is a Claude Skill designed to analyze an existing, already-developed Git repository and professionalize it — turning it into a clean, accurate, portfolio-ready project without rewriting Git history.

Everything GRP writes is **evidence-based**, traced directly to files it reads in your repository.

## Get Started

### Prerequisites
- [Claude Code](https://claude.com/claude-code) installed.
- A local Git repository (or [ephemeral workflow](#ephemeral-workflows)).

### Invocation

Run in the root of your project:

```bash
/repo-professionalize [path] [mode]
```

*   **path**: Defaults to the current directory.
*   **mode**: Select the level of action (see below).

## Operational Modes

| Mode | Behavior | Modifies Repository? |
|---|---|---|
| `--analyze` | Inspect and report only | No |
| `--plan` | Analyze, then propose a concrete change list | No |
| `--apply` | Apply a previously approved plan | Yes |
| `--portfolio` | Optimize for recruiters/visitors | After approval |
| `--github` | Add metadata, templates, workflows, releases | After approval |
| `--full` | **Analyze ⮕ Plan ⮕ Apply ⮕ Validate ⮕ Commit** | After approval |

**Default (no mode):** Analyze, plan, ask for approval, apply, and validate.

## Ephemeral Workflow (Clean Machine)

If you do not want to keep the repository on your laptop, use this "Provision — Operate — Destroy" pattern:

1. **Clone**: `git clone --depth 1 <repo-url>`
2. **Work**: Run `/repo-professionalize . --full`
3. **Verify**: Log into GitHub to verify changes.
4. **Delete**: `rm -rf <local-repo-path>`

> ⚠️ **Critical Guardrail**
> NEVER delete the folder until you have verified the professionalized code is pushed to your remote GitHub repository.

## How It Works

GRP follows a rigorous, evidence-based pipeline:

1. **Analyze (Read-Only)**: Scans the codebase for stack, Git state, and documentation gaps. It detects secrets (reporting location only) and builds an internal model of the project's architecture.
2. **Plan**: Proposes specific changes based on the project type. Wait for your approval here.
3. **Apply**: Implements the approved changes. It strictly preserves history, generates truthful docs, and extends configuration files.
4. **Validate**: Runs safety checks (no secrets added, links resolve) and attempts project-specific build/test commands to ensure integrity.
5. **Commit**: Bundles changes into logical commits and pushes them to your remote (if requested/allowed).

## Principles
*   **Evidence Only**: No invented features or benchmarks. Everything is traced to a file.
*   **History Integrity**: No destructive Git history manipulation (no rebase, force push, etc.).
*   **Security First**: Secrets are detected, reported, and blocked from being pushed.
*   **Honest Reporting**: Failed builds or missing tests are reported explicitly.
