# Dimensions — the six universal rubrics

The six dimensions a `/process-designer` invocation calibrates. Each has a four-anchor rubric matched to `AskUserQuestion`'s four-option ceiling. Each section closes with the synthesis implication — what changes downstream when the reader's target moves.

The rubrics here are at *technical* register. The skill mirrors the reader's free-text use-case paragraph when presenting them; the canonical wording stays here.

---

## 1. Reversibility — recoverability of mistakes

| Rating | Label | Description |
| --- | --- | --- |
| **1** | Pure exploration | Mistakes cost nothing. Sandbox; output discarded after evaluation. |
| **2** | Local artifacts | Changes touch files in a scratch directory or feature branch; `git stash` or branch-delete recovers all of it. |
| **3** | Visible to teammates | Changes commit to shared branches, deploy to staging, or affect shared state. Recoverable via revert / rollback, but seen. |
| **4** | Irreversible | Production deploys, external communications, financial transactions, destructive filesystem operations. Mistakes persist. |

*Synthesis implication.* Hook coverage scales: 0 hooks at 1; 1–2 at 2; 2–3 at 3; full coverage at 4. `CLAUDE.md` gains explicit *"never without confirmation"* entries at 3–4.

---

## 2. Domain distance — coverage in the LLM's training

| Rating | Label | Description |
| --- | --- | --- |
| **1** | Mainstream | Well-trodden territory. Popular language, common framework, mainstream domain. Training is dense here. |
| **2** | Niche but documented | Mainstream with niche aspects, or niche with good public documentation. Surface coverage; depth needs grounding. |
| **3** | Specialised or recent | Specialised domain, recent topic, or thin documentation. Most depth claims need retrieval before action. |
| **4** | Proprietary or yours | Your specific codebase, post-cutoff knowledge, contested-mainstream views, or proprietary domain. Distrust by default. |

*Synthesis implication.* `CLAUDE.md` gains grounding directives — *"for any claim about [domain], fetch source first"* — at 3–4. Eval queries test domain fit at 4.

---

## 3. Iteration cost — cost per experiment cycle

| Rating | Label | Description |
| --- | --- | --- |
| **1** | Seconds | Run a script; observe output; adjust. Eval loop is cheap; iterate freely. |
| **2** | A minute or two | Build + test cycle on a small project; light cloud calls. Iteration still cheap on practitioner-time scale. |
| **3** | Minutes to hours | Full test suite, container build, deploy-and-observe; eval cycle constrains the day. |
| **4** | Real-world action | Hours to days. Money, commitment, live-user experimentation, irreversible decisions per cycle. |

*Synthesis implication.* Eval-set size — twenty at 1–2; ten to fifteen at 3; five to ten at 4. Hypothesis-first iteration discipline tightens at 4.

---

## 4. Autonomy — required agent oversight

| Rating | Label | Description |
| --- | --- | --- |
| **1** | Always review | Every action reviewed before commit. The agent proposes; you approve each step. |
| **2** | Bundled review | The agent proposes a block of work; you approve after a short review. |
| **3** | Milestone gates | Review at named milestones. The agent runs OODA loops with you checking in at gates. |
| **4** | Autonomous | Fully autonomous within a bounded task class. Final result reviewed; outcome audit. |

*Synthesis implication.* `CLAUDE.md`'s decision-authority section: explicit *"never without confirmation"* list at 1–2; named milestone gates at 3; high-trust default + non-negotiable surface at 4.

---

## 5. Memory horizon — state persistence across sessions

| Rating | Label | Description |
| --- | --- | --- |
| **1** | Single conversation | Each session is standalone; nothing has to survive a `/quit`. |
| **2** | Same-day | Sessions chain across hours; `CLAUDE.md` plus minimal notes suffice. |
| **3** | Multi-day to weeks | A `NOTES.md` carries state; `/compact` and `/quit` discipline matters; the project has a memory architecture. |
| **4** | Long-running | Months-to-quarters of state; an evolving `CLAUDE.md` lineage. Memory IS the architecture. |

*Synthesis implication.* `CLAUDE.md`'s "where to read" pointers grow at 3–4. `NOTES.md` / `HANDOFF.md` / `decisions/` directives appear at 3–4.

---

## 6. Parallelism — single agent, sub-agents, or ensemble

| Rating | Label | Description |
| --- | --- | --- |
| **1** | Single agent | One agent, one conversation. The simplest architecture. |
| **2** | Sub-tasks on demand | One agent that occasionally invokes a sub-agent for bounded sub-tasks, returning to the main thread. |
| **3** | Orchestrator-workers | Sub-agents on independent directions; condensed returns; the multi-agent pattern at modest fan-out (3–5 workers). |
| **4** | Parallel ensemble | Population of configurations; eval-driven culling; fitness-based selection. |

*Synthesis implication.* Skill sketches for sub-agent orchestration at 3–4. Eval infrastructure for fitness scoring at 4.

---

## Why four anchors

`AskUserQuestion` accepts a maximum of four options per call. Each rubric fits one call. A five-anchor rubric would need two calls; the reader's calibration drifts between them. The current limit lives in [`references/capability-discovery.md`](references/capability-discovery.md) and is re-verified at each Stage 0 refresh — if the limit ever rises, the rubrics can extend.

## Per-use-case quality dimensions

The six above describe *process architecture*. Beyond them, the skill generates 2–4 use-case-specific *quality* dimensions per the reader's stated case — *reproducibility* for notebooks, *tone fidelity* for customer email, *blamelessness* for postmortems. These are not pre-listed; the skill reasons them from the use-case paragraph.

Each generated quality dimension takes the same shape: four anchors, framing in one sentence, synthesis implication.

If the use case is too generic to support quality dimensions, the skill says so and skips this sub-step rather than invent decorative dimensions.
