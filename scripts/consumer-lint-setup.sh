#!/usr/bin/env bash
# Prepare a consuming repository for a lint run, and say which paths to lint.
#
#   scripts/consumer-lint-setup.sh <fetched-rules-dir> [paths-json]
#
# THE REUSABLE WORKFLOW AND ITS TEST CALL THIS SAME SCRIPT. The logic used to
# live inline in .github/workflows/writing-contract.yml, where nothing could run
# it: that workflow is the one every consumer depends on and the one thing in
# this repository no job had ever invoked. Inline shell in a workflow is
# reachable only by merging and hoping.
#
# It does two things the caller cannot skip:
#
#   1. Installs the fetched styles, then grafts the caller's own accepted terms
#      into config/vocabularies/Local. The copy replaces everything inside the
#      fetched tree, so a vocabulary kept inside it would not survive.
#   2. Chooses the paths. Vale treats a named path that does not exist as a
#      fatal argument error rather than as nothing to lint, and almost no
#      repository has every document directory.
#
# Writes `files=<json>` to $GITHUB_OUTPUT when that is set, and always prints the
# JSON on stdout so a test can read it without GitHub.
set -euo pipefail

SRC="${1:?usage: consumer-lint-setup.sh <fetched-rules-dir> [paths-json]}"
GIVEN="${2:-}"

[ -d "$SRC/styles/AgenticWriting" ] || {
  echo "no styles at $SRC/styles/AgenticWriting — the rules were not fetched" >&2
  exit 1
}

mkdir -p .vale/styles
rm -rf .vale/styles/AgenticWriting .vale/styles/config
cp -R "$SRC/styles/AgenticWriting" .vale/styles/
cp -R "$SRC/styles/config" .vale/styles/

# The caller's own accepted terms, committed outside the fetched tree.
mkdir -p .vale/styles/config/vocabularies/Local
if [ -f .vale/vocab/accept.txt ]; then
  cp .vale/vocab/accept.txt .vale/styles/config/vocabularies/Local/accept.txt
else
  : > .vale/styles/config/vocabularies/Local/accept.txt
fi

# The config declares Packages, and those are not committed anywhere. They are
# gitignored in agentic-writing, so the checkout that fetches the rules does not
# carry them, and a consumer's runner has never run install.sh. Without this,
# Vale stops with "style 'write-good' does not exist on StylesPath" before it
# reads a single document — the whole check fails as a runtime error rather than
# as a finding. The same step exists in this repository's own CI, where the
# comment beside it says exactly this. It was in one workflow and not the other.
if command -v vale >/dev/null 2>&1; then
  vale sync >&2 || {
    echo "vale sync failed; the declared packages are missing" >&2
    exit 1
  }
else
  echo "vale is not on PATH; install it before this script" >&2
  exit 1
fi

if [ -n "$GIVEN" ]; then
  files="$GIVEN"
  echo "Linting the caller's paths: $files" >&2
else
  found=""
  for p in README.md docs specs tickets designs; do
    [ -e "$p" ] || continue
    found="${found:+$found,}\"$p\""
  done
  if [ -z "$found" ]; then
    echo "no document paths found; nothing to lint" >&2
    files=""
  else
    files="[$found]"
    echo "Linting: $files" >&2
  fi
fi

[ -n "${GITHUB_OUTPUT:-}" ] && echo "files=$files" >> "$GITHUB_OUTPUT"
printf '%s\n' "$files"
