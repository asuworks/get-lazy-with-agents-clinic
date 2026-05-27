# Skill sketch template — structural guidance

A sketch is *not* a working skill. It is the SKILL.md outline the reader fleshes out, then installs at `~/.claude/skills/<name>/SKILL.md`.

Each sketch goes to `process-designer-output/skills/<sketch-slug>/SKILL.md`. Use the reader's likely phrasing for the sketch slug (from their use-case paragraph), not technical jargon.

Generate 1–3 sketches. Pick the top 3 by *time saved per invocation × frequency*.

**The first sketch must cover the primary laborious work** the reader named — the activity that consumes the bulk of their time and that they described as a recurring task. Verification, checking, or formatting sketches (claim-checkers, voice-checkers, snippet-runners) come second, only if they earn the slot.

If you have generated 1–3 sketches and none produces the *primary output* of the use case, you missed the main work. Reconsider before writing the sketches to disk.

---

## How to choose what to sketch

From the reader's use-case paragraph plus the universal dimensions, identify *the laborious work the reader does often*. Look for:

- Recurring tasks the reader named.
- Cross-cutting concerns the reader implied (formatting, review, documentation).
- Boundary tasks: things at the start or end of every session.

---

## Sketch structure

### Frontmatter

```yaml
---
description: <When to trigger this skill. Pattern-match the reader's likely phrasing. Two or three sentences. Specific; vague descriptions don't trigger reliably.>
allowed-tools: <Tools the skill needs. Space- or comma-separated. Skip if uncertain — that allows all.>
---
```

The `description` is what the harness's matcher reads. Imitate the reader's likely phrasing from the use-case paragraph. Confirm the description-character cap against `.claude/agent-capabilities.md` §SKILL.md (currently 1,536 combined with `when_to_use`).

### Section 1 — Purpose

One sentence: what this skill does, why it exists.

### Section 2 — When to use it

Bullet list of trigger conditions. When the reader reaches for the skill; when the agent invokes it automatically.

*Calibration by Autonomy:*

- High — agent invokes on description match without confirmation.
- Low — description specifies *"Use only when the user explicitly says X."*

### Section 3 — The flow

Numbered steps. One per agent action. Reference specific tools (`AskUserQuestion`, `Read`, `Bash`) where they apply.

*Calibration by Iteration cost:*

- 1–2 — trial-and-error loops allowed.
- 3 — hypothesis-first with light measurement.
- 4 — hypothesis-first with explicit eval.

### Section 4 — Inputs the user provides

List inputs. Each with a name + one-sentence description. If interactive, list the `AskUserQuestion` calls.

### Section 5 — Outputs

What the skill produces. File paths, return data, side effects.

*Calibration by Reversibility:*

- 3–4 — outputs include a "preview before commit" step. Staging path; reader installs.
- 1–2 — outputs go to final location directly.

### Section 6 — Gaps the reader fills

This is the part that distinguishes a sketch from a working skill. List the specifics the reader adds:

- Replace the placeholder regex with the project's actual signature.
- Add the company tone-guide URL to `references/`.
- Fill in the test-runner command for the project (`pytest`, `npm test`, `cargo test`, etc.).

Be explicit. The sketch is honest about what it has not yet decided.

### Section 7 — Anti-patterns

The moves that would break this skill. Use the methods named in [`references/methods.md`](../methods.md): Verify, Interview, Hooks.

- *"Don't accept the agent's confidence on whether the test passed; run the test (Verify)."*
- *"Don't skip the interview step on tasks above the autonomy threshold (Interview)."*

### Section 8 — Quality bar

3–5 falsifiable criteria for when the skill is doing its job. Each criterion is a yes/no the reader can check after one invocation.

---

## Closing line

Each sketch ends with:

*"This is a sketch. The gaps in Section 6 must be filled before installing. Once filled, copy this folder to `~/.claude/skills/<sketch-slug>/` to activate."*
