# Hook config template — structural guidance

The hook config is three pieces under `process-designer-output/hooks/`:

1. `settings-snippet.json` — declarations the reader merges into `.claude/settings.json`.
2. `<hook-name>.sh` — one shell script per blocked pattern.
3. `README.md` — what each hook blocks, why, false-positive notes, install steps.

**Source the hook event names, matcher syntax, stdin JSON shape, and exit-code semantics from `.claude/agent-capabilities.md` §Hook events** — not from memory. Hooks are the category most exposed to harness churn.

---

## Coverage scales with Reversibility

| Reversibility | Hooks |
| --- | --- |
| 1 | None. Engineering cost > cost-on-failure. Produce only the `README.md` explaining why none was recommended. |
| 2 | 1–2 hooks against common painful failures — broken commits to shared branches, writes outside the project. |
| 3 | 2–3 hooks covering the reader's named irreversibility classes plus the canonical set (`rm -rf`, force-push). |
| 4 | Full coverage — every named class plus production guards (deploy commands, external API calls, financial operations). |

Cross-reference the reader's Stage-1 use case for *named* irreversibility classes (*"I deploy with `terraform apply`"* → wrap `terraform apply` in a hook).

---

## Hook script shape

Each script reads JSON from stdin, exits 2 to block:

```bash
#!/usr/bin/env bash
# Hook: <hook-name>
# Blocks: <one-sentence description and why>
# Risk class: <e.g., irreversible-filesystem, production-deploy, external-communication>

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

if echo "$COMMAND" | grep -qE '<pattern>'; then
  echo "BLOCKED by <hook-name>: <reader-facing reason>" >&2
  echo "If this block is wrong, audit the pattern in .claude/hooks/<hook-name>.sh" >&2
  exit 2
fi

exit 0
```

**Exit 2 blocks the tool call.** Exit 1 is treated as a non-blocking error — do not use it for a safety floor.

The command path inside `tool_input` is harness-version-dependent. Pull the current path from `agent-capabilities.md` §Hook events (currently `.tool_input.command` for Bash).

---

## Match patterns are specific or they're noise

Per hook, specify:

- Three concrete attack vectors or failure modes the pattern catches.
- Two legitimate operations the pattern *might* false-positive on. Tune the regex to exclude them, or accept the trade.
- A test fixture — three matching cases, three non-matching — at the bottom of the script, commented out, runnable by the reader with a small wrapper.

A pattern that catches everything (`.*`) is useless. A pattern that catches nothing is decoration.

---

## settings-snippet.json shape

Pull the current shape from `agent-capabilities.md` §Settings. Currently:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/<hook-name>.sh" }
        ]
      }
    ]
  }
}
```

`matcher` accepts exact tool name, `|`-separated tool list, or JavaScript regex (when the matcher contains any non-`[a-zA-Z0-9_|]` character). The path placeholder `${CLAUDE_PROJECT_DIR}` resolves at runtime.

One `PreToolUse` entry per hook. Other events (`UserPromptSubmit`, `Stop`, etc.) follow the same shape but use that event's stdin schema and matcher targets — re-check `agent-capabilities.md` if proposing a non-`PreToolUse` hook.

---

## Reject messages match the reader's register

A hook that fires shows its message on stderr. A message reading *"irreversibility class 4 violation"* to a reader whose use case is in plain language gets the hook disabled. Mirror the reader's free-text register in the reject text.

---

## hooks/README.md content

`process-designer-output/hooks/README.md` contains:

- One-paragraph framing: hooks sit above the loop; here is what each does and why.
- Table: hook name → risk class → what it blocks → false-positive notes.
- Install steps:
  1. Copy each `.sh` to `.claude/hooks/<hook-name>.sh`.
  2. `chmod +x` the scripts.
  3. Merge `settings-snippet.json` into `.claude/settings.json`.
  4. Test each hook with a deliberate trigger before relying on it.
