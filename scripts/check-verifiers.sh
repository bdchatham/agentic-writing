#!/usr/bin/env bash
# Every success criterion names a verifier that exists, or says plainly that it does not.
#
# THREE OF THE SEVEN CITED SOMETHING THAT DOES NOT RUN. SC-002 named "the registry
# consistency job", which reads the registry and never the contract. SC-003 named "the
# probe suite", which was never written. SC-005 and SC-006 named "a line-count check in
# CI" that no workflow contained. A criterion with a verifier nobody built reads exactly
# like one with a verifier that passes, which is the failure this repository exists to
# stop.
#
# A verifier line takes one of three shapes:
#
#   *Verifier:* `scripts/check-coverage.sh`
#   *Verifier:* judgement — a reviewer attempts it on three findings and reports.
#   *Verifier:* not built — the recognition suite does not exist yet.
#
# The first must name a path that exists. The other two must give a reason, because
# "not built" with no explanation is a shrug rather than a statement.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 - "$ROOT" <<'PY'
import pathlib, re, sys

root = pathlib.Path(sys.argv[1])
specs = sorted(root.glob('specs/*/spec.md'))
if not specs:
    print(f"FAIL no specs under {root}/specs — refusing to report success on an empty set")
    sys.exit(1)

PATHISH = re.compile(r'(?:[\w.-]+/)+[\w.-]*|[\w.-]+\.(?:sh|py|yml|yaml|md|ini|txt)')
COMMANDS = {'vale'}          # a tool the repository already requires on PATH
bad, rows = [], []

for spec in specs:
    lines = spec.read_text().splitlines()
    rel = spec.relative_to(root)
    criteria = [(i, l) for i, l in enumerate(lines) if re.match(r'^\*\*SC-\d+\*\*', l)]
    if not criteria:
        bad.append(f"{rel}: no success criteria found — the file names none, or the shape changed")
        continue

    for idx, (i, head) in enumerate(criteria):
        sc = re.match(r'^\*\*(SC-\d+)\*\*', head).group(1)
        end = criteria[idx + 1][0] if idx + 1 < len(criteria) else len(lines)
        vlines = [l for l in lines[i:end] if l.startswith('*Verifier:*')]
        if len(vlines) != 1:
            bad.append(f"{rel} {sc}: has {len(vlines)} verifier lines, expected exactly one")
            continue

        body = vlines[0][len('*Verifier:*'):].strip()
        marker = re.match(r'^(not built|judgement)\s+—\s+(.+)$', body)
        if marker:
            if len(marker.group(2)) < 15:
                bad.append(f"{rel} {sc}: '{marker.group(1)}' with no reason. Say what is missing, "
                           f"or who applies the judgement and how")
            rows.append(f"  {sc:<10}{marker.group(1):<12}{marker.group(2)[:56]}")
            continue

        spans = re.findall(r'`([^`]+)`', body)
        if not spans:
            bad.append(f"{rel} {sc}: names '{body}' as its verifier, which is prose, not a command. "
                       f"Name a path in backticks, or mark it 'not built — <reason>' or "
                       f"'judgement — <how>'")
            continue

        targets = [m for s in spans for m in PATHISH.findall(s)]
        if not targets:
            bad.append(f"{rel} {sc}: the backticks hold '{' '.join(spans)}', which names no path. "
                       f"A verifier is something a reader can run")
            continue
        for tgt in targets:
            first = spans[0].split()[0] if spans[0].split() else ''
            if tgt == first and first in COMMANDS:
                continue
            if not (root / tgt.rstrip('/')).exists():
                bad.append(f"{rel} {sc}: names '{tgt}', which does not exist")
        rows.append(f"  {sc:<10}{'runs':<12}{' '.join(spans)[:56]}")

print(f"  {"criterion":<10}{"kind":<12}verifier")
for r in rows:
    print(r)

if bad:
    print()
    for b in bad:
        print(f"FAIL {b}")
    sys.exit(1)
print("\nEvery success criterion names a verifier that runs, or says why none does.")
PY
