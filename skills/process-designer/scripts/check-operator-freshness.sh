#!/usr/bin/env bash
# Exit 0 if .claude/operator-profile.md exists AND its `last-confirmed:` date is within the last 30 days.
# Exit 1 otherwise (stale, missing, or unparseable).
#
# The skill calls this before Stage 1's profile questions so the agent does not reason about ISO dates inline.

set -uo pipefail

PROFILE="${CLAUDE_PROJECT_DIR:-.}/.claude/operator-profile.md"

if [ ! -f "$PROFILE" ]; then
  echo "stale: $PROFILE not found" >&2
  exit 1
fi

CONFIRMED=$(grep -m1 '^last-confirmed:' "$PROFILE" | sed -E 's/^last-confirmed:[[:space:]]+//')

if [ -z "$CONFIRMED" ]; then
  echo "stale: no last-confirmed line in $PROFILE" >&2
  exit 1
fi

# Parse the date. GNU date and BSD date use different flags; try both.
if CONFIRMED_SEC=$(date -d "$CONFIRMED" +%s 2>/dev/null); then
  :
elif CONFIRMED_SEC=$(date -j -f "%Y-%m-%d" "$CONFIRMED" +%s 2>/dev/null); then
  :
else
  echo "stale: cannot parse last-confirmed date: $CONFIRMED" >&2
  exit 1
fi

NOW_SEC=$(date +%s)
DELTA_DAYS=$(( (NOW_SEC - CONFIRMED_SEC) / 86400 ))

if [ "$DELTA_DAYS" -gt 30 ]; then
  echo "stale: last-confirmed is $DELTA_DAYS days ago" >&2
  exit 1
fi

exit 0
