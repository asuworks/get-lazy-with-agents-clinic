# `INSTALL.md` template — structural guidance

`process-designer-output/INSTALL.md` is the per-process manual install guide. Written in Stage 2.

A reader without `/process-installer` follows this by hand. A reader with `/process-installer` may still read it to understand what the installer does.

Write fresh prose per invocation — concrete paths and commands for *this* reader, not generic placeholders.

---

## Voice

Same register as the synthesised `CLAUDE.md` (mirrors the reader's free-text use-case paragraph). Numbered steps, copy-pasteable commands, no jargon the reader did not introduce.

---

## Section 1 — Framing (one paragraph)

What this install delivers (the four artifacts + the runtime scaffolding), what the reader needs in their environment (`cp`, `mkdir`, `chmod`, `jq` if merging an existing `settings.json`), approximate time (~5 minutes for a clean install).

## Section 2 — Pick install scope

Three short subsections; the reader picks one. One sentence each.

- **Project-local** (default) — everything under `./.claude/`. Right when the process is specific to this codebase.
- **User-global** — everything under `~/.claude/`. Right for reusable cross-project skills.
- **Hybrid** — skills `~/.claude/skills/`; hooks, settings, scaffolding project-local. Common power-user choice.

## Section 3 — Copy the artifacts

Concrete `cp` and `mkdir` commands for the project-local case. Note user-global variants inline. Read source paths from the manifest; destinations from the scope choice.

Example shape (the actual content uses real paths from this synthesis):

```bash
# CLAUDE.md (⚠ merge by hand if you already have one — never overwrite)
cp process-designer-output/CLAUDE.md ./CLAUDE.md

# Skills
mkdir -p .claude/skills
cp -r process-designer-output/skills/* .claude/skills/

# Hooks
mkdir -p .claude/hooks
cp process-designer-output/hooks/*.sh .claude/hooks/

# Eval set
mkdir -p evals
cp process-designer-output/evals/eval-set.md evals/
```

For any skill marked `is_sketch: true` in the manifest, note that the reader should add `disable-model-invocation: true` to its frontmatter before installing — or skip the skill and fill the gaps first.

## Section 4 — Make scripts executable

```bash
chmod +x .claude/hooks/*.sh
```

## Section 5 — Merge `settings.json`

Two cases:

- **Fresh install** — no prior `settings.json`:

  ```bash
  cp process-designer-output/hooks/settings-snippet.json .claude/settings.json
  ```

- **Existing `settings.json`** — show a `jq` merge or instruct manual:

  ```bash
  jq -s '.[0] * .[1]' .claude/settings.json process-designer-output/hooks/settings-snippet.json > .claude/settings.json.new
  # Inspect .new; mv when good.
  ```

  Shallow merge via `*`; for nested `hooks.PreToolUse[]` arrays, manual edit is safer to avoid duplicates.

## Section 6 — Initialize runtime scaffolding

For each path in the manifest's `runtime_paths`, generate the `mkdir` or `touch` line. Inline any seeded content with a heredoc:

```bash
mkdir -p archive/ decisions/ sources/ snippets/env/
touch NOTES.md

cat > voice-fingerprint.md <<'EOF'
# Voice fingerprint

Populate by reading the last six posts in archive/.
EOF
```

## Section 7 — Verify the install

- Hook fires correctly — run the test fixture from each `.sh`'s bottom comment.
- Skill is discoverable — in Claude Code, type `/<skill-name>`; it appears in suggestions.
- `CLAUDE.md` is at project root (or `~/.claude/` for user scope).
- `.claude/settings.json` parses (`jq . .claude/settings.json`).

## Section 8 — Next steps

Three lines: how to baseline the eval set against current setup, how to start using the skills, where to look when something feels off (mention the relevant docs paths).

## Section 9 — Roll-back

Each install step is reversible:

- Move installed files out of `.claude/`.
- Revert the `settings.json` merge by hand.
- Delete unpopulated runtime scaffolding.

A future `/process-installer` generates a precise `uninstall.sh`. Until then, keep an `INSTALL_LOG.md` of what you did so reversal is mechanical.
