#!/usr/bin/env bash
# An anchor arrives with four artifacts or it does not arrive. This enforces
# that, and counts the anchors exempt from it.
#
# The exemption is the point. Every anchor present when the rule was written
# predates it, so exempting them silently would make the rule decorative. They
# are marked `grandfathered` in the registry, printed on every run, and the
# count can only shrink.
#
# The root is anchored to this script, not to the caller's directory, and an
# empty anchor set is a failure. A checker whose empty case is "pass" answers
# "all is well" and "I found nothing" identically.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 - "$ROOT" <<'PY'
import pathlib, sys, yaml

root = pathlib.Path(sys.argv[1])
reg = yaml.safe_load((root / 'anchors' / 'registry.yaml').read_text())
anchors = reg.get('anchors') or []
bad, rows, exempt = [], [], []

if not anchors:
    print("FAIL no anchors in the registry — refusing to report success on an empty set")
    sys.exit(1)

def artifacts(a):
    """The four artifacts, computed rather than declared."""
    aid = a['id']
    rules = [r.split('.', 1)[1] for r in (a['verifier'].get('rules') or [])]
    cov = root / 'coverage' / f'{aid}.yml'

    have_entry = bool(a.get('steward') and a.get('license') and a.get('recognition'))
    have_cov = cov.is_file()

    missing_fixture = [r for r in rules
                       if not (root / 'evals' / 'rules' / r / 'expected.txt').is_file()]
    have_fixtures = not missing_fixture

    counted = set()
    if have_cov:
        doc = yaml.safe_load(cov.read_text()) or {}
        fp = doc.get('false_positives') or {}
        counted = set((fp.get('rules') or {}).keys())
    missing_count = [r for r in rules if r not in counted]
    have_counts = not missing_count

    return rules, have_entry, have_fixtures, have_cov, have_counts, missing_fixture, missing_count

for a in anchors:
    aid = a['id']
    status = a.get('admission')
    if status not in ('admitted', 'grandfathered'):
        bad.append(f"anchor '{aid}': admission must be 'admitted' or 'grandfathered', got {status!r}")
        continue

    rules, entry, fixtures, cov, counts, miss_fix, miss_cnt = artifacts(a)
    mark = lambda b: 'yes' if b else 'no '
    note = 'no rules' if not rules else f'{len(rules)} rules'
    rows.append(f"{aid:<24}{status:<16}{mark(entry):<7}{mark(fixtures):<10}{mark(cov):<10}{mark(counts):<8}{note}")

    if status == 'grandfathered':
        exempt.append(aid)
        continue

    # An anchor with no rules satisfied artifacts 2 and 4 by vacuous truth:
    # "every rule has a fixture" is true of no rules. A standard nothing checks
    # is exactly what the admission rule exists to keep out.
    if not rules:
        bad.append(f"anchor '{aid}' is admitted but names no rules, so it checks nothing. "
                   f"An anchor with no verifier belongs at coverage: none and admission: grandfathered")

    if not entry:
        bad.append(f"anchor '{aid}' is admitted but its registry entry lacks steward, licence or recognition test")
    if not cov:
        bad.append(f"anchor '{aid}' is admitted but has no coverage/{aid}.yml")
    for r in miss_fix:
        bad.append(f"anchor '{aid}' is admitted but rule '{r}' has no fixture at evals/rules/{r}/expected.txt")
    for r in miss_cnt:
        bad.append(f"anchor '{aid}' is admitted but rule '{r}' has no false-positive count in coverage/{aid}.yml")

print(f"{'anchor':<24}{'admission':<16}{'entry':<7}{'fixtures':<10}{'coverage':<10}{'counts':<8}rules")
for r in sorted(rows):
    print(r)
print(f"\ngrandfathered: {len(exempt)} of {len(anchors)} — {', '.join(sorted(exempt)) or 'none'}")
print("This count only shrinks. An anchor leaves the list by earning all four artifacts.")

if bad:
    print()
    for b in bad:
        print(f"FAIL {b}")
    sys.exit(1)
print("\nEvery admitted anchor carries its four artifacts.")
PY
