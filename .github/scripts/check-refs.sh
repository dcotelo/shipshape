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

# The skill is a launcher into the files above; verify its relative paths resolve
# from the skill directory, since installs symlink that directory elsewhere.
skill_dir="skills/shipshape"
if [ ! -f "$skill_dir/SKILL.md" ]; then
  echo "missing: $skill_dir/SKILL.md"
  fail=1
else
  for rel in ../../AGENTS.md ../../standard.yml; do
    if [ ! -f "$skill_dir/$rel" ]; then
      echo "skill reference broken: $skill_dir/$rel does not resolve"
      fail=1
    fi
  done
fi

exit "$fail"
