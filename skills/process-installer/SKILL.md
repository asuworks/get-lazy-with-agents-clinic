---
name: process-installer
description: Installs a process specification produced by /process-designer into the current project. Reads process-designer-output/manifest.json, surveys destination conflicts, copies artifacts, scaffolds runtime files and directories, and verifies the install. Use after /process-designer finishes, or any time the staged output needs to be (re)installed. Triggers on "install the process," "install process-designer-output," "install /process-designer's output," "install the staged process," or invocation as /process-installer.
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash
---

# process-installer

The companion skill to `/process-designer`. Reads the manifest produced by the design phase and installs the synthesised artifacts into the reader's project, with conflict survey, executable scaffolding, and a verification pass.

**Phase B scope** — project-local install only. Skills install with `disable-model-invocation: true` until their gaps are filled. Hybrid and user-global scopes belong to a later phase; interactive gap-walking belongs to a later phase; repeat-install detection and `uninstall.sh` generation belong to a later phase.

## What this skill produces

Under the working directory:

- `./CLAUDE.md` — copied from `process-designer-output/CLAUDE.md` **only if no existing `CLAUDE.md` is present**. Existing `CLAUDE.md` is preserved; the staged copy stays in `process-designer-output/` for manual merge.
- `.claude/skills/<name>/` — each sketch from the manifest, with `disable-model-invocation: true` injected into its frontmatter.
- `.claude/hooks/<name>.sh` — each hook from the manifest, with execute permission set.
- `.claude/settings.json` — merged (or created) to include the hook declarations from `settings-snippet.json`.
- `./evals/eval-set.md` — copied.
- Runtime scaffolding directories and files from the manifest's `runtime_paths` list. Existing files are not overwritten.
- `./INSTALL_LOG.md` — record of every action taken, with ISO timestamps. The operator's reversal trail until a future `/unprocess-installer` skill ships.

## The eight-stage flow

Run in order. Stage 2 calibrates the rest; stages 3–4 are operator-confirmed; stages 5–7 execute and verify.

### Stage 1 — Locate the staged output

Default location: `./process-designer-output/`. If not present in the current working directory, ask the operator for the path via `AskUserQuestion` (calibration is not yet loaded, so use neutral phrasing for this single question).

Confirm `process-designer-output/manifest.json` exists. If not, abort: `/process-designer` did not finish, or wrote to a non-standard path. Surface the error and stop.

### Stage 2 — Read the manifest and calibrate to the operator profile

Read `process-designer-output/manifest.json`. Confirm `schema_version` is `"1"` (the version this installer supports).

Read `.claude/operator-profile.md` (project-local). The file's `fluency` and `register` calibrate every subsequent `AskUserQuestion` call, every suggestion, and the closing brief — same rules as `/process-designer` applies during its interview.

