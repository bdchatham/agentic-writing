#!/usr/bin/env bash
# End-to-end test of the consumer path.
#
# Two links carried every consumer and neither had ever run:
#
#   scripts/install.sh repo        writes the config, the workflow and the rules
#   writing-contract.yml           the reusable workflow their CI calls
#
# Everything this repository verifies about itself goes through .github/workflows
# /vale.yml, which is a different file that installs rules differently. Green
# there said nothing about either link.
#
# This builds a scratch repository from evals/consumer/tree, installs into it,
# asserts what the installer claims it wrote, then runs the same setup script the
# reusable workflow runs and compares the lint output against a golden file.
#
# NOT COVERED, and worth saying: the vale-action step, reviewdog's reporting, and
# the cross-repository checkout that fetches the rules. Those need real GitHub.
set -uo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ref="${GITHUB_SHA:-$(git -C "$root" rev-parse HEAD)}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fail=0

note() { printf '  %s\n' "$1"; }
check() {  # check <description> <expected> <actual>
  if [ "$2" = "$3" ]; then
    note "ok   $1"
  else
    note "FAIL $1"
    note "       expected: $2"
    note "       actual:   $3"
    fail=1
  fi
}

cp -R "$root/evals/consumer/tree/." "$work/"
git -C "$work" init -q .

# CD FIRST. install.sh resolves the repository from the working directory, which
# is correct, so running it from anywhere else installs into that repository
# instead. The first draft of this test did exactly that and wrote a consumer
# workflow into agentic-writing. The installer now refuses that case; this stays
# because a test should not depend on the guard it is meant to leave alone.
cd "$work"
[ "$(git rev-parse --show-toplevel)" = "$(cd "$work" && pwd -P)" ] || {
  echo "refusing to install: the working directory is not the scratch repository" >&2
  exit 1; }

AGENTIC_WRITING_HOME="$root" AGENTIC_WRITING_REPO="$root" AGENTIC_WRITING_REF="$ref" \
  "$root/scripts/install.sh" repo >install.log 2>&1 || {
    echo "install.sh repo failed:"; sed 's/^/    /' install.log; exit 1; }

for f in .vale.ini .github/workflows/writing.yml .gitignore .vale/vocab/accept.txt; do
  [ -f "$f" ] && note "ok   wrote $f" || { note "FAIL did not write $f"; fail=1; }
done

# The pin is the whole update story. A workflow pinned to a ref that is not the
# one the rules came from fetches a different set on the consumer's next run.
check "workflow pins the installed ref" \
  "uses: bdchatham/agentic-writing/.github/workflows/writing-contract.yml@$ref" \
  "$(grep -o 'uses: bdchatham/agentic-writing/.github/workflows/writing-contract.yml@.*' .github/workflows/writing.yml)"
check "config records the same ref" "$ref" \
  "$(grep -o 'pinned to: .*' .vale.ini | sed 's/pinned to: //')"
check "fetched rules are gitignored" "yes" \
  "$(grep -qxF '.vale/styles/' .gitignore && echo yes || echo no)"

# From here the script mirrors what the reusable workflow does, by calling the
# same script it calls.
mkdir -p .vale/src && cp -R "$root/styles" .vale/src/ && cp -R "$root/scripts" .vale/src/
files="$(./.vale/src/scripts/consumer-lint-setup.sh .vale/src 2>/dev/null)"
check "path selection skips what does not exist" '["README.md","docs","specs"]' "$files"

actual="$(vale --no-global --no-exit --output=line --glob='!.vale/**' \
          README.md docs specs 2>&1 | sort)"
expected="$(cat "$root/evals/consumer/expected.txt")"
if [ "$actual" = "$expected" ]; then
  note "ok   lint output matches the golden"
else
  note "FAIL lint output differs from evals/consumer/expected.txt"
  diff <(printf '%s\n' "$expected") <(printf '%s\n' "$actual") | sed 's/^/       /'
  fail=1
fi

[ "$fail" -eq 0 ] && note "The consumer path works: install, configure, fetch, lint."
exit "$fail"
