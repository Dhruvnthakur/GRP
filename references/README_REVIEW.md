# README Strict Review (second pass)

After the first draft, switch roles: you are a skeptical maintainer and a recruiter who has 30 seconds. Review, then rewrite weak sections. Do at least one full review/revise cycle; stop after two unless problems remain.

## A. Reader tests
1. **30-second test:** from the first screen alone, can a stranger say what it is, what problem it solves, and the main technology?
2. **Architecture test:** can a developer name the components and how they connect?
3. **Install test:** are prerequisites, steps, and config sufficient to get it running?
4. **Run test:** is there at least one working usage example with expected output described?
5. **Contribution test:** could another developer find where to change things (structure, dev/test commands)?
6. **Recruiter test:** is it clear what the author actually built (not just which libraries exist)?
7. **Open-source feel:** does it look like a real project (navigation, links to docs, coherent structure)?

## B. Accuracy tests
- Every technical claim has a ledger row with evidence
- Re-run the contradiction check against the final text (databases, auth, languages, models, endpoints, platforms)
- Every command verified, run, or labelled `(unverified)`
- Every number has a source
- Every link and image resolves (`scripts/validate_docs.sh`)
- Mermaid diagrams reflect real components; syntax reviewed or rendered
- Badges correspond to things that exist (license file, workflow, version in manifest)

## C. Quality tests
- Generic sections? Replace with specifics or delete
- Missing implementation detail a reader would ask about? Add from code
- Unnecessary or duplicated sections? Remove
- Walls of text? Break up with a table, diagram, or link to docs/
- Length appropriate to complexity (not padded, not thin)?

## D. Score (0 = fails, 1 = acceptable, 2 = strong)
Clarity of hero, problem/solution, architecture accuracy, implementation depth, runnability, evidence discipline, honesty about limits, navigation/structure, visual presentation. Any 0 on accuracy or evidence blocks completion. Report the weak areas you could not fix (usually missing user input or assets).

## E. Output of the review
List what you changed because of the review, and what remains `TODO` for the user. Do not tell the user the README is "complete" if blocking items remain.
