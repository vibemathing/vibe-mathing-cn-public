# vibe-mathing-cn: Trusted AI Mathematics Research and Verification Workbench

[![CI](https://github.com/vibemathing/vibe-mathing-cn-public/actions/workflows/ci.yml/badge.svg)](https://github.com/vibemathing/vibe-mathing-cn-public/actions/workflows/ci.yml)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB)](requirements.txt)
[![Lean fixture](https://img.shields.io/badge/Lean-fixture-4B69FF)](fixtures/lean-proof/README.md)
[![License](https://img.shields.io/badge/license-MIT-0B7A75)](LICENSE)
[![Solution index](https://img.shields.io/badge/solutions-empty-orange)](result-library/indexes/solutions.json)
[![GEO](https://img.shields.io/badge/GEO-fact--bounded-7C3AED)](GEO.md)
[![Metamodel](https://img.shields.io/badge/metamodel-Point--Line--Face--Body-0B7A75)](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md)

> **Untrusted candidate generation + trusted verification: construct candidates from a problem space, then derive a solution view only after verification.**

> **Current public status (verified 2026-09-09):** the canonical Problem, Attempt, and Result ledgers are empty; `result-library/indexes/solutions.json` has no result IDs; this repository does not claim to solve any open mathematics problem.

Canonical public repository: <https://github.com/vibemathing/vibe-mathing-cn-public>

### Public entrypoint index

| Entrypoint | Purpose |
| --- | --- |
| [Problem repository fleet · GitHub Project #1](https://github.com/users/vibemathing/projects/1) | Browse public single-problem repositories; Project fields and cards are operational indexes, not mathematical evidence |
| [Bounty problem map · GitHub Project #2 View 3](https://github.com/users/vibemathing/projects/2/views/3) | Browse the dated bounty ranking; amounts and Project states are source metadata, not mathematical evidence or payable balance |
| [Top-146 bounty repository snapshot](problem-library/BOUNTY_PROJECT_2_TOP146.md) | Read the deduplicated public repository list and its machine-readable snapshot |
| [Public ProblemContract library](https://github.com/vibemathing/vibe-mathing-problem-library-public) | Discover public problem contracts, the catalog, and repository locators |
| [Single-problem research template](https://github.com/vibemathing/vibe-mathing-problem-public-template) | Inspect the fixed Web research Harness, candidate-write boundary, and bootstrap files |
| [All public `vibemathing` repositories](https://github.com/vibemathing?tab=repositories) | Find concrete `problem-*` repositories and other public engineering repositories |
| [Detailed public problem index in this repository](problem-library/VIBEMATHING_PUBLIC_INDEX.md) | Read the catalog, template, query commands, and admission boundary |

### Key problem repositories and bounty map

> These are ProblemContract/candidate-research entrypoints only. A repository, Issue, PR, CI run, or checkpoint does not mean that a problem has been solved and does not automatically create Evidence, a Result, or a Solution. The secp256k1 entry is not a Millennium Prize Problem.

The dated [`Project #2 View 3 snapshot`](problem-library/BOUNTY_PROJECT_2_TOP146.md) contains the first 146 unique repository URLs in the USD-equivalent bounty view, with original currency, source status, Award status, and provenance preserved. The [`machine-readable snapshot`](problem-library/registry/bounty-project-2-top146.v1.json) is pointer-only metadata: it does not import ProblemContracts or add amounts together. Because the requested unit is 146 repositories, the snapshot retains the USD 100.00 boundary rows; it is not a claim that every row is strictly greater than USD 100.

The six Millennium entries remain a separate category. The cryptographic `secp256k1` entry is an independent complexity-audit problem and is not part of the Millennium Problems.

| Category | Problem | Public single-problem repository |
| --- | --- | --- |
| Millennium problem | Riemann hypothesis | [`problem-millennium-riemann-hypothesis`](https://github.com/vibemathing/problem-millennium-riemann-hypothesis) |
| Millennium problem | P versus NP | [`problem-millennium-p-vs-np`](https://github.com/vibemathing/problem-millennium-p-vs-np) |
| Millennium problem | Navier–Stokes existence and smoothness | [`problem-millennium-navier-stokes`](https://github.com/vibemathing/problem-millennium-navier-stokes) |
| Millennium problem | Yang–Mills existence and mass gap | [`problem-millennium-yang-mills-mass-gap`](https://github.com/vibemathing/problem-millennium-yang-mills-mass-gap) |
| Millennium problem | Hodge conjecture | [`problem-millennium-hodge-conjecture`](https://github.com/vibemathing/problem-millennium-hodge-conjecture) |
| Millennium problem | Birch and Swinnerton-Dyer conjecture | [`problem-millennium-birch-swinnerton-dyer`](https://github.com/vibemathing/problem-millennium-birch-swinnerton-dyer) |
| Independent cryptographic problem | Classical polynomial-time audit of secp256k1 discrete-log inversion | [`problem-secp256k1-ecdlog-polytime`](https://github.com/vibemathing/problem-secp256k1-ecdlog-polytime) |

`vibe-mathing-cn` organizes mathematical problems, literature, derivations, computations, proofs, and formal checks into a traceable workflow. It is not a promise to solve arbitrary open problems: an honest `open` disposition is a valid outcome.

The repository's original code and documentation are released under the [MIT License](LICENSE); third-party material under `vendor/` remains subject to its own license and source lock.

## Start here

- [Architecture at a glance](#architecture-at-a-glance)
- [Quick start](#quick-start)
- [Core contract](#core-contract)
- [Single conceptual root](#single-conceptual-root-pointlinefacebody)
- [Top-level lifecycle](#top-level-lifecycle-project-workflow-task-step-job)
- [Method-layer map](#method-layer-map)
- [Candidate isolation](#candidate-isolation)
- [Public problem index](#public-problem-index)
- [Web GPT nine-lane prompt](#web-gpt-nine-lane-prompt)
- [Public capability boundaries](#public-capability-boundaries)
- [FAQ](#faq)
- [Machine-readable entrypoints](#machine-readable-entrypoints)
- [GEO facts and citation guide](#geo-facts-and-citation-guide)

## Quick start

From a clean public checkout:

```bash
git clone https://github.com/vibemathing/vibe-mathing-cn-public.git
cd vibe-mathing-cn-public
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install -r requirements.txt
make check
```

To exercise the deterministic SymPy fixture:

```bash
python3 scripts/vibe_mathing_cli.py register-problem \
  --file fixtures/sympy-counterexample/problem.json
python3 scripts/vibe_mathing_cli.py run \
  --problem-id problem:sympy-counterexample-fixture
```

This is a synthetic engineering fixture, not an open-problem solver or a new mathematical result. The fixed Lean/Mathlib fixture is documented in [`fixtures/lean-proof/README.md`](fixtures/lean-proof/README.md).

## Public problem index

The public concrete-problem namespace is indexed in [`problem-library/VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md). It points to:

- [`vibe-mathing-problem-library-public`](https://github.com/vibemathing/vibe-mathing-problem-library-public), the external ProblemContract catalog;
- [`vibe-mathing-problem-public-template`](https://github.com/vibemathing/vibe-mathing-problem-public-template), the fixed Web research Harness template;
- the [`vibemathing` repository list](https://github.com/vibemathing?tab=repositories), which locates concrete `problem-*` repositories.

Read-only metadata queries:

```bash
make index-public-problems
python3 scripts/query_vibemathing_public.py --kind library
python3 scripts/query_vibemathing_public.py --kind concrete --limit 20
python3 scripts/query_vibemathing_public.py --catalog
```

Select a canonical catalog contract first, re-check its identity, lifecycle, statement, and digest, then enter the matching single-problem repository and follow `WEB_BOOTSTRAP.md`. Remote catalogs, Issues/PRs, and Web Harness transport do not automatically admit a local Problem, Attempt, Result, or Solution. A copyable local draft is [`problem-library/templates/problem-contract.template.json`](problem-library/templates/problem-contract.template.json); it remains `lifecycle=draft` until separately reviewed.

## Web GPT nine-lane prompt

The public zero-barrier specification is [`prompts/web/ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md`](prompts/web/ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md). Given one problem-repository URL, its coordinator contract returns exactly nine self-contained T1–T9 Candidate-research prompt blocks. It does not launch workers, bypass a controlled repository's pre-admission process, or sign Evidence/Result.

Its high-assurance clauses treat unreviewed AI Lean source as potentially malicious: verifier-side trusted challenge and Candidate source remain separated and digest-bound; statement identity requires a trusted typed probe; semantic faithfulness requires independent review; native `leanchecker --fresh` remains in the `lean-kernel` trust domain; and proof-terminal replay must sandbox Candidate input and use a fixed, different-trust-domain checker/exporter/runner/config. Missing or unqualified routes remain `blocked/undetermined`.

Publication of this prompt does not imply that any private Suite/Harness version was released or rolled out.

## Architecture at a glance

![vibe-mathing-cn two-layer architecture overview](assets/architecture.svg)

This static diagram is also a reading and routing model: PLFB is the single conceptual root; F05/PWTSJ organizes execution, F04/OSPS maintains outcome space, and F09/F10 adjudicates evidence and Results. Faces meet through explicit Lines but cannot close one another's state. Plain-text clients should start with [`POINT-LINE-FACE-BODY-METAMODEL-v0.1.md`](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md); see [`RESEARCH-LIFECYCLE-MODEL-v0.1.md`](governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md) for F05 details.

## Core contract

The public workflow is:

```text
ProblemContract -> Attempt -> candidate/evidence -> Result
                                                    ├─> ResearchBundle (derived view)
                                                    └─> Solution View (derived index)
```

`ProblemContract` freezes the exact statement, domain, quantifiers, definitions, assumptions, allowed axioms, acceptance policy, and bounded runtime constraints. Only an active contract may create an Attempt. `ResearchBundle` is a read-only view derived from a consistent snapshot; it is not a fourth writable truth table.

The result state is two-dimensional:

- `outcome`: `undetermined | supported | established | refuted | inconclusive | withdrawn`;
- `evidence`: capabilities such as numeric, symbolic, human review, kernel check, counterexample check, axiom/escape audit, and statement faithfulness.

A finite computation, a Lean build, or a model self-review does not by itself establish a mathematical result. A proof and a counterexample that both pass closure for the same problem are a fail-closed conflict, not a choice between answers.

## Single conceptual root: Point–Line–Face–Body

Vibe Math uses **Point–Line–Face–Body (PLFB)** as its single conceptual metamodel root: stable objects are Points, typed directed relations are Lines, bounded knowledge or operation dimensions are Faces, and a reference-only Body composes Faces and cross-face Lines. PWTSJ, OSPS, Formal Methods, ProblemContract, Evidence, and Result are Faces or face-local models, not parallel top-level roots.

See [`POINT-LINE-FACE-BODY-METAMODEL-v0.1.md`](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md) for the public Face map, cross-face bindings, four graphs plus one ledger, and Body boundary. This release defines a conceptual standard; it does not claim an implemented PLFB registry service, Body runtime, OSPS orchestrator, or unified Observation Ledger.

## Top-level lifecycle: Project → Workflow → Task → Step → Job

PWTSJ belongs to PLFB Face F05. `Project` defines the complete goal, `Workflow` defines the task network, `Task` defines an input/output work unit, `Step` defines an operation and its method, and `Job` records one bounded execution. A Step may create multiple Jobs for parameter variants, bounded retries, or independent verification; recovering one Job requires a verified checkpoint, while rerunning creates a new Job.

This execution structure is orthogonal to F04 Outcome Space, F09 Evidence, and F10 Result:

```text
Project → Workflow → Task → Step → Job

ProblemContract → Attempt → candidate/evidence → Result → Solution View
```

`Job succeeded ≠ Step accepted ≠ Obligation closed ≠ OutcomeNode closed ≠ Result admitted ≠ Project solved`. The public repository treats this as the F05 architecture and routing language; it does not claim to provide a general scheduler, five persistent lifecycle schemas, an OSPS runtime, or multi-worker production capability. See [`RESEARCH-LIFECYCLE-MODEL-v0.1.md`](governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md).

## Method-layer map

The project uses a two-level map rather than treating a Lean tutorial index as the whole field:

```text
Specification & Semantics
  -> Deductive Verification / Theorem Proving (Lean's main territory)
  -> Model Checking / Abstract Interpretation / SAT-SMT-Symbolic Reasoning (including Symbolic Execution)
  -> Refinement & Synthesis

Lean stack: Type Theory & Kernel -> Language & Elaboration -> Proof Engineering
  -> Automation & Decision Procedures -> Library Engineering -> Applications
```

`ProblemContract` freezes specification and semantics; `math-proof` handles proof obligations; `math-formalization` separates Lean statements, proof terms, kernel checks, axiom/escape audits, and statement faithfulness; `math-computation` handles bounded computation and horizontal automation. Lean is a dependent-type-theory theorem-proving platform, not a synonym for all formal methods. See the full [`FORMAL-METHODS-MAP.md`](governance/standards/FORMAL-METHODS-MAP.md) for the taxonomy, learning order, and source map.

## Candidate isolation

A `CandidateObservation` is a discovery record, not a canonical ProblemContract. It remains `research_eligible=false` and cannot create an Attempt, Result, or Solution. Source labels such as `open`, `answered`, `resolved`, and `solved` are preserved as source metadata only; they are not mathematical outcomes.

The default problem query collection is `admitted`. Candidate queries must explicitly use `--collection candidates` or `--collection all`.

```bash
python3 scripts/query_problem_library.py --collection admitted --text Riemann --limit 10
python3 scripts/query_problem_library.py --collection candidates --limit 20
python3 scripts/build_candidate_observations.py
python3 scripts/validate_candidate_problem_library.py --verify-raw
```

Raw source responses, candidate snapshots, research records, runtime logs, credentials, private paths, and machine identities are not distributed in the public repository.

## Public capability boundaries

The 41-family tool registry uses:

```text
surveyed -> source_locked -> installed -> smoke_checked -> evidence_capable -> verifier_admitted
```

This is an evidence state machine, not an installation report. The public catalog is [`governance/tools/MATH_TOOL_CATALOG.md`](governance/tools/MATH_TOOL_CATALOG.md); the machine registry is [`governance/control-plane/math-tool-maturity.v1.json`](governance/control-plane/math-tool-maturity.v1.json). Families without public runtime evidence remain surveyed or source-locked.

Bounded canaries cover positive, negative, error, and timeout behavior. They test runtime protocol only and never create mathematical Results. Every computation, solver, CAS, external command, HTTP request, and canary subprocess must have a timeout, resource budget, output/response bound, stop condition, termination receipt, and explicit failure semantics.

## Verification

```bash
make check
python3 scripts/audit_public_status.py --format json --expect-empty
python3 scripts/validate_math_tool_maturity.py
python3 scripts/check_math_tools.py --profile portable --strict
MATH_CANARY_SOURCE_SHA256="$(sha256sum scripts/run_math_tool_canaries.py | awk '{print $1}')" \
  python3 scripts/run_math_tool_canaries.py --tools T13,T15,T16 --json --strict
```

For the complete model and Chinese documentation, see [`README.md`](README.md), [`problem-library/README.md`](problem-library/README.md), [`research/README.md`](research/README.md), and [`result-library/README.md`](result-library/README.md).

## Status

The repository publishes reusable schemas, owner skills, governance rules, bounded fixtures, source locks, and validation code. It does not claim a complete solution to any Millennium Prize problem or any other open mathematical problem.

## FAQ

### How should current status and external catalog information be verified?

Use the three canonical ledgers and `solutions.json` for local status. Treat external counts and repository states as dated snapshots, and re-read the remote contract, index, and digest before research. A verification date does not guarantee future freshness.

### Does this project solve an open mathematics problem?

No. The canonical Problem, Attempt, and Result ledgers are empty, the public solution index has no result IDs, and no open-problem solution is claimed.

### Why is a passing test not a proof?

A test checks code or a bounded input. It does not automatically establish a universal statement, natural-language statement faithfulness, independence, or novelty.

### What is the difference between a CandidateObservation and a Result?

A CandidateObservation is source-discovery input and remains outside research admission. A Result is a scoped atomic claim with outcome and evidence; a discovery record or proof draft cannot skip that boundary.

### What does the Lean fixture show?

It checks a fixed formal statement, proof term, and axiom/escape audit path. It does not automatically formalize or validate arbitrary natural-language mathematics.

### Why is `solutions.json` empty?

It is a derived read-only index. Only a proof or counterexample Result that passes direct verification, independence, and statement-faithfulness gates can enter it.

## Machine-readable entrypoints

- [`llms.txt`](llms.txt): concise retrieval context;
- [`GEO.md`](GEO.md): canonical facts, citation targets, and negative-boundary guide for humans and generative engines;
- [`assets/ai-citation/retrieval-contract.v1.json`](assets/ai-citation/retrieval-contract.v1.json): machine-readable intents, citations, and non-inference rules;
- [`scripts/query_ai_citation.py`](scripts/query_ai_citation.py): read-only rendering of fixed intent answers and stable citation URLs;
- [`scripts/audit_public_status.py`](scripts/audit_public_status.py): read-only status and SHA-256 snapshot audit for the canonical ledgers and solution index; it creates no Result;
- [`assets/ai-citation/schema-org-software.v1.json`](assets/ai-citation/schema-org-software.v1.json): Schema.org software-entity metadata for discovery and citation, not mathematical evidence;
- [`assets/ai-citation/`](assets/ai-citation/): summaries, terminology, bilingual answer matrix, GEO evaluation protocol, and report template;
- [`governance/publication/public-claims.v1.json`](governance/publication/public-claims.v1.json): public claims and evidence references;
- [`governance/control-plane/plfb-metamodel.v0.1.json`](governance/control-plane/plfb-metamodel.v0.1.json) and [`plfb-metamodel.schema.json`](governance/control-plane/plfb-metamodel.schema.json): conceptual types, F01–F13, B0–B4, and capability boundaries without business instances;
- [`scripts/validate_plfb_metamodel.py`](scripts/validate_plfb_metamodel.py): rejects duplicates, dangling references, wrong Face ownership, PWTSJ/OSPS misplacement, and false runtime capability claims;
- [`problem-library/VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md): external concrete-problem catalog, repositories, and Web research template entrypoint;
- [`governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md`](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md): the single PLFB conceptual root and cross-face/Body boundaries;
- [`governance/standards/FORMAL-METHODS-MAP.md`](governance/standards/FORMAL-METHODS-MAP.md): the formal-methods taxonomy and Lean positioning;
- [`governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md`](governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md): the Project → Workflow → Task → Step → Job lifecycle model;
- [`CITATION.cff`](CITATION.cff) and [`codemeta.json`](codemeta.json): citation and software metadata;
- [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`SECURITY.md`](SECURITY.md): contribution and security boundaries.

Here, GEO means Generative Engine Optimization for accurate entity identification, status, evidence, and boundaries. It measures documentation understanding and citation accuracy, not ranking, recommendation, or mathematical correctness.

## GEO facts and citation guide

For a compact, citation-ready description, start with [`GEO.md`](GEO.md), then cite the nearest first-party source: `solutions.json` and the three ledgers for current status, the Problem/Attempt/Result schemas for the workflow, [`FORMAL-METHODS-MAP.md`](governance/standards/FORMAL-METHODS-MAP.md) for method positioning, and [`VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md) for external problem pointers. Preserve the empty-ledger, Lean-position, pointer-only, and external-snapshot-revalidation boundaries.
