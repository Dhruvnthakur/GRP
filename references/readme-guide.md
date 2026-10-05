# README guide

Include a section only if the repo supports it. Order for most projects:

1. **Title + one-line description** (what it does, grounded in code)
2. **Badges** (truthful only: language, license if present, version from manifest, CI if workflow exists)
3. **Overview**: what and why. If the "why" is not documented, ask the user or leave `TODO`.
4. **Features**: only implemented ones, verified in code
5. **Demo**: existing screenshots/GIFs only; otherwise `TODO: add screenshot at docs/images/`
6. **Architecture**: short summary plus Mermaid diagram of real components; link to docs/ARCHITECTURE.md
7. **Tech stack**: table from manifests/Dockerfile (name, role, evidence file)
8. **Project structure**: trimmed tree with one-line purposes
9. **Requirements, Installation, Configuration, Usage**: commands copied from project scripts or verified by running. Env vars table from `.env.example`.
10. **API**: only if endpoints exist, or link to docs/API.md
11. **Testing**: framework and exact command
12. **Deployment**: only if Dockerfile/CI/deploy config exists
13. **Troubleshooting**: only issues evidenced by code/docs/issues
14. **Roadmap**: only from existing TODOs/issues or user input
15. **Contributing, License, Author**: license only if a LICENSE file exists

Style: concise, scannable, tables and code blocks where useful, beginner-runnable setup. No fake metrics, no marketing filler, no emoji spam. Preserve valuable content from the existing README rather than discarding it.

Evidence check before finishing: for each feature and command, name the file that supports it. Delete anything you cannot support.
