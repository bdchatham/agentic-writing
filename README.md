# agentic-writing

Open standards, packaged so that an AI model and a linter can use the same source of truth.

## The problem this solves

A personal skill or a hand-tuned prompt can improve model output. It cannot explain itself.
Nobody else can read it, verify it, or tell you which part did the work. When the model
version changes, you do not know what broke.

This repository replaces that with a two-sided contract. One side steers generation. The
other side measures the artifact. Both sides point at the same public standard.

## The three layers

| Layer | Artifact | What it does | What it cannot do |
|---|---|---|---|
| **Anchor** | `anchors/registry.yaml` | Names a public standard in the model context. Compresses a large convention into a few tokens. | Guarantee compliance. An anchor is a hint. |
| **Verifier** | `styles/AgenticWriting/*.yml` | Checks the finished text with [Vale](https://vale.sh). Each finding names a rule. Each rule names a clause in the standard. | Check the parts of a standard that need judgement. |
| **Eval** | `evals/` | Tests two things: does this model still recognize the anchor, and do the rules still find what they must find. | Prove the standard is the correct standard for your task. |

An anchor is a *plan*: it holds intent, and the intent dies if the context does not carry it.
A Vale run is an *ensure*: it measures the artifact from zero, every time, with no memory of
how the artifact was made. Prose quality must not depend on the plan. It must be
re-derivable from the artifact. This is why the anchor layer alone is not enough.

## Why "semantic anchor" works at all

An anchor is a well-defined term that acts as a reference point in a prompt. The term
retrieves a body of knowledge from the model. It does not add knowledge. `arc42` does no
more than a full description of its 12 sections. It costs fewer tokens, and every reader
resolves it to the same specification.

This has a hard limit. An anchor works only if the term is stable and widely documented.
A term that you invent yourself carries nothing. Therefore every anchor in the registry
has a `recognition_test`, and the test result is recorded per model. See
`evals/recognition/README.md`.

Prior art for the concept: <https://llm-coding.github.io/Semantic-Anchors/>

## Quick start

Install Vale, then the toolkit:

```bash
brew install vale          # or: see https://vale.sh/docs
curl -fsSL https://raw.githubusercontent.com/bdchatham/agentic-writing/main/scripts/install.sh | bash
```

That is the whole setup. `vale` now works in any directory, with no
per-project configuration and nothing to commit. Re-run it to pick up new
rules, and pass `--dry-run` first to see what it touches.

### Which rules run depends on where the file sits

The contract is a directory convention rather than a config file, so a scratch
directory works as well as a repository:

| Path | What runs |
|---|---|
| `specs/<feature>/spec.md` | spec structure, RFC 2119 casing, prose |
| `docs/adr/NNNN-name.md` | the four Nygard sections, prose, no sentence cap |
| `docs/design/name.md` | the four design sections, prose, no sentence cap |
| `docs/procedures/name.md` | the tighter procedure limits |
| `tickets/id.md` | the seven ticket sections, prose |
| anywhere else | prose only |

The sentence cap comes off an ADR and a design document on purpose. Those carry
reasoning, and reasoning travels through subordination that a word limit forces
you to cut. [ADR 0002](docs/adr/0002-vale-checks-prose-and-the-template.md)
records the evidence.

### Then

```bash
vale ls-config             # confirm the styles load, before you trust a finding
vale specs/                # lint a specification with its structure rules
~/.agentic-writing/.specify/templates/     # start a document from a template
~/.agentic-writing/scripts/build-spec-artifact.sh --help   # publish one
```

### CI, when a team wants it

Optional, and separate. One engineer trying the framework needs none of it.

```bash
cd <repo> && curl -fsSL .../scripts/install.sh | bash -s -- repo
```

That writes a `.vale.ini` and a workflow. The workflow calls a reusable one
from this repository. The checks then run for everyone, rather than for
whoever installed the toolkit.

## Repository map

```
anchors/registry.yaml      machine-readable anchor catalog (the single source of truth)
anchors/<id>.md            one page per anchor: normative summary + citation + coverage
styles/AgenticWriting/     Vale rules, one file per checkable rule
styles/config/vocabularies/ accept.txt and reject.txt, per Vale 3's layout
evals/recognition/         "does the model know this anchor" tests, per model version
evals/fixtures/            text that must produce known findings
scripts/                   registry -> prompt fragment, and OpenSTE vocabulary sync
docs/architecture.md       arc42-lite description of this system
docs/adr/                  decisions, in ADR-Nygard format
```

## Status

Alpha. The Vale rules in this repository are written against the documented extension
points but they are not yet verified against a Vale binary. Run `vale ls-config` and the
fixture suite first. Treat every rule as a candidate until CI is green.

## Licensing boundary

Read `NOTICE.md` before you add a standard. Some standards are public specifications that
you may quote. ASD-STE100 is not one of them: the specification and its dictionary are
copyrighted, and this repository does not contain them.
