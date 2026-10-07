# README Checklist and Anti-Patterns

Use before drafting (gates) and after drafting (acceptance). Every unchecked item is either fixed or listed in the report.

## Gates before writing
- [ ] Profile(s) identified from evidence
- [ ] Entry point and core pipeline read; can explain data flow aloud
- [ ] Preservation inventory made
- [ ] Existing claims audited; contradictions listed
- [ ] Evidence ledger exists; unsupported items marked omit/ask
- [ ] Blueprint written; omitted sections justified
- [ ] User questions asked if purpose/audience/results are essential and absent

## Section acceptance
| Section | Done when |
|---|---|
| Hero | one-line what+who+main tech; badges truthful; visual or recommendation |
| Overview/Problem/Solution | states the problem concretely; solution matches code behavior |
| Features | each feature maps to code; no vague bullets ("easy to use") |
| Architecture | diagram nodes all exist in repo; edges match real calls/data flow |
| How it works | stages in true order; each stage names the module that does it |
| Tech stack | table with role per technology; nothing listed that is unused |
| Structure | meaningful dirs only, each with a purpose |
| Install | commands verified or marked (unverified); prerequisites with versions from config |
| Config | table matches env vars read in code; `.env.example` exists; no real values |
| Usage | examples use real routes/flags/functions and are copy-runnable |
| API | real endpoints, schemas from code, auth requirement stated; or link to docs/API.md |
| Model/Algorithm | architecture, input/output, training, metrics only if real |
| Testing | real framework and command; run result reported honestly |
| Performance | evidenced numbers with source, or "Formal benchmarking has not yet been performed." |
| Limitations | evidenced constraints, plain language |
| Roadmap | derived from TODOs/issues/gaps; split Implemented / Planned / Possible |
| License/Author | license only if file exists; author info from user or repo |

## Anti-patterns (reject on sight)
- Generic AI intro: "X is a cutting-edge, powerful solution that leverages..."
- Features list that restates the tech stack
- Fake or unverifiable badges, metrics, screenshots, integrations, "production-ready"
- Technology list with no role
- Installation steps that were never checked against manifests
- Copying package.json `description` as documentation
- Repeating the same information in Overview, Features, and Architecture
- Walls of text; sections with no concrete nouns
- Decorative diagrams with components that do not exist
- Generic roadmap ("improve performance", "add more tests") not tied to evidence
- Excess emoji, marketing tone
- Preserving an old claim the code contradicts

## Red-flag phrase list (rewrite with specifics)
cutting-edge, state-of-the-art, seamless, robust and scalable, leverages the power of, revolutionary, game-changing, next-generation, blazing fast, comprehensive solution, empowers users, easy to use (show how instead), production-ready (unless evidenced)
