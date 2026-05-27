# Capability discovery — Stage 0 reference

Structural guide for Stage 0 of `/process-designer`. Names the harness-fact categories to fetch, the source preference, and the output-file shape.

The first line of the produced file (`.claude/agent-capabilities.md`) is `last-fetched: YYYY-MM-DD`. The freshness check (`scripts/check-capability-freshness.sh`) reads this line and exits 0 if within seven days, 1 otherwise.

---

## Categories to fetch

The reference file covers, at minimum:

### 1. SKILL.md format

- Required and optional frontmatter fields. (Currently: only `description` is recommended; `name` defaults to the directory name. Optional: `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, `shell`.)
- Valid `allowed-tools` values (accepts space- or comma-separated string, or YAML list).
- Skill location precedence: enterprise > personal > project > plugin.
- Description-character cap on the combined `description` + `when_to_use` (currently 1,536).
- Progressive-disclosure conventions (`scripts/`, `references/`, sub-directories).
- Body length recommendation: under 500 lines; move deep material to supporting files.

### 2. AskUserQuestion schema

- `questions` array: 1–4 items per call.
- Per-question fields: `question`, `header` (length cap, currently 12 chars), `options`, `multiSelect`.
- Per-option fields: `label`, `description`, optional `preview` (markdown; multi-line allowed; single-select only).
- **Options array cap: 2–4 items.** Anchor design depends on this.
- `AskUserQuestion` is **not available inside subagents**.

### 3. Hook events

- Current event names — include `PreToolUse`, `PostToolUse`, `SessionStart`, `SessionEnd`, `Stop`, `SubagentStart`, `SubagentStop`, `UserPromptSubmit`, `PreCompact`, `PostCompact`, `Setup`, `PermissionRequest`, `PermissionDenied`, plus newer ones surfaced in docs.
- Stdin JSON shape per event: common fields (`session_id`, `transcript_path`, `cwd`, `hook_event_name`, `permission_mode`); tool events add `tool_name` and `tool_input`. See §3a for the per-tool `tool_input` shape.
- Exit-code semantics: 0 = success; 2 = blocking (per-event behavior — blocks the tool call for `PreToolUse`, denies permission for `PermissionRequest`, etc.); other non-zero = non-blocking error (shown in transcript; execution continues).
- Matcher syntax: exact string; `|`-separated list; JavaScript regex (when the matcher contains any character other than letters, digits, `_`, or `|`).
- Handler types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.
- Path placeholders: `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_SKILL_DIR}`.

### 3a. `tool_input` JSON shape per tool

Hooks that target specific tools (`Write`, `Edit`, `Bash`, `WebFetch`, etc.) need the per-tool stdin shape. These are not always documented on the hooks page itself — fetch each tool's reference if missing. The shape stays stable per tool; the *set* of tools changes as the harness adds capabilities.

| Tool | `tool_input` fields |
| --- | --- |
| `Bash` | `command`, `description` (optional), `timeout` (optional, ms), `run_in_background` (optional) |
| `Write` | `file_path` (absolute), `content` |
| `Edit` | `file_path` (absolute), `old_string`, `new_string`, `replace_all` (optional) |
| `Read` | `file_path` (absolute), `offset` (optional), `limit` (optional) |
| `WebFetch` | `url`, `prompt` |
| `WebSearch` | `query`, `allowed_domains` (optional), `blocked_domains` (optional) |
| `Glob` | `pattern`, `path` (optional) |
| `Grep` | `pattern`, `path` (optional), `output_mode`, plus others |
| `AskUserQuestion` | `questions` (array of 1–4 question objects, each with `question` / `header` / `options` / `multiSelect`) |

A `PreToolUse` hook for `Write` or `Edit` reads the proposed file at `.tool_input.file_path`. A `PreToolUse` hook for `WebFetch` reads the target at `.tool_input.url`. Do not assume `.tool_input.command` exists outside of `Bash`.

### 4. `.claude/settings.json` shape

- Top-level keys (subset most relevant here): `hooks`, `permissions`, `env`, `skillOverrides`, `agent`, `model`.
- Permission model: `permissions.allow` / `permissions.ask` / `permissions.deny`. Evaluation order: deny > ask > allow. Arrays merge across scopes; deny always wins globally.
- Hook declaration shape (current):

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

- Scope precedence (highest → lowest): Managed → CLI args → Local (`.claude/settings.local.json`) → Project (`.claude/settings.json`) → User (`~/.claude/settings.json`).

### 5. Sub-agents

- Built-in: `Explore` (Haiku, read-only), `Plan` (read-only, used in plan mode), `general-purpose` (all tools).
- Custom subagent location: `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (user). Frontmatter requires `name`, `description`; optional `tools`, `disallowedTools`, `model`, `permissionMode`, `skills`, `hooks`, etc.
- Invocation: the Agent tool (renamed from Task in v2.1.63). Subagents cannot spawn further subagents.
- A skill can run inside a subagent via `context: fork` and `agent: <type>` frontmatter; in that mode, the skill body becomes the subagent's prompt.

### 6. File locations and precedence

- Skills: `~/.claude/skills/<name>/SKILL.md` (personal), `.claude/skills/<name>/SKILL.md` (project), `<plugin>/skills/<name>/SKILL.md` (plugin), managed location for enterprise.
- Settings: `.claude/settings.json` (project), `~/.claude/settings.json` (user), `.claude/settings.local.json` (personal, gitignored).
- Agents: `.claude/agents/<name>.md`, `~/.claude/agents/<name>.md`.
- Hooks: scripts referenced from settings; typically stored under `.claude/hooks/`.

---

## Source preference

1. Official Claude Code docs: `https://code.claude.com/docs/en/...` (the host moved from `docs.claude.com` to `code.claude.com`; old URLs redirect).
2. Anthropic engineering blog at `https://www.anthropic.com/news/...` for narrative context.
3. Recent practitioner write-ups only when corroborated by current docs.

Do not pull from posts older than six months without explicit cross-reference to current docs.

---

## Output file shape

The synthesised `.claude/agent-capabilities.md` should look like:

```markdown
# Agent capabilities — Claude Code <version-if-known>

last-fetched: YYYY-MM-DD
fetched-by: process-designer Stage 0
sources:
  - https://code.claude.com/docs/en/skills
  - https://code.claude.com/docs/en/hooks
  - https://code.claude.com/docs/en/settings
  - https://code.claude.com/docs/en/sub-agents

## SKILL.md format
...

## AskUserQuestion schema
...

## Hook events
...

## .claude/settings.json shape
...

## Sub-agents
...

## File locations and precedence
...

## What could not be verified
- (list items the fetch did not resolve cleanly)

## Notes for future re-fetches
- (what changed since the last refresh)
- (sources that were authoritative; sources that were stale)
```

---

## Search budget

Full Stage 0 typically takes 4–6 web requests. If budget is tight, prioritise:

1. SKILL.md format and `AskUserQuestion` (used by every synthesis step).
2. Hook events (load-bearing for any safety floor).
3. Settings (wraps hooks; permissions structure).
4. Sub-agents (only critical if Parallelism ≥ 3).
5. File locations (defer if needed).
