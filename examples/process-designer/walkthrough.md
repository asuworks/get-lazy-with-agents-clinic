# Building the `/process-designer` system — Level 3 in practice

> Worked example of the clinic's Level 3: a two-skill system that takes a use case and produces a working installed agent process. Each phase grounds in what `README.md` teaches.

A reader following this walkthrough builds the system alongside it. The walkthrough names the moves; the reader makes them on their own use case. The result is two installable skills at `skills/process-designer/` and `skills/process-installer/`, ready to invoke in sequence.

Ten phases. Phases 1–7 design the system (six phases for the design skill, one for the install skill); 8–10 assemble, integrate, finalize.

| Phase | Move | README method(s) |
| --- | --- | --- |
| 1 | Frame the task | — |
| 2 | Compose methods against constraints | All nine |
| 3 | Specify the interview | Interview, Decompose |
| 4 | Specify the synthesis | Hand off, Decompose, Sub-agents |
| 5 | Specify the safety floor | Hooks |
| 6 | Specify the verification | Verify, Evaluate |
| 7 | Specify the install | Hand off, Verify, Hooks |
| 8 | Assemble the skill files | Research |
| 9 | Wire into README | — |
| 10 | Finalize | Session hand-off |

---

## Phase 1 — framing the `/process-designer` task

Two parts: the operator's use case, and the constraints the skill must work around.

### Use case the operator stated

> *"A `/process-designer` skill that takes any task description and produces a working agent process for that task — for any reader of the clinic."*

Recursive — the skill produces processes; the skill itself is a process.

### Meta-frame of the use case

The reader brings a use case; the skill produces a process. Both operate at the level of the *class*. The class needs a meta-frame — the structure any specific use case in the class shares with every other. Phase 2 names its parts.

### Two complementary skills

The use case has two halves: *produce* the process spec, and *install* it into the reader's setup. A spec the reader cannot install is half a spec. The system therefore has two skills, designed in parallel through this walkthrough:

- **`/process-designer`** — interviews the reader; produces the process specification (four artifacts plus a machine-readable install contract). Phases 1–6 design it.
- **`/process-installer`** — reads the install contract; surveys destination conflicts; copies artifacts; scaffolds runtime; verifies. Phase 7 designs it.

Both ship under `skills/`. The contract between them is `manifest.json` plus `INSTALL.md` — produced by `/process-designer`'s Phase 4 synthesis, consumed by `/process-installer` at install time.

The constraints in the rest of this phase apply to the *design* skill — the one doing the heavy lifting against use-case variance, agent context limits, and harness churn. The install skill has its own (lighter) constraint profile, addressed in Phase 7.

### Constraints on the skill, human side

- **Bound cognition.** Reader can't hold the design space in working memory.
- **Scarce time.** Reader won't sit through a multi-hour session.
- **Unknown unknowns.** Reader doesn't know which dimensions they're missing.

### Constraints on the skill, agent side

- **Context size.** Interview + synthesis + refinement must fit one session for the typical case.
- **Knowledge cut-off.** SKILL.md schema and hook event names may be a quarter stale.
- **Confident ≠ correct.** Synthesised artifacts are not self-verifying.
- **Non-determinism.** Two runs against the same use case produce different artifacts.
- **Security exposure.** The skill writes to `.claude/`, fetches web content, proposes hook scripts.
- **Field churn.** Harness syntax is versioned; the skill cannot bake it in.

### Constraint on the skill, systemic side

- **Mutual unverifiability.** The skill can't verify the reader understood; the reader can't verify the skill understood.

### What this framing produces

Ten constraints. Every one must be addressed; none is optional. Phase 2 maps each to a method.

---

## Phase 2 — composing methods against the constraints

Each Phase 1 constraint maps to a method via `README.md` §211. The methods then compose into stages.

### One-to-one mapping

| Constraint | Primary method |
| --- | --- |
| Bound cognition | **Decompose** |
| Scarce time | **Hand off** |
| Unknown unknowns | **Interview** |
| Context size | **Decompose** |
| Knowledge cut-off | **Research** |
| Confident ≠ correct | **Verify** |
| Non-determinism | **Evaluate** |
| Security exposure | **Hooks** |
| Field churn | **Research** |
| Mutual unverifiability | **Interview** |

Seven of nine README methods are load-bearing. *Session hand-off* and *Sub-agents* enter as stack-mates below.

### Stage 1 — interview the reader

