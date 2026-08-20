# 001 — Anchored agentic tooling

**Status**: Draft

**Created**: 2026-08-19

**Input**: "Iterate on the agentic-writing package as a V2 of the sei-internal-skills
and agents. Right now we have virtually no adoption of those tools, so rethink them in
simpler terms — keep the mechanisms that work well, like the agent experts, and refine
the skills to strategically replace custom engineering rigor, writing or thinking
patterns with semantic anchors instead. Frame it from the beginning around principled
agentic tooling best practices, to leverage existing research that tells us why
something works and that it can be expected to keep working as models develop. Anchor
it around spec-driven development with a clean semantic anchoring on technical design
doc writing style."

<!-- vale off -->
## Anchors

Named once. Not restated below.

| Anchor | Governs | Does not cover |
|---|---|---|
| EARS | requirement syntax | whether the template matches the real class |
| RFC 2119 | normative keywords | whether the obligation is the right one |
| INVEST | user story quality | whether the slice delivers value |
| Gherkin | acceptance scenarios | whether the scenario is the important one |
| Conventional Commits | commit subject | whether the scope names the right component |
<!-- vale on -->

## Why this exists

V1 is a single-author library. Measured on 2026-08-19:

| Measure | Value |
|---|---|
| Repository created | 2026-03-21 |
| Commits | 152 by one author, plus 1 |
| Merged pull requests | 100, all by the same author |
| Forks | 0 |
| Issues opened by anyone else | 0 |
| Skills | 16 core, 11 experimental |
| Skill payload | 13,778 lines |

Five months, no second user.

## The thesis

**Leanness is a maintainability win, not an adoption win.** Sixteen lean skills nobody
installs is the same outcome as sixteen heavy ones. The distinguishing variable in V1 is
not size. It is whether a mechanism reaches an engineer who is not looking for it.

| Mechanism | Reaches an engineer | Adopted in V1 |
|---|---|---|
| Doctrine block in the context file | Pushed into the repository, read every session | Yes |
| Agent expert | Addressable by role name | Yes |
| CI gate | Blocks a merge whether or not it was invoked | Yes |
| Skill | Needs an install, then a remembered trigger phrase | No |
| Experimental skill | Needs a second, separate opt-in | Invisible |

So V2 inverts the ratio. The convention moves into the channel that already works, and
a skill becomes the rare case.

**This is why semantic anchoring is load-bearing rather than cosmetic.** An anchor is
small enough to live in an always-loaded context file. A 350-line knowledge kit is not.
Anchors do not make skills better. They make skills unnecessary for the common case.

### Why it stays reliable

An anchor named after a densely published standard becomes **more** reliable as models
train on more text about that standard. A hand-tuned kit becomes **less** reliable as
models drift, and it fails silently.

The claim is bounded, and the bound is part of the design: an anchor is only as strong
as its prior. A new or internal convention has no prior, cannot be anchored, and stays
stated in full and verified.

## Architecture

Four channels. Each convention belongs to exactly one.

| Channel | How it reaches an engineer | Holds |
|---|---|---|
| **Contract** | Always loaded, no invocation | The anchors, and the local rules that have no prior |
| **Evidence** | Read when a claim is questioned | Per anchor: steward, licence, probe, verdict, date |
| **Gate** | Blocks a merge | The checkable subset, as lint rules in CI |
| **Expert** | Named by role | The persona that applies judgement a gate cannot |

A **skill** exists only where a procedure has real side effects. Everything that is
knowledge belongs in the contract.

Spec Kit supplies the contract slot already: its constitution is versioned, ratified,
amendable, read by every phase, and its governance clause requires reviews to verify
compliance. V2 uses that slot rather than inventing one. Path and file decisions beyond
the channel belong in `plan.md`.

## User Scenarios & Testing

### User Story 1 - An engineer gets the convention without asking for it (Priority: P1)

An engineer who has never read this repository opens a feature in a consuming repository
and writes a design document. The anchors are already in their context, so the document
comes out in the house style. They installed nothing and invoked nothing.

**Why this priority**: This is the whole product. Every other story improves it or
assures it, and none has value if this one does not work. It is also the story V1 never
completed once in five months.

**Independent Test**: In a repository with the contract present and no skills installed,
ask for a design document. Confirm the output follows the anchored style, and that no
slash command was invoked.

**Acceptance Scenarios**:

1. **Given** a repository carrying the contract and no installed skills, **When** an
   engineer asks for a technical design document, **Then** the output follows the
   anchored style without any invocation.
2. **Given** the same repository, **When** the engineer runs the gate, **Then** the gate
   reports findings against the same anchors the contract named.

### User Story 2 - A reviewer can tell why a rule exists (Priority: P2)

A reviewer disagrees with a finding. They follow the rule to the anchor, the anchor to
its steward and licence, and the anchor to its probe verdict and the date it was taken.
They can then argue about the standard rather than about taste.

**Why this priority**: An unexplained convention is the failure V1's README already
names — a hand-tuned prompt cannot explain itself. Without this, V2 is a different set
of unexplainable preferences.

**Independent Test**: Pick any finding the gate reports. Confirm the chain from rule to
anchor to steward to probe verdict resolves with no missing link.

**Acceptance Scenarios**:

1. **Given** a reported finding, **When** a reviewer looks up its rule, **Then** the
   rule names the anchor and the anchor resolves to a registry entry with a steward, a
   licence, and a probe verdict.
2. **Given** an anchor with no recorded verdict, **When** a reviewer reads the registry,
   **Then** the absence is stated rather than implied.

### User Story 3 - A design document reads correctly for a human and an agent (Priority: P2)

An author writes a technical design document. A human reviewer scans it and finds the
decision. An agent reads it linearly and acts on it. Neither has to guess which
sentences are normative.

**Why this priority**: The design document is the artifact where the organisation's
thinking is encoded, and the one both audiences consume. It is the natural first
subject, and it is the subject this repository already has machinery for.

**Independent Test**: Take one existing design document. Run the gate. Confirm every
finding names a clause of a public standard, and that fixing the findings does not
change the document's meaning.

**Acceptance Scenarios**:

1. **Given** a design document, **When** the gate runs, **Then** each finding cites a
   rule that cites a clause.
2. **Given** a normative statement, **When** an agent reads it, **Then** the obligation
   is unambiguous because the keyword is uppercase.

### User Story 4 - The contract survives a model upgrade (Priority: P3)

A new model becomes the default. The probe suite runs against it. An anchor whose
recognition drops is demoted to stated text before it silently degrades a review.

**Why this priority**: Silent degradation is the failure mode that makes a prompt-only
approach untrustworthy. It is also the failure a gate cannot catch, because the gate
checks the artifact and not the model.

**Independent Test**: Run the probe suite against two different models. Confirm the
registry records a distinct verdict per model, and that a below-threshold verdict blocks.

**Acceptance Scenarios**:

1. **Given** a new default model, **When** the probe suite runs, **Then** every anchor
   receives a scored verdict recorded with the model identifier and the date.
2. **Given** an anchor scoring below the threshold, **When** the gate runs, **Then** it
   fails until the registry records the lower verdict.

### Edge Cases

- **An anchor that is famous but sparse in training data.** Fame is not evidence. The
  probe decides.
- **A local rule that resembles a public standard.** It stays local, because a later
  upstream change would silently move the rule.
- **A convention with no verifier.** It is stated in the contract and listed as
  uncheckable. It is never implied to be checked.
- **Two anchors a model confuses.** The pair is named in full, never by short form.
- **A model that names an anchor and applies it wrongly.** Recognition passes,
  application fails, the verdict is partial, and the stated text stays.

## Requirements

### The contract

**FR-001** The repository MUST hold exactly one always-loaded contract. A convention
absent from it MUST NOT be treated as adopted.

**FR-002** WHERE a convention names a public standard with a recorded passing verdict,
the contract MUST name the anchor and MUST NOT restate the standard.

**FR-003** WHERE a convention has no public standard, or no passing verdict, the
contract MUST state it in full.

**FR-004** The contract MUST state, for each convention, whether a gate checks it.

**FR-005** IF a convention cannot be checked, THEN the contract MUST say so rather than
leave the reader to assume a check exists.

### Evidence

**FR-006** The registry MUST record, per anchor: steward, licence, redistributability,
the probe, and every verdict with its model identifier and date.

**FR-007** WHEN an author adds an anchor to the contract, the author MUST record a
probe verdict first.

**FR-008** The probe MUST score recognition, application, differentiation, and
consistency.

**FR-009** The probe MUST use deterministic multiple-choice questions, so that no model
scores its own recall.

**FR-010** IF an anchor scores below the partial threshold, THEN the contract MUST keep
the stated text alongside the anchor.

