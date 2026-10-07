# README Profiles

A repo can have several profiles. Merge their sections, remove duplicates, and keep the README coherent. For each profile: what to read, sections that matter, what to document in `docs/`, and typical traps.

## AI / ML (also Computer Vision, NLP/LLM, Audio/Speech)
- **Read:** dataset loading, preprocessing/feature extraction, model definition, training loop (loss, optimizer, schedule, epochs, batch size), checkpoints, inference script/API, evaluation code, notebooks, saved metrics/plots.
- **Sections:** Overview, Problem, Solution, Pipeline (diagram), Model details (architecture, input format, output), Dataset (source, size, license, only if documented), Training, Evaluation (only real numbers with source), Inference example, Hardware requirements (from code: CUDA calls, memory notes), Limitations, Roadmap.
- **docs/:** MODEL.md, TRAINING.md, DATA.md, INFERENCE.md, DEPLOYMENT.md as warranted.
- **Traps:** inventing accuracy/latency; naming a model the code merely imports; claiming "real-time" without evidence; hiding that weights/data are not in the repo (document how to obtain them, or TODO).
- Audio/speech: sample rate, features (MFCC/spectrogram), languages actually covered. Vision: input size, augmentations, detection vs classification. NLP/LLM: model/provider, prompt templates, context handling, API keys via env only.

## Data Science / Analytics
- **Read:** notebooks, data loaders, cleaning steps, feature engineering, analysis/plots, outputs.
- **Sections:** Question being answered, Data (source, schema), Methodology, Key findings (only from committed outputs), Reproduction steps, Environment.
- **Traps:** stating conclusions not reproduced in the repo; unrecorded data sources.

## Full Stack
- **Read:** both client and server entry points, API client layer, auth flow, state management, DB schema/migrations, deployment config.
- **Sections:** Overview, Architecture (client-API-DB-external diagram), Features (verified in UI/route code), Tech Stack with roles, Structure, Install (each tier), Configuration, Usage (user workflow), API link, Database, Testing, Deployment.
- **docs/:** ARCHITECTURE, API, DATABASE, DEVELOPMENT, DEPLOYMENT.

## Backend / API
- **Read:** app factory, routers, middleware, schemas, services, persistence, auth, background workers, error handling.
- **Sections:** Overview, Architecture, Endpoints summary (full list in docs/API.md), Auth, Data model, Config, Running, Testing, Deployment, Limitations.
- **Traps:** documenting endpoints from names instead of reading handlers; inventing response schemas (use pydantic/DTO definitions).

## Frontend
- **Read:** routing, component hierarchy, state, API calls, build config.
- **Sections:** Overview, Screens/flows (existing screenshots), Architecture (components/state), Install/Run/Build, Configuration, Browser/device support only if declared.

## Mobile
- **Read:** app entry, navigation, platform channels/native modules, on-device processing, networking, storage, permissions, build flavors.
- **Sections:** Overview, Screens (screenshots if present), Architecture (UI, device processing, network, backend, storage), Requirements (SDK/Xcode/Flutter versions from config), Build and run per platform, Permissions, Release notes if any.
- **docs/:** ARCHITECTURE, DEVELOPMENT, BUILDING, RELEASE.

## CLI
- **Read:** argument parser definitions, command handlers, config loading, exit codes.
- **Sections:** What it does, Install, Commands (from parser, with real flags), Examples, Configuration, Exit codes if defined.
- Prefer capturing real `--help` output.

## Library / SDK
- **Read:** public exports, docstrings, tests, examples/.
- **Sections:** Overview, Install, Quick start (from tests/examples), API reference summary, Compatibility (declared versions), Development, Contributing.

## Research / Academic
- **Read:** paper/report files, code implementing the method, experiment scripts, results files.
- **Sections:** Abstract/Overview, Problem, Method, Implementation mapping (paper concept to file), Reproduction, Results (committed only), Citation (only if provided), Limitations.
- Do not claim publication, venue, or course/supervisor details unless present in the repo or given by the user.

## DevOps / Infrastructure / Automation
- **Read:** Terraform/Helm/Ansible, pipelines, scripts, cron/n8n/workflow exports, container definitions.
- **Sections:** Purpose, Architecture (resources and flow), Prerequisites, Secrets handling (names only), Deploy/Run, Operations/Runbook, Teardown, Cost/risk notes only if evidenced.

## Game / Desktop
- **Read:** main loop, scene/UI structure, asset pipeline, platform packaging.
- **Sections:** Overview, Gameplay/Features (verified), Controls (from input code), Build/Run, Assets and licenses, Architecture.

## Blockchain / Web3
- **Read:** contracts, deployment scripts, tests, frontend integration.
- **Sections:** Overview, Contracts (purpose per contract), Network/addresses (only if committed), Deploy and test, Security notes (audit status: only if real; otherwise "not audited").

## Embedded / IoT
- **Read:** firmware entry, drivers, pin/config maps, build flags.
- **Sections:** Hardware (board, sensors from code), Wiring (from pin definitions), Build/Flash, Protocols, Limitations.

## Multi-profile example: `AI/ML + FastAPI + Mobile`
Hero names all three roles. Architecture diagram: Mobile app → FastAPI → inference engine → storage. Sections: Problem, Solution, Pipeline, Model details, API (link), Mobile app, Install per component, Config, Testing, Limitations. docs/: ARCHITECTURE, MODEL, API, BUILDING.

## Other
Fall back to: Overview, Architecture (if non-trivial), Install, Usage, Testing, Limitations, Contributing.
