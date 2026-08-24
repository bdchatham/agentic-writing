# 2. Vale checks prose and the template, and nothing that needs an open set

## Status

Accepted, 2026-08-24. Refines ADR 0001, which declared the anchor-linter seam but did not
bound the linter's side of it.

## Context

One full specification cycle produced four failures that no gate caught. Two of them are
relational: a requirement ID referenced but never declared, and a requirement declared but
never verified. Both look linter-shaped, so the obvious next step was to write Vale rules
for them.

Research settled that they are writable, and that writing them is a mistake.

A rule that relates declared IDs to referenced IDs needs `conditional`, whose `first`
pattern compares its full match against `second`'s capture group. It needs `scope: raw`,
because under `scope: text` the same rule stops firing at all — three fixtures that catch a
real missing-verification defect under `raw` go silent under `text`. Under `raw` it then
reads inside fenced code blocks, so it flags a sample log holding `REQ-404`. The inline
`<!-- vale Rule = NO -->` toggle does not suppress a `raw` rule either. Uniqueness needs a
Tengo script, which is a program inside YAML with no tests and no debugger.

A rule that checks a FROZEN section names an approver fails differently. The correct form
sweeps an arbitrary section body, and Vale uses `regexp2`, which backtracks: the pattern
crashes with `maximum backtracking stack size exceeded` at roughly 400 lines in one
section. The form that ships is a bounded window that passes an approver from an unrelated
section.

A first attempt put the boundary at arity: one location for Vale, two or more for a test.
**That boundary is wrong, and a test showed why.** A rule requiring `## Problem` before
`## Impact` relates two locations, and Vale enforces it with a variable-length lookbehind.
It ran over a 2,523-line document in 130 ms and did not crash. The pattern anchors to two
known literals rather than scanning an unbounded body.

The literature reaches the same narrow scope from another direction. The one rigorous EARS
checker reports that it cannot detect semantic mismatches. A lexical rule caught three of
four requirements that a shape rule passed. AQUSA reached 72.2% precision overall and
42.3% on well-formedness, and its authors held the tool to "the clerical part of RE".

## Decision

Vale validates prose and enforces the template. It checks nothing that needs an open set.

The discriminator is one question. Can the rule state the thing it looks for?

- **Prose.** Approved words, active voice, sentence length, noun clusters, RFC 2119
  casing, and the unbounded terms ISO/IEC/IEEE 29148:2018 clause 5.2.7 names. A closed
  vocabulary, known to whoever writes the rule.
- **Template.** Section presence, and section order. A closed set of headings, known to
  whoever writes the rule. The 16 heading rules already shipping stay, and an order rule
  qualifies on the same grounds.
- **Neither.** Anything whose members are unknown until someone writes the document:
  requirement IDs, cross-references, coverage of one set by another, uniqueness within a
  set. No Vale rule. A test, or nothing.

Two rules follow from the failure modes above rather than from the discriminator:

- A pattern MUST NOT scan an unbounded body. Bound every quantifier, or do not write the
  rule.
- A template rule states presence or order only. It MUST NOT claim the section says
  anything, and its comment says so, as the shipping rules already do.

## Consequences

Positive:

- The next person answers the question without judgement: can you write the thing you are
  checking for into the rule? Headings yes, IDs no.
- Every rule the package ships keeps working. The decision bounds growth; it removes
  nothing.
- The style package stays small, and it stays honest about what it does not check.
- Rules stop being the reason to reshape an artifact. A specification adopts a `REQ-nnn`
  convention because tickets link IDs, not because a linter needs a pattern to match.

Negative:

- Two of the four failures from the cycle get no automated gate. They need a reader, and
  the contract must say so rather than implying coverage.
- `verifier.coverage: none` becomes more common in the registry. That field carries more
  weight now, and an unstated `none` reads as an oversight.
- A template rule enforces a house shape, not a public standard. It cannot cite a clause
  the way a prose rule cites 29148 §5.2.7, so its message states the consequence instead.
- Order rules are newly permitted and none exist yet. Someone will write one badly before
  someone writes one well.

## Glossary

Terms a reader needs and did not get from us. House vocabulary does not belong here.
Write a term this team invented as plain words at the point of use instead.

**open set.** This document's term for a collection whose members stay unknown until
someone writes the document. The requirement IDs a spec happens to declare are one. A
closed set holds still while someone writes the rule, and a template's headings are one.

**existence, occurrence, conditional.** Vale rule types. The first two match patterns
inside one scope. `conditional` is the only one that relates two patterns, and it is the
one every relational rule needed.

**scope.** Which slice of a document a Vale rule reads. `scope: text` reads rendered prose
block by block. `scope: raw` reads the whole file including fenced code blocks, and it
ignores the inline suppression comment.

**regexp2.** The regular expression engine Vale uses. It supports lookarounds, which RE2
does not, and it backtracks, which RE2 does not. The backtracking is what crashes an
unbounded pattern.

**Tengo.** The scripting language behind Vale's `script` rule type. It is the only way to
express a check that has to accumulate state, and it runs with no test harness and no
debugger.

**anchor.** A public term a model already holds, named in a prompt so the concept arrives
without spending words defining it. ADR 0001 pairs each one with a linter rule and records
how much of the standard that rule covers.

**EARS.** Easy Approach to Requirements Syntax. Five sentence templates for writing a
requirement, which fix clause order and make a shape check possible.

**AQUSA.** A research tool that lints user stories for quality defects. Cited here for its
measured precision and for the scope its authors chose to keep.

**ISO/IEC/IEEE 29148.** The requirements engineering standard. Clause 5.2.7 carries a
normative list of unbounded and ambiguous terms. That makes it the one clause here a
linter can enforce and cite.

## Alternatives considered

**Put the boundary at arity: one location for Vale, two for a test.** Rejected on
evidence. A heading-order rule relates two locations, works, and is fast. That boundary
would have banned a rule the template genuinely wants.

**Write the relational rules anyway, and accept the workarounds.** Rejected. The
`conditional` rule that misses under `scope: text` fails silently, and a rule that always
passes is worse than no rule, because it gets trusted.

**Drop Vale and rely on anchors.** Rejected, and ADR 0001 already gives the reason. An
anchor shapes what a model writes and produces no evidence about what it wrote. Dropping
the linter leaves a model's own claim as the only evidence, which is the failure this
cycle demonstrated three times.

**Replace Vale with a parser for everything.** Rejected for now. A parser handles open sets
and would also handle prose, but the prose rules work today and rewriting them buys
nothing. Revisit if a repository needs the open-set checks enough to build the parser
anyway.
