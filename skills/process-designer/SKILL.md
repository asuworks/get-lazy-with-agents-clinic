---
name: process-designer
description: Walks a clinic reader from a stated use case to a working agent process. Produces a CLAUDE.md, one to three skill sketches, a hook config, and an eval skeleton — all calibrated to the reader's six dimension targets plus 2–4 use-case-specific quality dimensions. Use when the reader asks to "design a process for working with AI agents," "set up my agent workflow," "build me a process for X," or invokes /process-designer.
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash, WebSearch, WebFetch
---

# process-designer

A reader brings a use case; this skill produces a personalised process specification. It walks the reader through six universal dimensions plus 2–4 use-case-specific quality dimensions, then synthesises four artifacts staged at `process-designer-output/`.

Every constraint a human–AI process faces maps to a method in [`references/methods.md`](references/methods.md); the synthesis composes the methods into the artifacts.

## What the skill produces

Under `process-designer-output/` in the reader's working directory:

- `CLAUDE.md` — calibrated to the six dimension targets plus any use-case quality targets.
- `skills/<name>/SKILL.md` — one to three skill sketches for laborious recurring work.
- `hooks/settings-snippet.json` plus `<hook-name>.sh` files — scaled to the reader's Reversibility target.
- `evals/eval-set.md` — twenty representative queries plus a four-anchor scoring rubric, sized by Iteration cost.

A reusable reference goes to the reader's `.claude/`:

- `.claude/agent-capabilities.md` — dated snapshot of harness facts (SKILL.md schema, hook events, settings shape).

## The five-stage flow

Run in order. Stage 0 is a prerequisite the others depend on.

### Stage 0 — Capability discovery (cached, prerequisite)

The harness's SKILL.md schema, hook event names, and `AskUserQuestion` option limit may have shifted since training. Stage 0 grounds the skill in current facts.

Check freshness:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/check-capability-freshness.sh"
```

Exit 0 → fresh (≤7 days). Proceed to Stage 1.
Exit 1 → stale or missing. Refresh via `WebFetch` over the categories in [`references/capability-discovery.md`](references/capability-discovery.md), then write the synthesised reference to `.claude/agent-capabilities.md` (create `.claude/` first with `mkdir -p .claude`).

Source preference: official Claude Code docs at `https://code.claude.com/docs/en/...` over blog posts. Record `last-fetched` ISO date and source URLs at the top of the file.

### Stage 1 — Interview the reader

The reader brings the intent; this stage extracts the calibration data the synthesis needs. See [`dimensions.md`](dimensions.md) for the canonical rubrics and [`references/operator-profile.md`](references/operator-profile.md) for the register and fluency taxonomies.

1. **Use-case paragraph.** Ask the reader to describe their use case in a paragraph — free text. The paragraph carries the substance and supplies the vocabulary substrate (specific nouns, verbs, named artifacts) for downstream synthesis. It also supplies the *default* register signal for step 4.

2. **Operator profile cache check.**

   ```bash
   bash "${CLAUDE_SKILL_DIR}/scripts/check-operator-freshness.sh"
   ```

   Exit 0 → fresh (≤30 days). Read `.claude/operator-profile.md` and surface the cached `fluency` and `register` to the reader via `AskUserQuestion`: *"Use this profile, or update?"* Options: *Use it / Update fluency / Update register / Update both*. If *Use it*, carry the cached values into step 5 and skip steps 3 and 4. Otherwise act on the choice — ask only the field(s) being updated.

   Exit 1 → stale or missing. Proceed to steps 3 and 4 (ask both fresh).

3. **Fluency.** *"How familiar are you with designing AI-agent processes?"* Four anchors — see [`references/operator-profile.md`](references/operator-profile.md) for full anchor descriptions:

   - **New** — first time designing an AI-agent process.
   - **Aware** — has used agent tooling; hasn't designed processes from scratch.
   - **Practitioner** — designs and tunes agent processes in workflow.
   - **Fluent** — architects multi-agent systems; knows the clinic vocabulary cold.

   Fluency drives the explainer-prelude depth in step 5.

