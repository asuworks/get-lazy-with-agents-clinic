#!/usr/bin/env bash
# Exit 0 if .claude/agent-capabilities.md exists AND its `last-fetched:` date is within the last 7 days.
# Exit 1 otherwise (stale, missing, or unparseable).
#
# The skill calls this before Stage 0's web fetches so the agent does not reason about ISO dates inline.

set -uo pipefail

CAPS="${CLAUDE_PROJECT_DIR:-.}/.claude/agent-capabilities.md"

if [ ! -f "$CAPS" ]; then
  echo "stale: $CAPS not found" >&2
  exit 1
fi

FETCHED=$(grep -m1 '^last-fetched:' "$CAPS" | sed -E 's/^last-fetched:[[:space:]]+//')

if [ -z "$FETCHED" ]; then
  echo "stale: no last-fetched line in $CAPS" >&2
  exit 1
fi

# Parse the date. GNU date and BSD date use different flags; try both.
if FETCHED_SEC=$(date -d "$FETCHED" +%s 2>/dev/null); then
  :
elif FETCHED_SEC=$(date -j -f "%Y-%m-%d" "$FETCHED" +%s 2>/dev/null); then
  :
else
  echo "stale: cannot parse last-fetched date: $FETCHED" >&2
  exit 1
fi

NOW_SEC=$(date +%s)
DELTA_DAYS=$(( (NOW_SEC - FETCHED_SEC) / 86400 ))

if [ "$DELTA_DAYS" -gt 7 ]; then
  echo "stale: last-fetched is $DELTA_DAYS days ago" >&2
  exit 1
fi

exit 0
