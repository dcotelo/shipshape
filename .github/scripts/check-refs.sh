#!/usr/bin/env bash
# Verify that every path AGENTS.md tells an agent to read actually exists,
# so prompt/tree drift fails CI instead of failing an agent run.
set -euo pipefail

fail=0

for p in AGENTS.md standard.yml; do
  if [ ! -f "$p" ]; then
    echo "missing: $p (referenced by AGENTS.md)"
    fail=1
  fi
done

stack_count=0
for f in stacks/*.yml; do
  [ -f "$f" ] && stack_count=$((stack_count + 1))
done
if [ "$stack_count" -eq 0 ]; then
  echo "stacks/ contains no *.yml files, but AGENTS.md references stacks/*.yml"
  fail=1
fi

exit "$fail"