4. **Register.** *"What register should the system use when communicating with you?"* Affects the agent's tone in responses, hook reject messages, eval rubric wording, and the install guide. **Does not** affect bash logic in hook scripts, the machine-readable `manifest.json`, or the agent's tool choices. Four anchors — see [`references/operator-profile.md`](references/operator-profile.md):

   - **Plain** — minimal jargon; analogies welcome.
   - **Professional** — standard work language; some terminology with brief unpacking.
   - **Technical** — precise terms-of-art; assumes professional context. *Default for the typical clinic reader.*
   - **Specialist** — full practitioner jargon; assumes deep familiarity.

   Infer the reader's likely register from their step-1 paragraph; surface that as the recommended option but let the reader override. The reader's *audience register* can diverge from the paragraph register — explicit override matters when the paragraph reads technical but the artifacts will be read by non-technical teammates. Register drives the artifact voice in Stage 2 and the anchor translation in step 5.

5. **Six universal dimensions.** **One dimension per `AskUserQuestion` call** — do not batch. Per dimension, apply five per-fluency adaptations on top of the use-case translation:

   - **Read** [`dimensions.md`](dimensions.md) for the four-anchor *semantic* scale.
   - **Translate** the question stem and each anchor's wording into the reader's use case using nouns, verbs, and named artifacts from their step-1 paragraph. Semantic content stays fixed.
   - **Adapt the question stem per fluency.**
     - *New* — rephrase entirely in everyday terms; do **not** name the dimension ("Reversibility").
     - *Aware* / *Practitioner* — name the dimension with brief context.
     - *Fluent* — name the dimension directly.
   - **Adapt the `AskUserQuestion` option labels per fluency.**
     - *New* — rephrase anchor labels in everyday vocabulary; hide clinic terms.
     - *Aware* / *Practitioner* — light gloss on clinic anchors.
     - *Fluent* — clinic anchor labels direct.
   - **Adapt the prelude per fluency.**
     - *New* — 2–3 sentence prelude with a worked example from the reader's use case. Surface a recommended default if a common one applies.
     - *Aware* — one-sentence framing plus one-sentence example.
     - *Practitioner* — one-sentence framing.
     - *Fluent* — no prelude.
   - **Adapt suggestions per fluency.**
     - *New* — surface a recommended default ("most readers like you pick 2 here").
     - *Aware* / *Practitioner* — recommended default is optional.
     - *Fluent* — no default surfaced; the question alone.

   The register (step 4) and the use-case vocabulary (step 1) layer on top of these adaptations — *plain*-register surface words go into a *new*-fluency rephrasing as easily as into a *fluent*-fluency one.

   Order: Reversibility → Domain distance → Iteration cost → Autonomy → Memory horizon → Parallelism.

   *Worked examples — Reversibility for the blog-workflow paragraph.*

   At *Practitioner* fluency + *Technical* register:

   > *Reversibility is about how recoverable mistakes are in your work.*
   >
   > *"How recoverable are mistakes in your blog workflow?"*
   > - 1 — *"Throwaway drafts you never save."* (anchor: pure exploration)
   > - 2 — *"Drafts in your notes folder or unpushed branch — scrap anytime."*
   > - 3 — *"Draft committed to the blog repo where the editor sees it."*
   > - 4 — *"Published to the live blog where readers see it."*

   At *New* fluency + *Plain* register, the same dimension is asked entirely differently — the word *Reversibility* never appears, and a recommended default is named:

   > *Quick context: I want to know how bad it is when something goes wrong in your blog work. Some mistakes you can just undo; others are out there for good once they happen. For example, deleting a draft you can always retype, but a typo that goes live on Monday is harder. Most weekly bloggers pick option 2 here.*
   >
   > *"When something goes wrong in your blog work, how hard is it to fix?"*
   > - 1 — *"No big deal — just a draft I was playing with."*
   > - 2 — *"I can undo it — drafts in my notes, not pushed anywhere."*
   > - 3 — *"My editor would see the bad version before I could fix it."*
   > - 4 — *"Already out on the live blog where readers can see it."*

   Same semantic scale; very different surface for a very different operator.

   **Mid-interview re-calibration.** After 2–3 dimensions, if a *new*-fluency operator is answering quickly and naming clinic terms unprompted, offer to bump fluency to *Aware* or *Practitioner*. If a *fluent*-fluency operator hesitates or asks for clarification, offer to step down. Adjusting fluency mid-interview is cheaper than redoing the whole interview.

