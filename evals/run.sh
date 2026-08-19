#!/usr/bin/env bash
# Rule regression test: does each rule still find what it must find?
# A rule that stops firing is a silent failure, and silent failures are the reason
# a prompt-only approach cannot be trusted.
set -euo pipefail

command -v vale >/dev/null || { echo "vale not on PATH: https://vale.sh/docs"; exit 2; }
command -v jq   >/dev/null || { echo "jq not on PATH"; exit 2; }

fail=0
for fixture in evals/fixtures/*.md; do
  base="$(basename "${fixture%.md}")"
  expected="evals/expected/${base}.json"
  [ -f "$expected" ] || { echo "no expectation for ${fixture}"; fail=1; continue; }

  found="$(vale --output=JSON "$fixture" || true)"
  rules="$(echo "$found" | jq -r '.[][] | .Check' | sort -u)"
  count="$(echo "$found" | jq '[.[][]] | length')"

  while read -r want; do
    [ -z "$want" ] && continue
    if ! echo "$rules" | grep -qx "$want"; then
      echo "MISS ${base}: expected rule ${want} did not fire"
      fail=1
    fi
  done < <(jq -r '.must_include_rules[]' "$expected")

  min="$(jq -r '.min_findings' "$expected")"
  if [ "$count" -lt "$min" ]; then
    echo "LOW  ${base}: ${count} findings, expected at least ${min}"
    fail=1
  fi
done

[ "$fail" -eq 0 ] && echo "All fixture expectations met."
exit "$fail"
