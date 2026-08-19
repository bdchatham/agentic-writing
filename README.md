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

```bash
brew install vale          # or: see https://vale.sh/docs
vale sync                  # fetch the third-party packages named in .vale.ini
vale ls-config             # confirm the styles load, before you trust any finding
vale docs/ README.md       # lint this repository with its own rules
```

## Repository map

```
anchors/registry.yaml      machine-readable anchor catalog (the single source of truth)
anchors/<id>.md            one page per anchor: normative summary + citation + coverage
styles/AgenticWriting/     Vale rules, one file per checkable rule
styles/Vocab/              accept.txt and reject.txt vocabularies
output-styles/             Claude Code output style generated from the registry
evals/recognition/         "does the model know this anchor" probes, per model version
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