**FR-011** IF an anchor scores below the failing threshold, THEN the author MUST remove
it from the contract and state the rule instead.

### Gates

**FR-012** Every gate finding MUST name a rule, and every rule MUST name the clause it
enforces.

**FR-013** A gate MUST NOT be weakened to make a check pass. IF a rule cannot be
expressed, THEN it MUST be deleted and the constraint recorded as uncheckable.

**FR-014** The gate MUST run in continuous integration on every change to a governed
artifact.

### Experts and skills

**FR-015** An expert MUST be addressable by role name and MUST NOT require a remembered
trigger phrase.

**FR-016** A skill MUST exist only where a procedure has side effects outside the
repository. Knowledge MUST live in the contract.

**FR-017** WHEN an author proposes a new skill, the author MUST first state why the
convention cannot live in the contract.

### The tracker

**FR-020** Linear is the tracker. WHERE a phase turns work units into tracker issues,
that path MUST target Linear.

**FR-021** The repository MUST NOT ship a GitHub-issue path. Spec Kit's own
`speckit-taskstoissues` targets GitHub, so it is removed from the vendored set rather
than left installed and unused.

### Licensing

**FR-018** This repository is public. Every artifact in it MUST be publishable: no
proprietary standard text, no controlled dictionary, and no organisation-specific
operational detail.

**FR-019** IF a convention is specific to one organisation's systems, THEN it MUST stay
in that organisation's own repository and cite the public anchor from there.

## Success Criteria

Each criterion names the command that checks it, or the word `judgement`.

**SC-001** One engineer who is not the author uses the contract on work the author did
not assign, within 60 days of the first release.
*Verifier:* authorship of a commit or pull request in a consuming repository. This is
the criterion V2 exists to satisfy; the others are subordinate to it.

**SC-002** Every anchor named in the contract resolves to a registry entry. A dangling
name fails the build.
*Verifier:* the registry consistency job.

**SC-003** Every registry entry carries a verdict for the current default model.
*Verifier:* the probe suite.

**SC-004** The gate reports zero errors on every governed artifact in this repository.
*Verifier:* `vale README.md docs/ anchors/ specs/`

**SC-005** The contract fits in a single file a person reads in under five minutes.
*Verifier:* line count under 250.

**SC-006** No knowledge artifact in the repository exceeds 150 lines. A longer one is
evidence that a standard is being restated.
*Verifier:* a line-count check in CI.

**SC-007** A reader can trace any finding to a clause without asking the author.
*Verifier:* judgement — a reviewer attempts it on three findings and reports.

## Migration

V1 has 16 core skills. Eight are built on organisation-specific profiles and cannot move
to a public repository under FR-018 and FR-019.

| Disposition | Skills |
|---|---|
| **Convert to anchors and experts** in V2 | `idiomatic`, `systems`, `root-cause`, `xreview` |
| **Delete** — process rigor that a standard already covers | `audit-skill`, `author-skill`, `brevity`, `pr-quality` |
| **Stay in the organisation's repository** — Sei-local | `evm`, `kubernetes`, `platform`, `harbor-dev`, `gov-ops`, `validate-release`, `validator-platform`, `chaos-suite` |

Deletion is the point, not a cost. A skill that encodes rigor a public standard already
carries is the custom pattern this iteration exists to remove.

## Assumptions

- Spec Kit's constitution is a stable slot. Its templates ship with the CLI, so the
  shape tracks upstream.
- The probe suite runs against the models the team actually uses, not a fixed list.
- The four generic skills carry judgement that no lint rule can express, which is why
  they become experts rather than gates.
- `NOTICE.md` continues to govern what enters this repository.

## Out of scope

- The organisation-specific skills stay where they are. No generic rewrite here.
- V1 is not retired. It keeps its history and its Sei-local content.
- The probe questions are not written here. This spec requires them; `plan.md`
  designs them.
- The file layout beyond the four channels is a `plan.md` decision.

## Open questions

1. **Where does the contract physically live** so that it is loaded by every harness and
   not only by one? Spec Kit's constitution is read by the Spec Kit phases. A root
   context file is read by the session. These are perhaps the same file.
2. **What is the failing threshold for a probe?** Published practice uses 80% and 50%
   bands. Adopting them without measuring our own anchors would be borrowing a number.
3. **Do the four generic skills become experts, or does one expert absorb several?**
   Four narrow experts have the same recall problem as four skills.
