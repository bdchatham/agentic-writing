#!/usr/bin/env bash
# No artifact in this repository may cite a private skill or agent as an authority.
#
# This repository is public. A citation a reader cannot follow is not a citation, and
# a rule that lives behind a private name has not actually been stated. The rule is in
# the Governance section of .specify/memory/constitution.md.
#
# A file that must name a private resource — a migration map, for instance — opts out
# with a single line anywhere in it:
#
#     <!-- cites-private: why this file names them -->
#
# Extend PRIVATE when a new private resource appears. A denylist is the honest shape
# here: the check knows what is private, not what is allowed.
set -euo pipefail

PRIVATE='brandon-code|brandon-voice|idiomatic-reviewer|prose-steward|kubernetes-specialist'
PRIVATE="$PRIVATE|platform-engineer|sei-network-specialist|solidity-developer|systems-engineer"
PRIVATE="$PRIVATE|sre-engineer|security-specialist|observability-platform-engineer"
PRIVATE="$PRIVATE|opentelemetry-expert|k8s-capacity-management|platform-release-manager"
PRIVATE="$PRIVATE|harbor-dev|gov-ops|validate-release|validator-platform|chaos-suite"
PRIVATE="$PRIVATE|xreview|root-cause|audit-skill|author-skill|pr-quality"

TARGETS=(README.md NOTICE.md AGENTS.md CLAUDE.md docs anchors specs .specify/memory)
fail=0

for t in "${TARGETS[@]}"; do
  [ -e "$t" ] || continue
  while IFS= read -r f; do
    if grep -q '<!-- cites-private:' "$f"; then
      reason="$(grep -m1 -o '<!-- cites-private:.*-->' "$f")"
      echo "SKIP $f  $reason"
      continue
    fi
    if grep -nIE "(^|[^A-Za-z0-9/-])/?($PRIVATE)([^A-Za-z0-9-]|$)" "$f" >/dev/null 2>&1; then
      echo "PRIVATE CITATION in $f:"
      grep -nIE "(^|[^A-Za-z0-9/-])/?($PRIVATE)([^A-Za-z0-9-]|$)" "$f" | sed 's/^/    /'
      fail=1
    fi
  done < <(find "$t" -type f \( -name '*.md' -o -name '*.yaml' \) 2>/dev/null)
done

[ "$fail" -eq 0 ] && echo "No private citations. Every authority named here is one a reader can follow."
exit "$fail"
