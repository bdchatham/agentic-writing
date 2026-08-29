#!/usr/bin/env bash
# No artifact in this repository may cite a private skill or agent as an authority.
#
# This repository is public. A citation a reader cannot follow is not a citation, and
# a rule that lives behind a private name has not actually been stated. The rule is in
# the Governance section of .specify/memory/constitution.md.
#
# THE SCAN COVERS EVERY TRACKED FILE. It used to cover eight paths and two extensions,
# which left the rule files themselves out: they are .yml, and the pattern read .yaml.
# A denylist that skips most of the repository is a denylist in name only.
#
# A file that must name a private resource — a migration map, for instance — opts out
# with a line of its own:
#
#     <!-- cites-private: why this file names them -->
#
# THE MARKER MUST START THE LINE. Any occurrence anywhere used to count, so this
# script exempted itself by accident: it quotes the marker to search for it. The
# denylist below is still a citation, so the script is skipped here by name.
#
# Extend PRIVATE when a new private resource appears. A denylist is the honest shape
# here: the check knows what is private, not what is allowed.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PRIVATE='brandon-code|brandon-voice|idiomatic-reviewer|prose-steward|kubernetes-specialist'
PRIVATE="$PRIVATE|platform-engineer|sei-network-specialist|solidity-developer|systems-engineer"
PRIVATE="$PRIVATE|sre-engineer|security-specialist|observability-platform-engineer"
PRIVATE="$PRIVATE|opentelemetry-expert|k8s-capacity-management|platform-release-manager"
PRIVATE="$PRIVATE|harbor-dev|gov-ops|validate-release|validator-platform|chaos-suite"
PRIVATE="$PRIVATE|xreview|root-cause|audit-skill|author-skill|pr-quality"

SELF='scripts/check-no-private-citations.sh'   # holds the denylist itself
CITE="(^|[^A-Za-z0-9/-])/?($PRIVATE)([^A-Za-z0-9-]|$)"
fail=0 scanned=0

if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  files() { git -C "$ROOT" ls-files -z; }
else
  files() { find . -type f -not -path './.git/*' -print0; }
fi

while IFS= read -r -d '' f; do
  [ -f "$f" ] || continue
  scanned=$((scanned + 1))
  [ "$f" = "$SELF" ] && continue
  if grep -qE '^[[:space:]]*<!-- cites-private:' "$f" 2>/dev/null; then
    echo "SKIP $f  $(grep -m1 -oE '<!-- cites-private:.*-->' "$f")"
    continue
  fi
  if grep -nIE "$CITE" "$f" >/dev/null 2>&1; then
    echo "PRIVATE CITATION in $f:"
    grep -nIE "$CITE" "$f" | sed 's/^/    /'
    fail=1
  fi
done < <(files)

if [ "$fail" -eq 0 ]; then
  echo "No private citations in $scanned tracked files. Every authority named here is one a reader can follow."
fi
exit "$fail"