6. **Use-case quality dimensions.** Reason from the paragraph; generate two to four. Apply the same per-fluency adaptations as step 5 (question stem, option labels, prelude, suggestions) plus the per-register translation.

   **For *new* fluency operators**, offer to defer this sub-step to the refinement loop:

   > *"You've answered six dimensions about the work itself. I can also generate two to four use-case-specific quality dimensions — things like reproducibility, tone fidelity, or how cleanly your output reads. Or we can skip them now and revisit after you see the first draft. Defer?"*

   For *aware / practitioner / fluent* operators, run the sub-step inline without the defer offer.

   If the use case is too generic to support quality dimensions at any fluency, skip the sub-step entirely rather than invent decorative dimensions.

7. **Persist the operator profile.** Write `.claude/operator-profile.md` with `last-confirmed: <today>`, `fluency: <level>`, `register: <level>`, and a short notes section pointing at the use-case slug. Create `.claude/` if needed (`mkdir -p .claude`). See [`references/operator-profile.md`](references/operator-profile.md) for the file shape.

8. **Record.** The use-case paragraph, the operator profile (fluency + register), and the `(dimension, target-anchor)` table feed Stage 2.

Target ten minutes for a typical Stage 1; longer for *New* fluency because the preludes are expanded; shorter for repeat-runs with a fresh cached profile.

### Stage 2 — Synthesise the artifacts plus the install contract

Read:

- Stage 1's results.
- Stage 0's fresh harness facts (`.claude/agent-capabilities.md`).
- The operator profile (`.claude/operator-profile.md`) for the register and fluency that drive artifact voice.
- The synthesis templates at [`references/synthesis-templates/`](references/synthesis-templates/).
- The Constraint × Method map at [`references/methods.md`](references/methods.md) for citation in `CLAUDE.md`.

The operator's register propagates only to *human-facing surfaces*: the voice and conventions section of `CLAUDE.md` (which propagates further to the agent's responses to the human), hook reject messages on stderr, eval rubric anchors, the install guide, and human-facing comments in skill sketches. The bash logic in hooks (`grep`, `exit 2`) and the JSON of the manifest are register-neutral.

The synthesised `CLAUDE.md` also carries an *Operator-aware interaction* section that instructs the runtime agent to read `.claude/operator-profile.md` every session and calibrate every `AskUserQuestion` call, suggestion, and explainer per the recorded fluency + register. This makes the operator profile a *live* part of the installed process — the operator can update `.claude/operator-profile.md` directly to change calibration without re-running `/process-designer`. See [`references/synthesis-templates/claude-md.md`](references/synthesis-templates/claude-md.md) §9 for the section's structure.

Create the output tree:

```bash
mkdir -p process-designer-output/skills process-designer-output/hooks process-designer-output/evals
```

Generate one artifact at a time (or fan out across sub-agents for the dense case):

- **CLAUDE.md** — guidance at [`references/synthesis-templates/claude-md.md`](references/synthesis-templates/claude-md.md). Calibrated by Autonomy, Reversibility, Domain distance, Memory horizon, and use-case quality dimensions.

- **Skill sketches** — guidance at [`references/synthesis-templates/skill-sketch.md`](references/synthesis-templates/skill-sketch.md). One to three sketches for laborious recurring work surfaced by the use case. Each sketch is a SKILL.md outline with explicit *"gaps the reader fills."*

- **Hook config** — guidance at [`references/synthesis-templates/hook-config.md`](references/synthesis-templates/hook-config.md). Number of hooks scales with Reversibility (0 / 1–2 / 2–3 / full). Hook event names, matcher syntax, and stdin shape come from `agent-capabilities.md`, not memory.

- **Eval skeleton** — guidance at [`references/synthesis-templates/eval-skeleton.md`](references/synthesis-templates/eval-skeleton.md). Twenty queries by default, sized down for high Iteration cost. Three default criteria plus use-case quality criteria up to five total.

- **`manifest.json`** — guidance at [`references/synthesis-templates/manifest.md`](references/synthesis-templates/manifest.md). Machine-readable install contract: every artifact's source path and destination(s), dimension targets, runtime paths the `CLAUDE.md` references, per-sketch gap lists. Written to `process-designer-output/manifest.json`. Consumed by a guided installer; also readable by hand.

- **`INSTALL.md`** — guidance at [`references/synthesis-templates/install-md.md`](references/synthesis-templates/install-md.md). Per-process manual install guide. Numbered steps from *"pick scope"* through *"verify."* Written to `process-designer-output/INSTALL.md`. The reader follows this when installing by hand.

