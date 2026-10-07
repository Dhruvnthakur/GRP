# Portfolio README (`--portfolio`)

Audience: recruiters, hiring managers, professors, interviewers, GitHub visitors. Goal: let them understand the developer's technical contribution quickly and truthfully.

## Emphasize (in this order, only where evidenced)
1. **Problem** and **Solution** in plain language
2. **Technical complexity**: what was hard (a custom pipeline, multi-service design, real-time constraint, model integration)
3. **Architecture**: one clear diagram
4. **Engineering decisions**: why this design (from code structure, commit messages, docs, or the user)
5. **Interesting implementation details**: a short "Core implementation" section naming modules and what they do
6. **Results**: real, sourced numbers or screenshots; otherwise omit or state not yet evaluated
7. **Challenges and what was learned**: only from user input or evidence (e.g. a documented workaround)
8. **Future improvements**: tied to real gaps

## How to gather what code cannot tell you
Ask the user (one concise batch): the motivating problem, their role (solo or team: do not assume), the hardest part, any results/screenshots/demo link, what they would improve. Without answers, leave `TODO` markers instead of writing narrative.

## Presentation
- Strong hero, then a visual (existing asset, or recommendation: 2-4 screenshots of main UI, key workflow, results, dashboard)
- Skimmable: tables for stack and config, diagram for architecture, short paragraphs
- Link to docs/ for depth; keep README focused
- Pin-worthy repo hygiene: clean tree, .gitignore, .env.example, license choice, topics and description (via `references/github-metadata.md`, only on request)

## Do not
- Inflate scale, users, performance, or novelty
- Imply team contributions, production deployment, or publication without evidence
- Use buzzwords as a substitute for specifics
- Fill gaps with plausible-sounding text. A short honest README beats an impressive false one.