**Calibration summary** (full taxonomy at the `/process-designer` skill's `references/operator-profile.md`):

- **Fluency** controls live-interaction surfaces.
  - *New* — rephrase question stems in everyday vocabulary; option labels in everyday terms; 2–3 sentence preludes with concrete examples from the install context; surface recommended defaults.
  - *Aware* — 1-sentence framing + 1-sentence example per question; option labels in light gloss.
  - *Practitioner* — 1-sentence framing per question; clinic vocabulary in option labels.
  - *Fluent* — no prelude; clinic vocabulary direct.
- **Register** controls human-facing prose — the closing brief, any error messages, any rationale surfaced to the operator. Mirrors the chosen register (plain / professional / technical / specialist) throughout.

If `.claude/operator-profile.md` is missing, fall back to *Technical + Practitioner* and note the fallback in the closing brief.

### Stage 3 — Show the install plan and ask confirmation

Build the action plan from the manifest. Present a summary table to the operator:

| Artifact | Source (under `process-designer-output/`) | Destination |
| --- | --- | --- |
| `CLAUDE.md` | `CLAUDE.md` | `./CLAUDE.md` (or staged if existing) |
| Skill: `<name>` (×N) | `skills/<name>/` | `./.claude/skills/<name>/` |
| Hook: `<name>` (×N) | `hooks/<name>.sh` | `./.claude/hooks/<name>.sh` |
| Settings snippet | `hooks/settings-snippet.json` | merged into `./.claude/settings.json` |
| Eval set | `evals/eval-set.md` | `./evals/eval-set.md` |
| Runtime paths | (from manifest) | scaffolded under `./` |

Surface the dimension targets from the manifest's `dimensions` block so the operator sees what they're installing without re-reading every file.

Ask via `AskUserQuestion`: *"Proceed with the install?"* Options (phrased per the operator's fluency):

- **Proceed** — run the full install.
- **Cancel** — exit without changes.

If the operator cancels, exit cleanly. No partial install.

### Stage 4 — Conflict survey

For every destination path the installer would write to, check what's already there and propose a strategy:

| Existing | Strategy | Backup written? |
| --- | --- | --- |
| `./CLAUDE.md` | **Preserve existing**; leave staged copy at `process-designer-output/CLAUDE.md` for manual merge | No |
| `.claude/settings.json` | Merge (preserve other keys; append hook entries via `jq`; warn on matcher collisions) | Yes — copy to `.claude/settings.json.bak.<ISO-timestamp>` |
| `.claude/skills/<name>/` | Move to `.claude/skills/<name>.bak.<ISO-timestamp>/`; install fresh | Yes |
| `.claude/hooks/<name>.sh` | Move to `.claude/hooks/<name>.sh.bak.<ISO-timestamp>`; install fresh | Yes |
| `./evals/eval-set.md` | Move to `./evals/eval-set.md.bak.<ISO-timestamp>`; install fresh | Yes |
| Runtime files exist (`NOTES.md`, `voice-fingerprint.md`, etc.) | **Leave alone** — operator state is sacred | No |
| Runtime directories exist (`archive/`, etc.) | **Leave alone** — `mkdir -p` is idempotent | No |

Present the conflict survey via `AskUserQuestion`. If any conflicts exist, ask: *"Proceed with the conflict plan above?"* Options: *Proceed / Cancel*. No per-file overrides in this scope.

If no conflicts, skip the prompt and move to Stage 5.

### Stage 5 — Prepare sketches for install

For each skill in the manifest where `is_sketch: true`, copy the SKILL.md from staging to a working buffer and **inject `disable-model-invocation: true` into the frontmatter** before placement. The injection rule:

- Parse the YAML frontmatter between the leading `---` markers.
- If `disable-model-invocation` is absent, add the line.
- If present and false, update to `true`.
- Leave the rest of the file untouched.

The resulting SKILL.md installs discoverable in the operator's project (via `/skill-name`) but does not auto-fire on description match. The operator removes the flag after the gaps in the sketch's Section 6 are filled.

### Stage 6 — Execute the install

Run each action in order. Append every action to `./INSTALL_LOG.md` as `<ISO-timestamp>  <action>`.

1. Create destination directories (idempotent):
   ```bash
   mkdir -p .claude/skills .claude/hooks evals
   ```
2. Create every directory in `runtime_paths` where `type: "directory"`:
   ```bash
   mkdir -p <path>
   ```
3. Create every file in `runtime_paths` where `type: "file"`. Skip if the file already exists (operator state preserved).
   - If `seed` is `null`: `touch <path>`.
   - If `seed` has content: write via heredoc.
4. Copy `CLAUDE.md` to `./CLAUDE.md` *only if* the destination does not exist.
5. For each skill:
   - Back up `.claude/skills/<name>/` to `<name>.bak.<ISO-timestamp>/` if present.
   - Copy `process-designer-output/skills/<name>/` to `.claude/skills/<name>/`.
   - Inject `disable-model-invocation: true` into the SKILL.md's frontmatter.
6. For each hook:
   - Back up `.claude/hooks/<name>.sh` to `<name>.sh.bak.<ISO-timestamp>` if present.
   - Copy the hook from staging.
   - `chmod +x` the result.
7. Merge `settings-snippet.json` into `.claude/settings.json`:
   - If `.claude/settings.json` does not exist: copy the snippet outright.
   - If it exists: back it up, then `jq -s '.[0] * .[1]' settings.json snippet.json > settings.json.new && mv settings.json.new settings.json`. Inspect the result for collisions in `hooks.PreToolUse`; if the snippet's matchers collide with existing matchers, log a warning. The shallow merge can replace nested arrays; in that case, log explicitly that prior `PreToolUse` entries may need manual restoration from the backup.
   - If `jq` is not available, abort merge: copy the snippet to `.claude/settings.json.new` and ask the operator to merge by hand. Log the deferred action.
8. Copy the eval set to `./evals/eval-set.md`.

Every step's log line includes the source and destination paths so the operator can reverse each line by reading `INSTALL_LOG.md`.

### Stage 7 — Verify and report

Run the verification checks:

1. **Skills discoverable.** For each skill: `.claude/skills/<name>/SKILL.md` exists and its frontmatter contains `disable-model-invocation: true`.
2. **Hooks executable.** For each hook: `test -x .claude/hooks/<name>.sh` succeeds.
3. **Hook fires correctly.** Test fixtures must run from a driver file, not via direct piping (see *"Hook fixture self-test paradox"* below). For each hook with a commented test fixture at the bottom of the script:
   - Assemble all fixtures into `./.verify-install.sh` — a temporary verification driver at the project root. Split destructive literal patterns (`rm -rf`, force-push, recursive deletes) into innocuous tokens assembled at runtime so even file creation does not trip the hooks. Example: `RM=$(printf 'r''m')` then `"${RM} -rf sources/"` inside the JSON payload, instead of writing the literal `rm -rf sources/` into the heredoc.
   - Make the driver executable: `chmod +x ./.verify-install.sh`.
   - Run it: `./.verify-install.sh`. The driver pipes each payload through the relevant hook and reports PASS / FAIL per fixture against the hook's exit code.
   - Log the driver creation in `INSTALL_LOG.md` with a *"safe to delete after baseline"* note.
   - Skip silently if no test fixture is present in any hook.

   **Hook fixture self-test paradox.** Piping fixtures directly through the outer `Bash` tool call — e.g., `echo '{"tool_input":{"command":"rm -rf sources/"}}' | ./.claude/hooks/<name>.sh` — embeds the destructive pattern as a literal string in the outer command. Hooks that scan `Bash` invocations (like the typical `protect-verification`-style hook) will fire on the outer call and block the test. The driver-file pattern bypasses this: the outer `Bash` invocation contains only the filename; the destructive patterns live inside the file, where they are not subject to outer-call scanning. Where the driver-file itself is written via a `Write` or `cat <<EOF` that contains the pattern verbatim, split the pattern into tokens assembled at runtime so the file-creation invocation is also hook-clean. This pattern surfaced on the first real run of `/process-installer`; document it here so the next operator doesn't re-discover it the hard way.
4. **`settings.json` parses.** `jq . .claude/settings.json` exits 0.
5. **`CLAUDE.md` accounted for.** Either present at `./CLAUDE.md` (clean install) or preserved at the previous location with the staged copy still in `process-designer-output/` (conflict path).
6. **Runtime scaffolding present.** Every entry in `runtime_paths` exists at the expected location.
7. **`INSTALL_LOG.md` written.** Every action from Stage 6 has a log entry.

Surface the result via the closing brief — in the operator's register, calibrated to their fluency.

For *new* fluency, the brief is verbose: name what was installed, where, what the operator does next (fill sketch gaps, baseline the eval set), and an explicit pointer to `INSTALL_LOG.md` as the reversal trail.

For *fluent* fluency, the brief is terse: paths and pass/fail of the verification checks.

End with the post-install next-steps:

- *"Each sketch is installed with `disable-model-invocation: true`. Fill the gaps listed in each skill's Section 6, then remove the flag to activate."*
- *"Baseline the eval set in `evals/eval-set.md` before the first real session — record results under `evals/results/`."*
- *"Reversal: every action is logged in `INSTALL_LOG.md`; reverse by reading the log bottom-up."*

### Stage 8 — Optional cleanup of the staging folder

After the closing brief, ask via `AskUserQuestion` whether to clean up the staging folder:

- *"Keep `process-designer-output/`"* — preserves the as-built record. `manifest.json` and `INSTALL.md` remain reachable as install-time documentation; the staged artifact copies are reference snapshots in case the installed versions later drift. **Default.**
- *"Delete `process-designer-output/`"* — staging is redundant after a clean install. Recoverable only by re-running `/process-designer`, which regenerates the staging with fresh content (and a new `generated_at` timestamp).

Default to *keep* for safety. The default is the recommended option — the staging carries genuine documentation value (the manifest is the install contract; `INSTALL.md` is the manual fallback) and the disk cost is negligible.

If the operator picks *delete*, `rm -rf process-designer-output/` and log the action in `INSTALL_LOG.md`. Do not delete without the explicit choice.

This stage is the final step. The skill exits here.

## Quality bar

The install is doing its job well when:

1. The operator-profile calibration applies — `AskUserQuestion` calls and the closing brief read in the operator's register and at their fluency.
2. No existing operator state is clobbered. `CLAUDE.md` preserved; runtime files preserved; `settings.json` merged not replaced; backups taken before overwriting skills or hooks.
3. Every hook script has its executable bit set after install.
4. Every skill sketch's frontmatter contains `disable-model-invocation: true` after install.
5. The verification pass surfaces any miss before the operator runs anything.
6. `INSTALL_LOG.md` records every action; the operator can reverse the install by reading the log.

## Anti-patterns

- **Installing without reading the operator profile.** A *plain*-register operator who survived the design interview should not hit clinic vocabulary at the install step. Calibrate every `AskUserQuestion` call and the closing brief.
- **Overwriting `CLAUDE.md`.** Always preserve the existing file; stage the new one alongside for manual merge.
- **Activating sketches as-is.** A sketch with unfilled gaps that fires automatically wastes the operator's time on flawed runs. Inject `disable-model-invocation: true`.
- **Skipping the executable bit.** A hook script without `+x` does not run; the safety floor is silent. Always `chmod +x`.
- **Piping destructive test fixtures via outer `Bash`.** The hook fires on the outer call and blocks the test, leaving the verification step half-run. Always assemble fixtures into a driver file and execute the file — see Stage 7's *Hook fixture self-test paradox* note.
- **Deleting `process-designer-output/` without asking.** The staging carries documentation value (manifest = install contract; `INSTALL.md` = manual fallback). Stage 8 asks; never delete by default.
- **Silent `settings.json` merges that drop existing hook entries.** The `jq -s '.[0] * .[1]'` shallow-merge replaces nested arrays. Always back up first; always log the collision; always tell the operator if a manual reconciliation may be required.
- **Skipping the verification pass.** The install isn't done until verification confirms the install. `INSTALL_LOG.md` plus the verification report is the closing artifact, not the file copies.
- **Re-running the installer over a prior install without surfacing it.** Phase B does not detect a prior install — a later phase will. For now, the operator's existing state is preserved through the backup discipline; nothing silently clobbers.

## See also

- The companion design skill: [`../process-designer/SKILL.md`](../process-designer/SKILL.md).
- The full operator-profile taxonomy (calibration rules): [`../process-designer/references/operator-profile.md`](../process-designer/references/operator-profile.md).
- The manifest schema: [`../process-designer/references/synthesis-templates/manifest.md`](../process-designer/references/synthesis-templates/manifest.md).
- The manual install path (without this skill): each `process-designer-output/INSTALL.md` is the per-process manual guide.
