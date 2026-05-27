# Operator profile — Stage 1 reference

The operator's *register* and *fluency* are cached in `.claude/operator-profile.md` between invocations of `/process-designer`. This file defines both taxonomies, the cached-file shape, and the freshness rule.

`scripts/check-operator-freshness.sh` returns 0 if the cached file is fresh (≤30 days), 1 otherwise.

---

## Register taxonomy — four anchors

The reader picks one as the language for the synthesised artifacts. The paragraph from Stage 1's step 1 supplies the *default* register; the reader can override.

### Plain

Minimal jargon; analogies welcome. Everyday workplace language. The reader is intelligent and engaged but not domain-immersed — or the *audience* for the artifacts isn't.

Sample phrasing:
- *"Stuff that can't be undone."*
- *"How risky is it if the AI messes up?"*
- *"Does the AI work on its own, or do you check everything?"*
- *"How often does one round of testing happen?"*

**Avoid:** *idempotency, non-determinism, t-norm, p%-understanding, context rot.*
**Prefer:** *things-that-stick, gives-different-answers, weighing-multiple-signals, how-sure-the-AI-is, the-AI-forgets-stuff.*

### Professional

Standard work language. Some domain terminology with brief unpacking. The reader has read about AI agents but isn't a daily practitioner.

Sample phrasing:
- *"Operational risk and recoverability."*
- *"How much oversight does the AI need?"*
- *"Variability in AI output across runs."*
- *"State that persists across sessions."*

**Avoid:** raw practitioner jargon (*t-norm*, *p%-understanding*) without unpacking.
**Prefer:** named concepts with a one-line gloss. *"AI agents give different outputs from the same prompt — output variance."*

### Technical

Precise terms-of-art for the domain. Assumes professional context but not deep specialist immersion. **The clinic's default register.**

Sample phrasing:
- *"Reversibility surface."*
- *"Non-determinism in agent output."*
- *"Context window as working set."*
- *"Hook-enforced safety floor."*

**Avoid:** plain-language analogies that feel patronising; over-unpacking of standard terms.
**Prefer:** the exact terminology from the clinic README's Methods × Constraints map.

### Specialist

Full practitioner jargon. Assumes deep familiarity with agent architecture, prompt engineering, and the clinic's full vocabulary. The reader is a peer.

Sample phrasing:
- *"P%-understanding aggregated via product t-norm across evidence sources."*
- *"Context substrate at 60% capacity triggers `/compact`."*
- *"Orchestrator-worker with condensed-return contracts."*

**Avoid:** spelling out concepts the reader has internalised. *"As you know, non-determinism means..."* is condescending.
**Prefer:** direct reference to the underlying machinery.

---

## Fluency taxonomy — four anchors

Fluency is the agent's model of the operator's *competency for the task at hand* (designing AI-agent processes). It drives every live-interaction surface during the interview *and* at runtime in the installed process — vocabulary, question phrasing, `AskUserQuestion` option wording, suggestions, sub-step inclusion. The reader picks one.

- **New** — first time designing an AI-agent process.
- **Aware** — has used agent tooling; hasn't designed processes from scratch.
- **Practitioner** — designs and tunes processes in workflow.
- **Fluent** — architects multi-agent systems; knows the clinic vocabulary cold.

### How fluency shapes the live interaction

Per dimension question:

| Surface | New | Aware | Practitioner | Fluent |
| --- | --- | --- | --- | --- |
| **Question stem** | Everyday words; dimension name hidden | Dimension named with brief context | Dimension named with brief context | Dimension named direct |
| **`AskUserQuestion` option labels** | Rephrased in everyday vocabulary | Light gloss on clinic terms | Light gloss | Clinic anchor labels direct |
| **Worked-example prelude** | 2–3 sentences with use-case example | 1-sentence framing + 1-sentence example | 1-sentence framing | None |
| **Recommended default** | Surfaced ("most readers like you pick 2") | Optional | Optional | Not surfaced |

Beyond the dimension questions:

- **Use-case quality dimensions sub-step** — *new*: offered as deferrable to the refinement loop. *Aware / practitioner / fluent*: inline.
- **Mid-interview re-calibration offer** — after 2–3 dimensions: *new* operator who's tracking easily gets a bump-up offer; *fluent* operator who hesitates gets a step-down offer.

