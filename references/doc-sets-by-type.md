# Choose docs by project type

Create a file only if it adds real value for this repo. Small projects usually need just the README.

| Type | Candidate docs |
|---|---|
| AI/ML, Data Science | ARCHITECTURE, MODEL, TRAINING, DATA, INFERENCE, DEPLOYMENT. Document only what code shows: datasets (source, format), training script params, metrics only if produced by committed results. Never state accuracy you did not see. |
| Full-stack | ARCHITECTURE, API, DATABASE, DEVELOPMENT, DEPLOYMENT |
| Backend/API | API, ARCHITECTURE, DATABASE, DEPLOYMENT |
| Frontend | DEVELOPMENT, ARCHITECTURE (component/state structure), BUILDING |
| Mobile | ARCHITECTURE, DEVELOPMENT, BUILDING, RELEASE |
| Library | API, USAGE, DEVELOPMENT, CONTRIBUTING |
| CLI tool | USAGE (commands/flags from `--help` or parser code), DEVELOPMENT |
| Research/academic | README with methodology, DATA, reproduction steps; cite only real results |
| Automation/DevOps | ARCHITECTURE, DEPLOYMENT, RUNBOOK; document secrets handling by variable name only |
| C/C++/Java/Python general | BUILDING, DEVELOPMENT, USAGE |

## How to decide
- Complexity: more than a few modules or services justifies ARCHITECTURE.
- Existence: API.md only if routes/handlers exist. DATABASE.md only if schema/models/migrations exist.
- Contributor intent: CONTRIBUTING, CODE_OF_CONDUCT, SECURITY only for projects meant to accept outside contributions, or on request.
- Ask when essential information (purpose, deployment target, data provenance) cannot be found.
