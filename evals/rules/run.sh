#!/usr/bin/env bash
# Per-rule golden-file harness.
#
# Each directory under evals/rules/ isolates one rule: its own .vale.ini naming
# only that rule, a test.md carrying both conforming and non-conforming input,
# and expected.txt holding the exact output.
#
# Golden files beat "did rule X fire". They pin the line, the column and the
# message, so a rule that starts reporting the wrong span, or a message someone
# edited without thinking, fails the run.
#
# --no-global is not optional. Vale loads the user's global configuration IN
# ADDITION to a local one, so without it a machine with the toolkit installed
# gets extra findings and the golden file never matches.
set -uo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
fail=0

for dir in "$root"/evals/rules/*/; do
  [ -f "${dir}test.md" ] || continue
  name="$(basename "$dir")"
  actual="$(cd "$dir" && vale --no-global --no-exit --output=line . 2>&1 | sort)"
  expected="$(cat "${dir}expected.txt" 2>/dev/null || true)"

  if [ "$actual" = "$expected" ]; then
    echo "ok   $name"
  else
    echo "FAIL $name"
    diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") | sed 's/^/       /'
    fail=1
  fi
done

[ "$fail" -eq 0 ] && echo "All rule fixtures match their golden files."
exit "$fail"