### How fluency shapes the synthesised artifacts

Secondary effect — fluency tunes the verbosity of *why* clauses in the synthesised `CLAUDE.md`. A *new*-fluency reader's CLAUDE.md trends to the upper end of the 400–1,200 word budget with explicit rule rationale; a *fluent* reader's CLAUDE.md trends to the lower end, with methods invoked by name not explained.

### Read at runtime, not just at synthesis time

The synthesised `CLAUDE.md` references `.claude/operator-profile.md` and includes an *Operator-aware interaction* directive (see [`synthesis-templates/claude-md.md`](synthesis-templates/claude-md.md)) — the runtime agent reads the file every session and calibrates per the recorded fluency + register.

This makes the operator profile a *live* part of the installed process. The operator can update `.claude/operator-profile.md` directly to change calibration; the next session picks it up without re-running `/process-designer`.

When fluency grows (a *new* operator becomes a *practitioner* after a few weeks of use), updating the file is the small move; re-running `/process-designer` is the big move. Both are valid; the live-file approach is the lighter path.

---

## How register and fluency drive synthesis

**Register** controls *what the human experiences from the system* — not the system's behaviour.

*Directly human-facing surfaces* (the words the human reads):
- `INSTALL.md` prose.
- Eval rubric anchor wording and query phrasing.
- Hook reject messages — the stderr text when a hook fires.
- Human-facing comments and rationale in skill sketches.

*Indirectly human-facing* (the agent's communication, shaped through `CLAUDE.md`):
- The voice/conventions section in `CLAUDE.md` propagates to the agent's responses. A *Plain*-register `CLAUDE.md` gives the agent a Plain voice when it replies to the human.

*Not affected by register*:
- Bash logic in hook scripts (`grep`, `exit 2`, regex patterns).
- The machine-readable `manifest.json`.
- The agent's tool choices, dimension calibrations, or other behaviour — only its *communication style*.

**Fluency** controls every live-interaction surface during the interview *and* at runtime in the installed process — vocabulary, question stems, `AskUserQuestion` option labels, worked-example preludes, recommended defaults, sub-step inclusion. See the *Fluency taxonomy* section above for the per-surface breakdown.

Register and fluency are **orthogonal axes**. A *Specialist* operator can be *New* (knows the jargon but hasn't designed a process). A *Plain* operator can be *Fluent* (designs processes routinely but talks about them in everyday language). The two questions are asked separately.

---

## Cached file shape

`.claude/operator-profile.md` looks like:

```markdown
# Operator profile

last-confirmed: YYYY-MM-DD
fluency: <new|aware|practitioner|fluent>
register: <plain|professional|technical|specialist>
project: <inferred from working-directory name or asked>

## Register: <name>
<one-paragraph description of what this register means for this operator>

## Fluency: <name>
<one-paragraph description of what this fluency means for the interview>

## Notes for future re-runs
- Conditions that would indicate the profile needs updating.
```

---

## Freshness rule

- `last-confirmed` within 30 days → fresh. Surface cached values; ask *use / update one / update both* via `AskUserQuestion`.
- Older than 30 days, missing, or unparseable → stale. Ask both questions fresh; paragraph supplies the register default.

The 30-day window catches drift in the reader's preferences without forcing them to re-confirm every session. The threshold is longer than Stage 0's 7-day capability check because operator preferences are more stable than harness schemas.

---

## Anti-patterns

- **Inferring register only from the paragraph.** Paragraph register and audience register can diverge. A reader writing a technical paragraph about a mentor program for non-technical mentees needs explicit override.
- **Defaulting silently to Technical + Practitioner.** That is the clinic's implied audience but not every reader's. Always confirm via the explicit questions; never assume.
- **Mixing registers across artifacts.** A *Plain* operator should not get a CLAUDE.md saying *"reversibility surface"* and a hook script with reject message *"BLOCKED by irreversibility-class-3."* Pick one register; apply consistently.
- **Patronising at high registers.** A *Specialist* who reads *"as you know, non-determinism means..."* stops reading. Match the register.
- **Locking the profile.** If a reader picks *Plain + New* but learns rapidly during the interview, offer to bump fluency to *Aware* or *Practitioner* during the refinement loop. The profile is a starting calibration, not a cage.
