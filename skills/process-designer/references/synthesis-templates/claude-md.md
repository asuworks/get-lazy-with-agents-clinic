# CLAUDE.md template — structural guidance

Each section names what to consider and how the dimension targets shape it. Write fresh prose; do not interpolate placeholder slots.

Target length: 400–1,200 words. Bias upper bound for high Memory horizon (more pointers to maintain); lower bound otherwise.

The synthesised `CLAUDE.md` is a c₂ artifact — instructions about how to instruct in this project. The agent reads it every session.

---

## Section 1 — Project context

One sentence: what this project is, who works on it, what the agent is being asked to do. Concrete. Avoid aspirational language.

*Calibration.* Pull from the reader's Stage-1 use-case paragraph. Strip aspirational language; keep concrete nouns.

## Section 2 — Decision authority

What the agent decides alone; what it surfaces for confirmation; what it never decides without explicit authorisation.

*Calibration by Autonomy:*

- 1 — explicit list of "never without confirmation" categories. File modifications, command execution, external calls.
- 2 — bundled review at block boundaries; agent proposes a block, user approves.
- 3 — gates at named milestones; agent runs OODA loops between gates.
- 4 — high-trust default; list the non-negotiable surface only.

*Calibration by Reversibility:*

- 4 — irreversible operations always surface, regardless of Autonomy. *"Even at high autonomy, the following always require human confirmation: [list]."*
- 1–3 — looser; let Autonomy alone govern.

## Section 3 — Interview rule

The agent's default for non-trivial work: interview the user until ~98% sure (or lower threshold for lower-stakes work). Specify the threshold and what triggers an interview.

*Calibration by Reversibility and Autonomy together:*

- High Reversibility (3–4) + low Autonomy (1–2): threshold 98%, fire on tasks > 30 min.
- Mid: threshold 90%, fire on tasks > 2 hours.
- Low Reversibility (1–2) + high Autonomy (3–4): threshold 75%, fire only when the user asks.

## Section 4 — Voice and conventions

Pull from the use case. Name domain voice (legal, customer-facing, scientific writing) if applicable. Propagate stated tone preferences verbatim.

*Default voice rules* (override per use case):

- Active voice.
- No hedging adverbs unless the claim genuinely requires them.
- Numbers and specifics over generalities.

Include code conventions if the work is code; reading-level + citation style if the work is prose.

## Section 5 — Where to read

Pointers to canonical project state. Per pointer: one sentence on *what's there* and *when to read it*.

*Calibration by Memory horizon:*

- 1 — `README.md` and the immediate project root.
- 2 — add a brief same-day notes file.
- 3 — add `NOTES.md`, `decisions/`, recent meeting notes.
- 4 — full set: `NOTES.md`, `decisions/`, issue tracker, team wiki link.

## Section 6 — Tool preferences

Which tools the agent reaches for first; which to avoid; which require setup.

*Calibration by Parallelism:*

- 1 — single-agent default; no sub-agent invocation unless requested.
- 2 — occasional sub-task invocation.
- 3 — orchestrator-worker pattern at modest fan-out; named sub-agents.
- 4 — ensemble + fitness-selection structure.

*Calibration by Domain distance:*

- 4 — require `WebFetch` / `WebSearch` before acting on knowledge claims. *"For any claim about [domain], fetch source first."*
- 3 — lighter grounding directives for the niche aspects.
- 1–2 — trust the model's defaults.

## Section 7 — Safety floor

Brief list of categorical *always* / *never* rules. Enforcement is in `hooks/` — this list is the documentation.

*Calibration by Reversibility:*

- 4 — long list, explicit named classes (deploys, migrations, external comms, destructive filesystem operations on shared volumes).
- 3 — medium list, reader's specific irreversibility classes.
- 1–2 — common-sense floor only.

Close the section with: *"These rules are enforced by hooks in `.claude/hooks/`. The list is the documentation; the hooks are the deterministic guarantee."*

## Section 8 — Use-case quality bar

Generated from Stage 1's use-case quality dimensions. For each dimension at target ≥ 3, add a sentence naming the dimension and what good output looks like at that target.

Example:

> *Reproducibility (target 4). All generated code includes seed setup, environment freeze, and a one-command re-run path.*

---

## Section 9 — Operator-aware interaction calibration

The synthesised `CLAUDE.md` instructs the runtime agent to read `.claude/operator-profile.md` and calibrate every `AskUserQuestion` call, suggestion, and explainer to the recorded fluency + register. This makes the operator profile a live part of the installed process — the operator updates the file directly to change calibration; no `/process-designer` re-run required.

Content of this section in the synthesised CLAUDE.md (the agent reads it every session):

> ## Operator-aware interaction
>
> Read `.claude/operator-profile.md` at session start. Calibrate every `AskUserQuestion` call, suggestion, and explainer to the recorded fluency and register.
>
> Current calibration (from `.claude/operator-profile.md`):
> - **Fluency:** `<fluency>`
> - **Register:** `<register>`
>
> Per-fluency directives in force:
> - **Question stems:** <directive>
> - **Option labels in `AskUserQuestion`:** <directive>
> - **Worked-example preludes:** <directive>
> - **Recommended defaults:** <directive>
>
> Per-register directives in force:
> - **Reply tone to the operator:** <directive>
> - **Vocabulary on human-facing surfaces:** <directive>
>
> If `.claude/operator-profile.md` is missing at session start, fall back to *Technical + Practitioner*.

The synthesis inlines the *directives that apply to this operator*, not the full taxonomy. The agent reads its directives; the taxonomy lives in the skill's `references/operator-profile.md` if the agent or operator wants to consult it.

*Calibration by fluency.* The section's prominence scales with how far the operator profile is from the clinic default (*Technical + Practitioner*):

- *Technical + Practitioner* operator → section may be omitted (the default matches the implicit audience).
- *New + Plain* operator → section near the top of `CLAUDE.md`; verbose directives with explicit examples drawn from the use case.
- Other combinations → directives proportional to the difference.

*Calibration by register.* The directives themselves are written in the operator's register.

---

## Closing footer

End the `CLAUDE.md` with a date and the dimension targets:

```markdown
---
*Generated by `/process-designer` on YYYY-MM-DD. Dimension targets: Reversibility=N, Domain distance=N, Iteration cost=N, Autonomy=N, Memory horizon=N, Parallelism=N. Plus: [dim]=N, [dim]=N.*
*Regenerate by re-running the skill with adjusted targets.*
```
