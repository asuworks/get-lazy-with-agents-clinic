# Methods and constraints — local copy

The skill's local copy of the framework that the clinic's `README.md` introduces in *Why Human+AI collaboration fails*, *Process Methods*, and the *Constraint → Method map*. Embedded here so the synthesis cites the framework without depending on the reader's working-directory layout.

---

## Constraints a Human–AI process faces

### Human-side constraints

1. **Bound cognition.** Finite working memory; multi-tasking overhead. The practitioner's environment now produces output faster than this invariant can absorb.
2. **Scarce time.** The practitioner's hour is the scarcest resource. Tokens are cheap; compute is cheap; the salaried hour is not.
3. **Unknown unknowns.** The map of relevant considerations is incomplete in ways the planner cannot enumerate from inside the map.

### Agent / LLM-side constraints

1. **Context size.** Finite window; recall degrades before the nominal limit (context rot).
2. **Knowledge cut-off.** Bounded by training data; bias against niche and recent material.
3. **Confident ≠ correct.** Surface confidence is fluency, not truth. The model has no separate epistemic module that audits its output.
4. **Non-determinism.** Same input produces different outputs. A prompt is a probability distribution, not a function.
5. **Security exposure.** The agent writes files, fetches the web, runs shell. Each is a surface.
6. **Field churn.** Tools, models, harnesses move quarterly. The thinking patterns underneath move much more slowly.

### Systemic constraints

1. **Mutual unverifiability.** Neither party fully verifies the other's epistemic state from inside the conversation. Verification must live outside the conversation — in tests, tool calls, second opinions, hooks.

---

## The nine methods

Methods are moves; constraints are forces. Each method addresses one or more constraints. Methods stack.

### Decompose — chunk a task into agent-shaped parts

One omnibus prompt fits neither working memory nor context. Identify the parts; run them as separate prompts. Each part: one input, one output, one checkable result.

### Hand off — delegate a task end-to-end

Give the agent full context, authority limits, a stopping condition. Don't give it implicit assumptions or anything irreversible. The user reviews the diff, not the loop.

### Session hand-off — bridge state across sessions

A session ends; the agent forgets. Externalise the state into a document the next session reads. The cheapest form of session-spanning memory.

### Sub-agents — spawn fresh contexts in parallel

Exploration eats parent context. Move it into a child with a fresh window. The parent reads the summary; the noise stays in the child. Bad fit for back-and-forth tasks — keep those in the parent.

### Verify — run the test, don't trust the report

LLM fluency reads as confidence. Confidence is not evidence. Better: a deterministic gate that refuses *done* until the test command exits zero.

### Interview — surface the meta-frame before acting

Unknown unknowns and mutual unverifiability — same move: surface silent premises before acting on them. Aim for ~98% understanding. Minutes spent here; the work that follows lands.

### Research — refresh on cut-off and churn

Training cut-off is in the past. The field changes quarterly. Memory of an API is a guess. Anything that touches the harness, an API, or a public service — research it first.

### Evaluate — score the process across runs

A single output is a draw from a distribution, not a measurement. To measure: N draws, criteria, a score. Without the eval, you can't tell which variant moves 6/10 to 8/10.

### Hooks — gate agent actions at the harness layer

The agent cannot police itself — prompts can be ignored, paraphrased, hijacked. Hooks sit below the model and intercept every tool call. Configuration, not prompt.

---

## Constraint → Method table

| Constraint family | Constraint | Primary method | Stacks well with |
| --- | --- | --- | --- |
| Human | Bound cognition | **Decompose** | Hand off |
| Human | Scarce time | **Hand off** | Decompose, Verify |
| Human | Unknown unknowns | **Interview** | Research |
| Agent | Context size | **Decompose** | Sub-agents, Session hand-off |
| Agent | Session boundary | **Session hand-off** | Decompose |
| Agent | Exploration cost | **Sub-agents** | Decompose |
| Agent | Knowledge cut-off | **Research** | Verify |
| Agent | Confident ≠ correct | **Verify** | Hooks, Interview |
| Agent | Non-determinism | **Evaluate** | Verify |
| Agent | Field churn | **Research** | Interview |
| Systemic | Mutual unverifiability | **Interview** | Verify, Hooks |
| Systemic | Security exposure | **Hooks** | Verify |

The synthesis cites this table when explaining *why* a specific calibration appears in `CLAUDE.md` or `hooks/`.

---

## Mutual amplification — the goal the methods serve

A process built well does not ask the agent to be reliable. It asks the agent to be useful, and asks the *system around the agent* to be reliable.

The human supplies intent, judgment, decision-making, domain taste, stakes awareness — what humans are good at. The agent supplies language, coverage, option generation, domain knowledge, parallel context, tireless thoroughness — what agents are good at. The methods compose so that each side reinforces what the other is best at, and neither tries to do the other's work.

Whenever a human is doing what an agent could do, given the right context, the process is not yet amplifying. The synthesised artifacts make the boundary visible.
