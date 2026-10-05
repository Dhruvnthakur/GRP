# GRP (GitHub Repo Professionalizer)

**GRP** is a Claude Skill designed to analyze an existing Git repository and professionalize it, turning it into a clean, accurate, portfolio-ready project.

Everything GRP writes is **evidence-based**, traced directly to files it reads in your repository.

## Features
* **Evidence-based**: Claims are backed by repository files.
* **Non-destructive**: Never rewrites Git history.
* **Secure**: Automatically scans for and reports potential secret leaks.
* **Validation**: Ensures integrity after changes.

## Quick Start
```bash
/repo-professionalize [path] [mode]
```

## Modes
| Mode | Description |
|---|---|
| `--analyze` | Inspect and report only |
| `--plan` | Analyze and propose changes |
| `--apply` | Apply approved changes |
| `--full` | Full pipeline: Analyze, Plan, Apply, Validate, Commit |

See [SKILL.md](SKILL.md) for full documentation.

## License
This project is licensed under the MIT License.