**Existing `CLAUDE.md`**: if one already exists in the working directory, still write to `process-designer-output/CLAUDE.md` and note in the closing summary that the reader merges manually. Never overwrite.

### Stage 3 — Verify the synthesis

Three checks before declaring the artifacts ready:

- **Harness check.** Grep each artifact for harness-specific strings — frontmatter field names, hook event names, settings keys, **and `tool_input.<field>` paths in any hook script**. Confirm each appears in `.claude/agent-capabilities.md`, including the per-tool `tool_input` table (§3a). A hook script that reads `.tool_input.file_path` without the table confirming `file_path` is a `Write` / `Edit` field is a flag — verify or correct it.
- **Coverage check.** Produce a table of `(dimension, target, artifact-where-calibrated)`. Any row with no calibration is a gap.
- **Register check.** Confirm the synthesised `CLAUDE.md` matches the register of the reader's use-case paragraph. A plain-language paragraph should not get a `CLAUDE.md` saying *"irreversibility surface."*

Surface mismatches before the refinement loop runs.

### Stage 4 — Refinement loop

Summarise to the reader:

- Each dimension and target.
- Each use-case-specific dimension generated.
- All six outputs produced, by path (four artifacts + `manifest.json` + `INSTALL.md`).
- One sentence per artifact on how dimension values shaped it.
- Stage 3's verification results.

Then ask via `AskUserQuestion`: *"Adjust any dimension targets and regenerate?"*

If the reader adjusts targets, repeat Stage 2 with new values (manifest and `INSTALL.md` regenerate alongside). Up to three refinement passes per session; after that, suggest manual editing of the staged artifacts.

### Closing handoff

Once the reader accepts the synthesis, surface the install paths and stop:

- **Guided** (recommended) — run `/process-installer` from this folder. It reads `manifest.json`, surveys destination conflicts, copies the artifacts to `.claude/`, scaffolds the runtime files, and verifies the install. Calibrates its own interaction to the operator profile.
- **Manual** — follow `process-designer-output/INSTALL.md` step by step.
- **Programmatic** — read `process-designer-output/manifest.json` and script the install yourself.

The skill ends here. The install is the reader's next step; do not attempt to install the artifacts as part of this invocation.

## Quality bar

The skill is doing its job well when:

1. `.claude/agent-capabilities.md` exists and is fresh; synthesis quotes from it.
2. Stage 1 completes in under ten minutes for the typical case.
3. The synthesised `CLAUDE.md` reads as the reader's own working document — register matches the use-case paragraph.
4. Hook recommendations are scaled to the reader's stated Reversibility — no generic boilerplate.
5. Eval queries are recognisably from the reader's domain, not generic.
6. The reader installs the artifacts with at most minor edits.

## Anti-patterns

- **Verbatim anchor wording.** Anchors copy-pasted from `dimensions.md` into the `AskUserQuestion` options read as if the use case wasn't given. Translate each anchor into the reader's vocabulary using Stage 1's free-text paragraph.
- **Batching dimensions.** Putting two or more dimensions into one `AskUserQuestion` call drifts the reader's calibration between them. One dimension per call.
- **Ignoring fluency.** A *new* reader getting terse questions with no examples freezes up; a *fluent* reader getting verbose preludes gets frustrated. Calibrate the prelude depth per the fluency reading from Stage 1's step 2.
- **Skipping Stage 0.** Synthesising from training-data knowledge of SKILL.md schema or hook events. Refresh first; harness churn is the load-bearing fact.
- **Overwriting existing `CLAUDE.md`.** Always stage at `process-designer-output/CLAUDE.md`. Overwrite is irreversible to the reader.
- **Generating use-case dimensions that don't earn their place.** Skip the sub-step rather than invent decorative dimensions.
- **Mad-Libs synthesis from templates.** Templates are structural guidance. Write fresh prose per artifact.
- **Hiding the calibration table.** Surface the dimension-to-artifact map in Stage 4; let the reader verify the synthesis matched intent.

## See also

- [`dimensions.md`](dimensions.md) — six universal dimensions with four-anchor rubrics.
- [`references/methods.md`](references/methods.md) — Constraint × Method table.
- [`references/capability-discovery.md`](references/capability-discovery.md) — Stage 0 fetch structure.
- [`references/synthesis-templates/`](references/synthesis-templates/) — structural guidance per artifact.