- **Decompose** into atomic questions, one consideration at a time.
- **Hand off** each question; structured input → answer → next.
- Extract three independent classes of input — the use case (paragraph), the operator profile (register × fluency), and the dimensions of the work. Phase 3 specifies the questions per class.
- Target ten minutes for the typical case.
- Aim for ~98% understanding before Stage 3 runs.

### Stage 2 — research the harness

Synthesis uses the harness's current syntax; the model's memory may be stale.

- **Research** before synthesis. Web-fetch official docs; record sources and date.
- **Cache** in a project-local reference file; a re-run within the week skips the fetch.
- **Sub-agent** the fetch when categories are independent (SKILL.md format, hook events, `AskUserQuestion` schema, settings shape).

### Stage 3 — synthesize the process artifacts

- **Decompose** the spec into six outputs in two layers: four artifacts (`CLAUDE.md`, skill sketches, hooks config, eval skeleton) plus the install contract (`manifest.json`, `INSTALL.md`). Phase 4 specifies each.
- **Hand off** each: write to a staging path, reader inspects, reader installs.
- **Sub-agent** per-artifact generation for the dense case.

### Stage 4 — verify and prepare the eval

- **Verify** at synthesis time: cross-check artifacts against Stage 2's fresh facts and Stage 1's stated targets.
- **Evaluate** at install time: ship an eval skeleton — twenty queries from the reader's domain, four-anchor rubric.

### Stage 5 — propose the safety floor as hooks

- **Hooks** proposed, not installed. Reader inspects before installing.
- Coverage scales with the reader's reversibility surface.

### Session hand-off as a sixth, dormant stage

For the dense case, intermediate state survives a `/quit`:

- **Session hand-off** via `.claude/agent-capabilities.md` (Stage 2 output) and `.claude/operator-profile.md` (Stage 1 output). The next session reads them.
- Dormant by default; the typical reader doesn't touch them.

### What this composition produces

Five active stages plus one dormant. Every constraint maps to at least one method; every method maps to at least one stage. The mutual-amplification claim is now testable in the small — reader supplies intent and use-case detail; skill supplies vocabulary, structure, and the fresh harness facts the reader doesn't have.

Next: the interview's content.

---

## Phase 3 — specifying the interview the skill conducts

Stage 1 of the skill is *interview the reader*. Phase 3 names what the interview must extract and in what order.

### Three classes of input the synthesis needs

The Stage-2 synthesis calibrates against three independent inputs:

- **The use case** — *what* the reader is trying to do. Captured as a free-text paragraph.
- **The operator** — *for whom* the artifacts are being made and at what fluency. Captured as a two-axis profile (*register × fluency*) cached for thirty days.
- **The work** — six universal scales describing the *shape* of the process, plus 2–4 use-case-specific quality scales.

Each class is asked separately. The paragraph answers *what*; the profile answers *for whom*; the dimensions answer *how*. The three classes are orthogonal: the same use case can run at any operator profile, and the same operator can characterise different work at different dimensions.

### The use-case paragraph

Free text. The paragraph carries the substance and supplies the vocabulary substrate (specific nouns, verbs, named artifacts) for downstream synthesis. It also supplies the *default* register signal for the operator profile — but does not lock register; the paragraph register and the audience register can diverge, and the reader picks register explicitly.

### The operator profile: register and fluency, cached for thirty days

Two questions about the operator after the paragraph. Both cached in `.claude/operator-profile.md` with a 30-day freshness window so a returning reader does not repeat themselves.

- **Register** — *plain / professional / technical / specialist*. Controls *what the human experiences from the system*: the agent's tone in responses, hook reject messages on stderr, eval rubric wording, and the install guide. Not the bash logic in hook scripts; not the machine-readable manifest. The paragraph's register is the recommended default; explicit override matters when the paragraph reads technical but the artifacts will be read by non-technical teammates.
- **Fluency** — *new / aware / practitioner / fluent*. The agent's model of the operator's competency *for this task*. Drives every live-interaction surface — during the `/process-designer` interview *and* at runtime in the installed process. The synthesised `CLAUDE.md` references `.claude/operator-profile.md` and instructs the runtime agent to keep calibrating per the recorded fluency. A *new* operator never reads clinic vocabulary they don't have; a *fluent* operator never reads an explanation they don't need. Surface-by-surface breakdown at [`references/operator-profile.md`](../../skills/process-designer/references/operator-profile.md) inside the skill.

If the cached profile is fresh, the skill surfaces it via `AskUserQuestion` — *"Use this profile, or update?"* — and the reader answers once instead of repeating both questions.

