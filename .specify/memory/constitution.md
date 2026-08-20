# agentic-writing Constitution

This file is the contract. It loads in every session with no invocation, and that is
why a convention here reaches an engineer who is not looking for it. **A convention
absent from this file is not adopted.**

## Core Principles

### I. Anchor, contract, or delete

Every convention is one of three things. An **anchor** names a public standard the
model already holds: name it and spend no more words. A **contract** is a local rule,
or a term with a weak prior: state it in full. Anything that is neither gets deleted.

### II. Evidence before anchor

Naming a standard is a bet on its prior. A term becomes an anchor only after a probe
records that a model resolves it, with the model identifier and the date. An unprobed
term is a contract. Fame is not evidence.

### III. The gate is the claim

A rule no command checks is a wish. Every convention states whether a gate checks it,
and says so plainly when none does. A gate is never weakened to make a check pass: a
rule that cannot be expressed gets deleted, and the constraint is recorded as
uncheckable.

### IV. Push, not pull

A convention reaches an engineer through this file or through a gate. It does not
reach them through a command they have to remember. **A skill exists only where a
procedure has side effects outside the repository.** Knowledge lives here. An author
proposing a skill states first why the convention cannot live in this file.

### V. State the gap

A named standard fails three ways: the model substitutes openly, it substitutes
silently, or it invents. Only the first announces itself. Every anchor therefore
carries what it does **not** cover, and a partial verdict keeps its stated text alongside the anchor.

## The anchors

Name one from this table. **Naming an anchor absent from it is forbidden** — a
confabulated method name reads authoritative and costs more than plain prose.

**No anchor here carries a recorded probe verdict yet.** Until one does, treat a
surprising output as the anchor failing rather than the model disagreeing.

| Anchor | Governs | Does not cover |
|---|---|---|
| EARS | requirement syntax | whether the template fits the real class |
| RFC 2119 | normative keywords, uppercase | whether the obligation is the right one |
| INVEST | whether a story is a real slice | whether the slice delivers value |
| Gherkin | acceptance scenarios | whether the scenario is the important one |
| Cockburn use cases | a flow with triggers and extensions | whether the extensions are complete |
| arc42 | section order of a design | section quality |
| C4 model | diagram levels | where the boundary belongs |
| Domain-Driven Design | bounded context, ubiquitous language | where the boundary actually falls |
| Clean Architecture | dependency direction between contexts | layering inside one — see below |
| ADR (Nygard) | a decision record that supersedes | whether consequences state the real cost |
| TDD | test-first, red then green | which school suits this codebase |
| Property-Based Testing | invariants over generated inputs | finding the invariant |
| Conventional Commits | commit subject | whether the scope names the right component |
| BLUF | conclusion first | whether that sentence is the bottom line |
| Diátaxis | one page, one mode | whether the mode was chosen well |
| Effective Go | Go idiom | modules and generics — it predates both |
| Go Code Review Comments | review-time Go checklist | design-level structure |
| Google Go Style Guide | normative Go rulings | this repository's own patterns |
| Code Smells | surface signs of design trouble | whether the fix is worth it |

**Clean Architecture carries a documented criticism.** Bogard and Comartin argue the
indirection does not pay, because most changes traverse every layer anyway. It also
collides with Go idiom, where three similar lines beat a premature helper. Use it for
dependency direction between bounded contexts. Do not impose it inside one.

## Stated in full

These have no reliable public prior. Naming them is not enough.

**Writing.** Write in Simplified Technical English (ASD-STE100): approved words in one
meaning only, active voice, one instruction per sentence, procedural sentences under 20
words and descriptive under 25, noun clusters of at most 3 words. Keep code, commands,
identifiers, and quoted output verbatim.

**Code structure.** Code reads as a legible sequence of named steps a new engineer
follows top to bottom with no narrator. The method body is the table of contents; step
names carry the *what*; you drill into a step only for its detail. A readability
refactor changes structure only, and the unchanged tests still passing is the proof.

**Comments.** A comment states the present. Never history, never why-removed — that
belongs in the commit. Put it at the top, as package, file, or type documentation.

**Errors are interface.** Every error condition is part of the public contract.

**Two-way doors only.** A one-way door needs explicit human approval before you
finalize it: a persisted schema, a public API contract, a wire format, or anything
another system comes to depend on.

## Writing modes

Four artifacts carry a structure contract. Ordinary prose carries the prose rules only.

| Artifact | Path | Gate checks |
|---|---|---|
| Design | `docs/design/**` | Non-goals, Alternatives, Trade-offs, Open questions |
| Spec | `specs/**` | Anchors, Success Criteria, Independent Test |
| Ticket | `tickets/**` | the seven sections of the body |
| Procedure | `docs/procedures/**` | 20-word sentences, imperative steps |

Run `vale <path>`. Exit code 0 means "no finding at or above the gate". It does not mean
compliant.

## The spec contract

A specification uses Spec Kit's filenames, CLI, and vendored templates. Seven deltas
apply, each fixing something the upstream template leaves to the author.

| Delta | In | Fixes |
|---|---|---|
| `## Anchors`, each with a *does not cover* column | `spec.md` | The body restates the method without it |
| `## Glossary` | `spec.md` | An agent reads linearly and cannot ask what a term means |
| `## Boundary Context` | `spec.md` | A spec with no stated boundary grows while open |
| `**Objective:** As a <role>, I want <X>, so that <Y>` | each requirement | Names the beneficiary; prevents an orphan requirement |
| EARS with a named actor — `THE Controller SHALL` | each requirement | `System MUST` names no actor |
| `## Boundary Commitments` — Owns, Out of Boundary, Allowed Dependencies | `plan.md` | Makes the dependency rule reviewable |
| `### Revalidation Triggers` | `plan.md` | The escalation path, agreed before anyone hits it |
| `### Existing Architecture Analysis` | `plan.md` | Forces the as-is to be read before the to-be is written |

**Every success criterion names its verifier.** `SC-002 … Verifier: gorelease in CI`.
A criterion nothing checks says `judgement`. An unmarked criterion is not honest.

**Every user story carries four things** — priority, why this priority, an Independent
Test, and acceptance scenarios. A ticket is generated from them and cannot invent what
the story omitted.

**Every task carries five** — a test-first instruction, an `Observable:` check,
`_Requirements:_` upward, `_Boundary:_`, and `_Depends:_`.

**Never invent a requirement.** An unstated detail becomes
`[NEEDS CLARIFICATION: <the question>]`. A plausible default written silently into a
spec is the failure the artifact exists to prevent.

**`spec.md` holds what and why only.** Naming a library, a schema, a signature, or a
file path moves the line to `plan.md`.

## Governance

Precedence, highest first: a direct instruction in the conversation; the repository's
own instruction file; this file.

This repository is public. Every artifact in it is publishable: no proprietary standard
text, no controlled dictionary, no organisation-specific operational detail. A
convention specific to one organisation's systems stays in that organisation's
repository and cites the public anchor from there.

**No artifact here names a private skill or agent as an authority.** If a rule matters,
state the rule. A citation a reader cannot follow is not a citation. CI enforces this.

An amendment states what changed and why, and bumps the version below. Deleting a
principle requires the same ceremony as adding one.

**Version**: 1.0.0 | **Ratified**: 2026-08-19 | **Last Amended**: 2026-08-19
