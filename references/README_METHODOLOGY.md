# README Methodology

The README is produced by a pipeline, not written in one pass. Do the steps in order. Each step has an output; the README is only as good as these.

```
1 Profile  →  2 Read the code  →  3 Preservation inventory  →  4 Audit + contradictions
   →  5 Evidence ledger  →  6 Blueprint  →  7 Draft  →  8 Strict review (README_REVIEW.md)  →  9 Revise
```

This methodology draws on common open-source README practice (project-type-specific structure, audience-aware writing, content preservation, accuracy auditing). No dedicated README skill was available to inspect; do not claim otherwise.

## 1. Profile
Run `scripts/analyze_repo.sh`. Classify into one or more profiles from `README_PROFILES.md` (e.g. `AI/ML + Backend API + Mobile`). Base it on signals (imports, manifests, artifacts), not the repo name. The profile set selects sections, reading order, and docs/.

## 2. Read the code (mandatory)
The directory tree is a map, not understanding. Read, in this order, until you can explain the project to a colleague without notes:
1. Existing README and docs (intent, claims)
2. Manifests and run config (stack, scripts, ports, services)
3. Entry points (`main`, `app`, `index`, CLI parser, mobile `main`)
4. Core modules the entry point calls: the processing pipeline in order
5. Routes/handlers, models/schemas, auth, background jobs
6. For ML: dataset loaders, preprocessing, model definition, training loop (loss, optimizer, epochs), inference path, evaluation code, saved results
7. Tests (they reveal intended behavior and real usage)
8. Git history: `git log --stat --reverse | head`, tags, large refactors. Use it for roadmap/decision context, never to claim dates or authorship.

Write down, privately: the flow of data from input to output; the 3-7 core components and how they connect; what is implemented vs stubbed (`pass`, `NotImplementedError`, empty handlers, TODO).

If the repo is too large to read fully, read the core path fully, sample the rest, and say the analysis was sampled.

## 3. Preservation inventory
Before rewriting an existing README, extract and keep a list of: links, images/badges, install and run commands, examples, diagrams, acknowledgements/citations, project-history notes, author/contact info. Reuse each item unless it is demonstrably obsolete (contradicted by code, dead link, removed feature). Record what you drop and why.

## 4. Audit and contradiction detection
For every factual claim in the existing README (supported databases, "authentication implemented", supported languages, models, endpoints, commands, versions) find the supporting file. Classify:
- **Verified**: keep
- **Incorrect / unsupported**: correct it or remove it; list in the report
- **Outdated**: update to what the code does now
- **Unclear / duplicated**: rewrite or merge

Never keep a claim because it was already there. Treat `analyze_repo.sh` claim-check warnings as leads to verify by reading code, not as verdicts (a technology may be used indirectly).

## 5. Evidence ledger
Before drafting, build a table (keep it in the conversation, or in a scratch file that is NOT committed):

| Claim to be made | Evidence (file:line or command output) | Status |
|---|---|---|
| Uses PaddleOCR for text extraction | `src/ocr/engine.py:12` | verified |
| Exposes POST /api/analyze | `app/routes.py:40` | verified |
| 94% accuracy | none | **omit** |

Rules: no ledger row, no sentence in the README. Status values: verified / partially verified (say so in text) / omit / ask user.

## 6. Questions you may need to ask the user
Code cannot tell you the real-world problem, the intended audience, why certain engineering decisions were made, or whether results exist elsewhere. Ask one concise batch (max 4 questions) when these are essential and not documented, e.g.: "What problem motivated this? Who is it for? Do you have evaluation results or screenshots to include? Any known limitations?" If the user is unavailable, write `TODO` placeholders for those items rather than guessing.

## 7. Blueprint
Produce a short blueprint before drafting:

```
README Blueprint
Profile:        AI/ML + FastAPI backend
Audience:       developers, recruiters, researchers
Hero:           <one-line what + main tech>
Sections:       Overview, Problem, Solution, Architecture, How It Works, Tech Stack (with roles),
                Structure, Install, Config, Usage, API, Model Details, Testing, Limitations, Roadmap
Omitted:        Deployment (no deploy config), Performance (no results; one honest line)
docs/ split:    ARCHITECTURE.md, API.md (README links to them)
Open questions: problem statement, dataset provenance
```

The blueprint must differ between repos. Do not reuse a fixed template.

## 8. Writing principles
- **Hero first.** Title, a one-line statement of what it is and for whom, truthful badges, then a visual (existing screenshot/GIF) or a clearly marked recommendation. The first screen must say what it is, what problem it addresses, and the main technology.
- **Concrete over generic.** Name the actual input, output, model, endpoint, algorithm. "Detects synthetic speech in multilingual audio using X features and a Y classifier" beats "an innovative AI solution".
- **Problem then solution** for significant projects, grounded in what the code does; if motivation is undocumented, ask or TODO.
- **Explain flow.** For non-trivial systems, show the real pipeline (Mermaid or ASCII) then one short paragraph per stage.
- **Tech stack with roles.** Table: technology, what it does here, where (file/dir).
- **Structure tree** limited to meaningful directories, each explained in a few words.
- **Runnable.** Install, config, and usage commands come from project scripts or were run. Mark unverified ones `(unverified)` rather than presenting them as tested.
- **Configuration table** from real env var usage: variable, required, description, example/default placeholder. Never real values.
- **Usage examples** must be exercisable: real routes, real function names, real CLI flags. Derive from tests or handlers.
- **Implementation depth.** Include a "Core implementation" or "How it works" section naming key modules and what they do, so a reader sees what was actually built.
- **Performance** only with evidence; otherwise one line: "Formal benchmarking has not yet been performed."
- **Limitations** from evidence: stubs, missing auth, hardcoded paths, unsupported platforms, GPU need, data constraints. This builds credibility.
- **Roadmap** from TODOs/issues/comments/clearly missing pieces, separated into Implemented / Planned / Possible future work. No invented items.
- **Link out.** Keep README scannable; move depth to `docs/` and link.
- **Length follows complexity.** A small CLI can be ~100 lines. A multi-component ML platform may be 300+ plus docs/. Never pad.

## 9. Unknowns vocabulary
`TODO` (needs user input), `Not documented`, `Not currently implemented`, `Optional`, `(unverified)`. Use sparingly and visibly; list all of them in the final report.