Register and fluency are orthogonal axes. A *specialist*-register operator can be *new* fluency (knows the jargon but hasn't designed a process); a *plain*-register operator can be *fluent* (designs routinely but talks about it in everyday language). The full taxonomy lives at [`references/operator-profile.md`](../../skills/process-designer/references/operator-profile.md) inside the skill.

### Per method, what must be known about the work

The six universal dimensions fall out of a reverse-derivation that's independent of the operator profile: each method in Stages 2–5 needs specific information about the *work itself*.

| Method to calibrate | What it needs to know |
| --- | --- |
| Hooks (Stage 5) | how reversible are mistakes in this work? |
| Research (Stage 2) | how far from the model's training distribution is the work? |
| Evaluate (Stage 4) | how costly is one iteration cycle? |
| Hand off (Stage 3) | how independently should the agent operate? |
| Session hand-off | how much state crosses sessions? |
| Sub-agents (Stages 2, 3) | how parallel is the work? |

Six questions. The dimensions interview is the six.

### Six universal dimensions

Each row above becomes a dimension. The wording stabilises:

- **Reversibility.** Recoverability of mistakes — pure exploration to irreversible production.
- **Domain distance.** Coverage in the model's training — mainstream to proprietary or post-cutoff.
- **Iteration cost.** Cost per experiment cycle — seconds to real-world commitments.
- **Autonomy.** Required oversight — every-step review to outcome-only audit.
- **Memory horizon.** State persistence — single conversation to multi-month lineage.
- **Parallelism.** Concurrency — single agent to fitness-selected ensemble.

These are the dimensions any process-design problem characterises against. Universal because they fall out of the constraint→method composition, not because they were pre-listed.

### Why four-anchor rubrics

`AskUserQuestion` caps options at four per call. Each dimension gets four named anchors — recognisable points on the scale, not synonyms. The anchor wording is the calibration; the reader picks the closest, not a number on an unanchored slider.

A five-anchor rubric would need two calls per dimension; the reader's calibration drifts between them. Four anchors per call preserve the gradient.

### Per-use-case quality dimensions beyond the universal six

The six describe *process architecture*. Reader-specific *quality* dimensions describe what good output looks like for this reader's kind of work — *reproducibility* for notebooks, *tone fidelity* for customer email, *blamelessness* for postmortems.

These are not pre-listed. The skill reasons about them from the reader's stated use case and proposes two to four, each with its own four-anchor rubric. The reader confirms or skips each.

### Interview flow and time budget

- Free-text use case first.
- Operator-profile cache check second. If `.claude/operator-profile.md` is fresh (≤30 days), surface the cached fluency + register and ask *use / update one / update both*. If stale or missing, ask both fresh.
- Fluency question (if updating or stale) — one `AskUserQuestion`, four anchors (*new / aware / practitioner / fluent*).
- Register question (if updating or stale) — one `AskUserQuestion`, four anchors (*plain / professional / technical / specialist*); paragraph-inferred register surfaced as the recommended option.
- Universal six dimensions next (one `AskUserQuestion` per dimension), in the order Reversibility → Domain distance → Iteration cost → Autonomy → Memory horizon → Parallelism. Per-dimension prelude calibrated to fluency; anchor wording translated via use case + register.
- Use-case-specific quality dimensions last; same per-fluency prelude and per-register translation.
- Persist `.claude/operator-profile.md` at the end with today's `last-confirmed` date.
- Time budget: ten minutes for the typical case; longer for *New* fluency because the preludes are expanded; shorter for repeat-runs with a fresh cached profile.

### What this specification produces

Stage 1 is now defined — a free-text use-case capture, six `AskUserQuestion` calls for the universal dimensions, two to four for use-case-specific quality dimensions. Stage 1's output is the use-case paragraph plus a structured table of `(dimension, target-anchor)` pairs that Stage 3 consumes.

Next: the synthesis.

---

## Phase 4 — specifying the synthesis the skill produces

Stage 3 takes Stage 1's interview output and Stage 2's harness facts, and produces the process specification in pieces. Phase 4 names the pieces and what each is calibrated against.

### Two layers of specification

The synthesis produces six outputs in two layers:

| Layer | Output | Job |
| --- | --- | --- |
| **Artifacts** | `CLAUDE.md` | Decision authority, interview rule, voice and conventions, safety-floor pointer, quality bar |
| | `skills/<name>/SKILL.md` (1–3 sketches) | Laborious recurring work the reader does often |
| | `hooks/` (settings snippet + shell scripts) | The reversibility floor as deterministic interception |
| | `evals/eval-set.md` | Twenty representative queries + four-anchor scoring rubric |
| **Install support** | `manifest.json` | Machine-readable install contract — every artifact's source path and destination, every dimension target, every runtime path the `CLAUDE.md` references, the gap list per skill sketch |
| | `INSTALL.md` | Per-process manual install guide; numbered steps from *"pick scope"* through *"verify"* |

The artifacts layer is the process specification proper — what the agent does for the use case. The install-support layer documents how the specification reaches the reader's setup. A specification the reader cannot install is half a specification; both layers ship together.

Each artifact in the first layer has independent value — the reader can adopt one without the others. The install-support layer is consumed end-to-end: the manifest references the artifacts; `INSTALL.md` references the manifest. The companion [`/process-installer`](../../skills/process-installer/SKILL.md) skill consumes the manifest and executes a guided install (project-local scope; sketches installed with `disable-model-invocation: true`). `INSTALL.md` is the manual fallback when the installer skill is unavailable.

### How dimensions calibrate each artifact

- **Reversibility** scales the hooks config and adds "never without confirmation" entries to `CLAUDE.md`.
- **Domain distance** writes grounding directives into `CLAUDE.md` and shapes eval queries that test domain fit.
- **Iteration cost** sizes the eval set — full twenty for cheap loops, ten or fewer for expensive cycles.
- **Autonomy** writes `CLAUDE.md`'s decision-authority section — explicit confirmation list at low autonomy, end-to-end operation at high.
- **Memory horizon** writes the cross-session pointers — `NOTES.md` / `HANDOFF.md` / `decisions/` directives at higher horizons.
- **Parallelism** decides whether skill sketches use the sub-agent pattern; mentions orchestrator-worker contracts at higher parallelism.
- **Use-case-specific quality dimensions** add a quality-bar section to `CLAUDE.md` and corresponding eval criteria.

Six universal dimensions, six calibrations across four artifacts. The synthesis is the mapping.

### Primary laborious work first, verification sketches second

The one-to-three skill sketches fall in a natural priority order. The first sketch covers the **primary laborious work** the reader named — the activity that consumes the bulk of their time. Verification, checking, and formatting sketches (claim-checkers, voice-checkers, snippet-runners) come second, only if they earn the slot.

The ordering matters because verification only pays once the primary work is automated. A synthesis that ships only verification sketches has skipped the main work — the reader still does the primary activity by hand and now has skills to check the output. Address the bulk-of-time activity first; verification is amplification on top.

### Per-artifact templates as internal references

Each artifact is generated against an internal template — structural guidance the skill carries in its `references/` folder. Templates specify what each section considers and how the dimensions calibrate it, not what the section says. The synthesis writes fresh prose; the templates do not fill in.

### Where the artifacts go before install

The skill writes to `process-designer-output/` in the reader's working directory:

```
process-designer-output/
├── CLAUDE.md
├── skills/<sketch-name>/SKILL.md
├── hooks/
│   ├── settings-snippet.json
│   └── <hook-name>.sh
└── evals/
    └── eval-set.md
```

Never directly into `.claude/`, never into the reader's working `CLAUDE.md`. The reader reviews; the reader installs.

### Existing `CLAUDE.md` is not overwritten

If a `CLAUDE.md` is already in the working directory, the skill writes only to `process-designer-output/CLAUDE.md` and notes the reader merges manually. Overwriting is irreversible to the reader.

### Decompose per artifact for parallel generation

Each artifact's generation reads the interview output, the harness facts, and the relevant calibrations. No artifact depends on another's intermediate state. For the dense case, the four generations fan out across sub-agents — orchestrator-worker, condensed returns.

### Quality bar before install is named

The synthesis declares the artifacts ready when:

- Every Stage-1 dimension target has a corresponding calibration in at least one artifact.
- Hook script matchers come from Stage 2's fresh harness facts, not training-data recall.
- `CLAUDE.md` reads as the reader's own working document — register matches the reader's free-text use case description.

### What this specification produces

Stage 3 is now defined: six outputs across two layers (four artifacts plus the install contract), six dimension calibrations across the artifacts, fixed output paths, no overwrites, parallelism-friendly fan-out, a falsifiable readiness bar. Stage 3's output is the contents of `process-designer-output/`.

Next: the safety floor.

---

## Phase 5 — specifying the safety floor as hooks

Stage 5 of the skill is *propose the safety floor*. Hooks sit above the agent loop and intercept tool calls deterministically. The agent cannot talk around them — they are configuration, not prompt.

### Why hooks, not prompted self-policing

Prompts can be ignored, paraphrased, or hijacked. A `CLAUDE.md` rule saying *"never run `rm -rf`"* is read once and competes with every other rule in the context. A hook runs unconditionally on every matching tool call.

For anything that touches files, the network, or shared infrastructure — write a hook before writing a prompt. README §330.

### What the skill produces

Three pieces under `process-designer-output/hooks/`:

- `settings-snippet.json` — declarations the reader merges into `.claude/settings.json`.
- `<hook-name>.sh` — one shell script per blocked pattern.
- `README.md` — what each hook blocks, why, false-positive notes, install steps.

### Coverage scales with Reversibility

| Reversibility | Hooks recommended |
| --- | --- |
| 1 (pure exploration) | None. Engineering cost exceeds cost-on-failure. |
| 2 (local artifacts) | 1–2 hooks against common painful failures — broken commits to shared branches, writes outside the project. |
| 3 (visible to teammates) | 2–3 hooks covering the reader's named irreversibility classes plus the canonical set. |
| 4 (irreversible) | Full coverage — every named class plus production guards (deploys, external API calls, financial). |

The skill reads the reader's free-text use case for named irreversibility classes — *"I deploy with `terraform apply`"* becomes a `terraform apply` confirmation hook.

### Hook script shape

Each script is a tool-call filter that exits non-zero to block:

```bash
#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
if echo "$COMMAND" | grep -qE '<pattern>'; then
  echo "BLOCKED by <hook-name>: <reason>" >&2
  exit 1
fi
exit 0
```

The actual hook event name, matcher syntax, and stdin JSON shape come from Stage 2's fresh research — not from this template.

### Match patterns are specific or they're noise

Per hook, the skill specifies:

- Three concrete attack vectors or failure modes the pattern catches.
- Two legitimate operations that might false-positive; the regex excludes them or accepts the trade.
- A test fixture — three matching cases, three non-matching — at the bottom of the script, commented out, runnable.

A pattern that catches everything (`.*`) is useless. A pattern that catches nothing is decoration.

### Hooks are proposed, not installed

The skill never writes to `.claude/settings.json` or `.claude/hooks/` directly. The reader inspects, runs the test fixtures, copies into place. Install discipline is the reader's; the skill's job is the right files at staging paths.

### Reject messages match the reader's register

A hook that fires shows the reader its message on stderr. A message reading *"irreversibility class 4 violation"* to a reader who described their work in plain language gets the hook disabled. Reject messages mirror the register of the reader's free-text use case.

### What this specification produces

Stage 5 is now defined — per the reader's Reversibility target, between zero and a full set of `PreToolUse` hooks; each with specific match patterns, falsifiable test fixtures, reader-readable reject messages. All staged at `process-designer-output/hooks/`. The reader installs.

Next: verification.

---

## Phase 6 — specifying the verification the skill returns

Stage 4 has two halves. *Verify* checks the synthesised artifacts at synthesis time. *Evaluate* hands the reader a skeleton they run themselves at install time and afterwards.

### Verify at synthesis time

The skill runs three checks before declaring the artifacts ready:

- **Harness check.** Every harness-specific string in the artifacts — frontmatter fields, hook event names, settings keys, plus `tool_input.<field>` references in hook scripts — comes from Stage 2's research output, not training-data recall. The skill grep-checks against the cached `agent-capabilities.md` (including its per-tool `tool_input` table) and surfaces mismatches.
- **Coverage check.** Every Stage-1 dimension target maps to at least one calibration in at least one artifact. The skill produces a table of `(dimension, target, artifact-where-calibrated)`. Any row with no calibration is a gap.
- **Register check.** The artifacts read as the reader's own working documents — prose register matches the reader's free-text use case. A use case in plain language does not get a `CLAUDE.md` that says *"irreversibility surface."*

Mismatches surface to the reader before installation, not after.

### Evaluate at install time, then continuously

The eval set is a separate artifact the reader runs against the agent. It catches regressions when prompts, models, or skills change.

- Twenty representative queries from the reader's domain — not generic. *"Summarise this document"* is decoration; *"summarise this incident postmortem into a one-paragraph executive briefing preserving the named contributing factors"* is evaluable.
- A four-anchor scoring rubric per criterion.
- A results template the reader copies per run, dates the run, records the score.

### Query mix surfaces what changes

- About ten common tasks. These pass at high rates today; the eval catches regressions.
- About six edge cases. Known-difficult conditions; common failure modes. These fail today and improve over time.
- About four aspirational tasks. Things the reader wants the agent to do but currently doesn't. Failure targets.

Aim for roughly twelve of twenty passing at baseline — neither too easy nor too hard.

### Rubric criteria are orthogonal

Three default criteria, each on a four-anchor scale:

- **Correctness.** Did the output do what was asked?
- **Calibration.** Was confidence proportional to the actual epistemic state? Penalise confident-wrong.
- **Domain fit.** Did the output read as native to the reader's domain, or generic?

Per-use-case quality dimensions from Stage 1 add criteria up to a maximum of five. If two criteria always score the same, the skill collapses them.

### Eval-set size scales with Iteration cost

| Iteration cost | Eval-set size |
| --- | --- |
| 1–2 (cheap) | Full twenty. |
| 3 (day-constraining) | Ten to fifteen. Drop the most expensive aspirational queries. |
| 4 (real-world action) | Five to ten, carefully chosen. Eval cheap enough to run per change. |

### Run discipline is part of the eval-set

The eval-set's preamble names the discipline:

- Run baseline at install time. Record.
- Make one change at a time. Re-run. Record deltas.
- Re-baseline when configuration changes substantially.

Without the discipline, the skeleton is a list of queries with no measurement loop.

### What this specification produces

Stage 4 is now defined: a synthesis-time verification pass (harness / coverage / register) that surfaces mismatches before install, and an install-time eval skeleton (queries / rubric / results template / run discipline) the reader runs to catch regression. Stage 4's output is `process-designer-output/evals/eval-set.md` plus a verification report in the skill's closing summary.

Phases 1–6 complete. The design skill is fully specified.

Next: the install side.

---

## Phase 7 — specifying the install the companion skill executes

The synthesis spec (Phase 4) produces the artifacts plus the install contract. Phase 7 specifies the companion skill that consumes the contract — `/process-installer`. Without it, the reader pieces the install together by hand from `INSTALL.md`. With it, install is a single command, calibrated to the operator profile, with a verification pass.

### Why a separate skill, not a step inside `/process-designer`

Three reasons:

- **Different concern.** Design is interview plus synthesis; install is conflict survey plus execution. Mixing the two bloats the design skill and conflates *"what is the spec?"* with *"how is it deployed?"*.
- **Different invocation cadence.** The reader runs `/process-designer` once per design; they may run `/process-installer` multiple times — refinement reinstalls, eventual reinstalls at different scopes.
- **Different failure modes.** A bad install doesn't invalidate the design. Keeping them separate means the reader re-runs the install without re-running the (longer) synthesis.

### Constraints on the install skill

Fewer than the design skill's ten, and a different mix:

- **Mutual unverifiability** — the install agent doesn't know the reader's prior project state. Addressed by a *conflict survey* (Stage 4) before any write.
- **Reversibility** — the install is a sequence of writes. Addressed by *backups before overwriting* and `INSTALL_LOG.md` as a reversal trail.
- **Confident ≠ correct** — the install can claim success without actually working. Addressed by a *verification pass* (Stage 7).
- **Knowledge cut-off** — same harness-syntax risk as the design skill, but the install defers to the cached `agent-capabilities.md` the design skill already wrote. No fresh fetch on install.

Bound cognition and scarce time apply too — the install must be quick and not overload the reader. They're addressed by defaults and confirmation gates.

### Two classes of input the install consumes

- **The staged synthesis** at `process-designer-output/` — manifest, artifacts, install guide. Produced by `/process-designer` Phase 4.
- **The operator profile** at `.claude/operator-profile.md` — produced by `/process-designer` Phase 3. The install reads it to calibrate its own `AskUserQuestion` calls to the operator's fluency and register.

Cross-skill consistency: both skills calibrate to the same profile. The operator who saw plain-language preludes in the design interview gets plain-language preludes at install time.

### Eight stages, one per concern

Same decomposition discipline as the design skill's five stages: each stage does one job, has one output, gates the next.

| Stage | Job |
| --- | --- |
| 1 | Locate the staged output (`process-designer-output/manifest.json`) |
| 2 | Read manifest + operator profile; calibrate the interaction |
| 3 | Show the install plan; ask confirmation |
| 4 | Survey destination conflicts; ask confirmation |
| 5 | Prepare sketches (inject `disable-model-invocation: true`) |
| 6 | Execute (mkdir / cp / chmod / merge); log every action |
| 7 | Verify (test fixtures, parse checks, presence checks) |
| 8 | Optional cleanup of the staging folder |

Stages 3 and 4 are operator-confirmed; no surprise actions. Stage 6 logs every action to `INSTALL_LOG.md` so the install is reversible bottom-up. Stage 7 confirms the install before declaring success. Stage 8 asks before deleting anything — the staging carries documentation value.

### Sketches install disabled until gaps are filled

Each synthesised skill is a sketch — Section 6 of every SKILL.md lists *"gaps the reader fills."* A sketch that auto-fires on description match before the gaps are filled wastes the reader's time on flawed runs. Stage 5 injects `disable-model-invocation: true` into each sketch's frontmatter before placement. The sketches are discoverable via `/skill-name` invocation but won't auto-fire. The operator removes the flag after filling the gaps.

This is the default. Interactive gap-walking — the install asking the reader each gap and rewriting the SKILL.md — is a later-phase enhancement.

### Conflict policy preserves operator state

The install never clobbers what the operator already has:

- Existing `CLAUDE.md` at the project root is preserved; the staged copy stays at `process-designer-output/CLAUDE.md` for manual merge.
- Existing `.claude/settings.json` is backed up and merged, not replaced.
- Existing skill or hook directories are backed up to `<name>.bak.<timestamp>/` before fresh install.
- Runtime files (`NOTES.md`, `voice-fingerprint.md`, etc.) are left alone — the operator's state is sacred.

The conflict survey is shown to the operator at Stage 4; the install proceeds only on explicit confirmation.

### Verification uses a driver file, not direct piping

Stage 7 runs seven checks: skills discoverable with the disable flag, hooks executable, hook test fixtures fire correctly, `settings.json` parses, `CLAUDE.md` accounted for, runtime scaffolding present, `INSTALL_LOG.md` written.

Hook fixtures present a chicken-and-egg problem: the test fixtures contain destructive patterns (e.g., `rm -rf sources/`), and the very hooks they test scan `Bash` invocations. Piping fixtures directly through the outer `Bash` tool call triggers the hook on the outer call. The install writes the fixtures to a driver file (`.verify-install.sh`) at the project root; the outer `Bash` invocation sees only the filename. Where even the file-creation invocation would trip a hook, destructive patterns are assembled at runtime from innocuous tokens (e.g., `RM=$(printf 'r''m')`) so the heredoc that writes the driver is also hook-clean.

### What this specification produces

`/process-installer` defined as eight stages, three classes of input (staged synthesis + operator profile + existing project state), one closing brief calibrated to the operator profile, one reversal trail at `INSTALL_LOG.md`, one optional cleanup decision at the end. The skill ships at `skills/process-installer/`.

Next: assembly.

---

## Phase 8 — assembling the skill files

Phases 1–7 specified the system. Phase 8 writes the actual files. The design skill's Stage 2 *Research* is invoked here: both skills' bodies must use the harness's current syntax, not training-data recall.

### File tree the two skills install as

```
skills/
├── process-designer/                # the design skill (Phases 1–6 specified)
│   ├── SKILL.md                     # entry point; the five-stage flow
│   ├── dimensions.md                # six universal dimensions, four-anchor rubrics
│   ├── references/
│   │   ├── methods.md               # README's Methods × Constraints map, embedded
│   │   ├── capability-discovery.md  # structural guidance for Stage 0's fetch
│   │   ├── operator-profile.md      # register and fluency taxonomies; cached file shape
│   │   └── synthesis-templates/
│   │       ├── claude-md.md         # structural guidance for the CLAUDE.md artifact
│   │       ├── skill-sketch.md      # structural guidance for skill sketches
│   │       ├── hook-config.md       # structural guidance for hooks
│   │       ├── eval-skeleton.md     # structural guidance for evals
│   │       ├── manifest.md          # structural guidance for the install manifest
│   │       └── install-md.md        # structural guidance for the manual install guide
│   └── scripts/
│       ├── check-capability-freshness.sh
│       └── check-operator-freshness.sh
└── process-installer/                 # the install skill (Phase 7 specified)
    └── SKILL.md                     # entry point; the eight-stage flow
```

Every reference inside each skill folder is reachable from that skill at install time. No paths leak between skills or outside the folders.

### `SKILL.md` is the entry point, short

Frontmatter (`name`, `description`, `allowed-tools`) plus the five-stage flow plus a quality bar. Around 150 lines.

The body does not duplicate `dimensions.md` or the synthesis templates — it points to them. Progressive disclosure: the agent reads the entry, loads what it needs, runs.

### `dimensions.md` is the rubric reference

Six dimensions, each a heading. Per dimension: a one-sentence framing, a four-anchor rubric in a small table, a one-line synthesis implication. Read by Stage 1 of the skill, one dimension at a time.

### `references/methods.md` embeds the Constraints × Methods map

The skill cannot rely on `../../../README.md` at install time — the reader's working directory is unknown. The Methods × Constraints map from README §211 is embedded inside the skill so the synthesis cites it locally.

### `references/synthesis-templates/*` are structural guidance, not Mad Libs

One file per artifact. Each names what to consider per section, how the dimensions calibrate it, what the readiness check is. The synthesis writes fresh prose; the templates do not interpolate placeholder slots.

### `references/capability-discovery.md` shapes Stage 2's fetch

The structure of the cached `.claude/agent-capabilities.md`: which URLs to fetch, which categories to cover, what counts as fresh (seven days), and a per-tool `tool_input` table so hook scripts can reference `.tool_input.file_path` for `Write` / `Edit` without inferring from the `Bash` example. Stage 2 reads this; the output is the cached reference file.

### `scripts/check-capability-freshness.sh` is the deterministic freshness check

Reads `.claude/agent-capabilities.md`, parses the `last-fetched` line, exits 0 if within seven days, 1 otherwise. The agent calls the script instead of reasoning about ISO dates inline.

### Frontmatter uses the current SKILL.md schema

Fetched fresh at build time. Fields and valid `allowed-tools` values are recorded in `references/capability-discovery.md` and used by the synthesis templates when the skill produces sketches for the reader's own skills. If the schema shifts, only the cached reference and the templates need updating; the rest of the skill stays the same.

### What this assembly produces

Both skill folders. `skills/process-designer/` contains thirteen files (~1,300 lines) — SKILL.md, dimensions.md, six synthesis templates, the methods + capability-discovery + operator-profile references, and the two freshness scripts. `skills/process-installer/` contains one file (~280 lines) — the SKILL.md with the eight-stage flow inline. Total system surface: ~1,580 lines across the two skills.

Next: wire into README.

---

## Phase 9 — wiring into `README.md`

The walkthrough is the artifact that makes Level 3 concrete. Phase 9 makes it reachable from the reader's entry point.

### Two README edits

- The Level 3 bullet in the comfort-level list gains a parenthetical pointer to this walkthrough.
- The closing *"The process (WIP)"* placeholder is replaced with a one-line framing and a link to this walkthrough.

The skill folder remains linked as before. Walkthrough and skill play different roles: the skill is what the reader installs; the walkthrough is what teaches them why the skill is shaped the way it is.

### Pointer direction

The skill's `SKILL.md` carries no link back to the walkthrough — install-time portability would break the path. The walkthrough's *see also* section points at the skill. Readers reaching the skill folder via README know the skill is the artifact; readers reaching the walkthrough know the skill is downstream.

---

## Phase 10 — finalising the build

### The two skills are installable in sequence

The reader copies `skills/process-designer/` and `skills/process-installer/` to `~/.claude/skills/` (or leaves them in-repo for project use) and invokes them in order:

1. `/process-designer` — runs the five-stage design flow (Stage 0 refreshes `.claude/agent-capabilities.md` on first invocation; within seven days the refresh is skipped). Output stages at `process-designer-output/`.
2. `/process-installer` — runs the eight-stage install flow against that staging. Output lands under the reader's project. The closing brief points at the gap-filling work and the eval baseline as the natural next steps.

Cross-skill state lives in `.claude/operator-profile.md` (calibration) and `.claude/agent-capabilities.md` (harness facts). Both files are read by the design skill at design time and by the install skill at install time; both persist across sessions.

The first iteration of the install skill ships project-local scope only. Hybrid + user-global scope, interactive sketch-gap-walking, repeat-install detection, and `uninstall.sh` generation are natural extensions that can land later without re-touching `/process-designer`.

### The walkthrough is what the reader's recursion looks like

A reader who reads the clinic, picks their own use case, and follows the ten phases against their use case produces *their* skills — the design skill that interviews them about variants of the task, and the install skill that lands the resulting spec. The walkthrough is the worked example; the reader's two skills are the level-3 artifact.

The recursion is concrete. Trust the process.

---

## See also

- [`../../skills/process-designer/`](../../skills/process-designer/) — the design skill this walkthrough produced.
- [`../../skills/process-installer/`](../../skills/process-installer/) — the companion install skill.
- [`../../README.md`](../../README.md) — the clinic the walkthrough grounds in.
- [`../odder/`](../odder/) — the Level 2 worked example.