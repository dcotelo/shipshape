#!/usr/bin/env bash
# Verify that every path the agent manuals tell an agent to read actually
# exists, so prompt/tree drift fails CI instead of failing an agent run.
#
# Two layers:
#   1. Fixed anchors: the files the manuals are built around.
#   2. Extracted references: every repo-relative path named in backticks or
#      markdown links inside AGENTS.md and the skill launcher must exist.
#      Zero extracted paths from AGENTS.md is itself a failure — either the
#      extractor broke or the prompt was emptied.
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

# Pull candidate repo-relative paths out of a markdown manual.
# Considers backtick spans and markdown link targets ([text](path), [`text`](path)).
# Keeps: file paths ending in .md/.yml/.yaml/.sh/.json, and directory refs ending
# in "/". Drops URLs, mailto:, anchors, globs, and anything with characters outside
# [A-Za-z0-9._/-]. Output is one candidate per line, de-duplicated.
tick="$(printf '\140')"
extract_paths() {
  local manual="$1"
  {
    # backtick spans: `path`
    # (|| true: a manual with no spans of one kind must not abort the other)
    grep -o "${tick}[^${tick}]*${tick}" "$manual" | sed "s/^${tick}//; s/${tick}\$//" || true
    # link targets: [text](path) — the target only
    grep -o '\]([^)]*)' "$manual" | sed 's/^](//; s/)$//' || true
  } |
    grep -v -E '^(https?://|mailto:|#)' |
    grep -v -F '*' |
    grep -E '^[A-Za-z0-9._-][A-Za-z0-9._/-]*(\.(md|yml|yaml|sh|json)|/)$' |
    sort -u
}

# Files the manual tells the agent to WRITE during a run, not read from this
# tree. They are skipped, not resolved. Keep this list short and explained.
generated_outputs="ruleset.json"

# Does the candidate resolve from any of the given base directories?
# A trailing "/" means a directory reference; anything else must be a file.
resolves() {
  local candidate="$1"
  shift
  local base
  for base in "$@"; do
    case "$candidate" in
      */) [ -d "$base/$candidate" ] && return 0 ;;
      *)  [ -f "$base/$candidate" ] && return 0 ;;
    esac
  done
  return 1
}

# Check every extracted path in a manual. Sets manual_count to the number of
# candidates seen so the caller can fail closed on zero.
manual_count=0
check_manual() {
  local manual="$1"
  shift
  local candidate
  manual_count=0
  while IFS= read -r candidate; do
    [ -n "$candidate" ] || continue
    case " $generated_outputs " in
      *" $candidate "*) continue ;;
    esac
    manual_count=$((manual_count + 1))
    if ! resolves "$candidate" "$@"; then
      echo "missing path referenced by $manual: $candidate"
      fail=1
    fi
  done < <(extract_paths "$manual")
}

if [ -f AGENTS.md ]; then
  check_manual AGENTS.md .
  if [ "$manual_count" -eq 0 ]; then
    echo "AGENTS.md names no local paths; extractor broken or prompt emptied"
    fail=1
  fi
fi

# The launcher writes paths relative to its own directory (../../AGENTS.md) and
# also names root files bare in its table; accept either resolution.
if [ -f "$skill_dir/SKILL.md" ]; then
  check_manual "$skill_dir/SKILL.md" "$skill_dir" .
fi

exit "$fail"
