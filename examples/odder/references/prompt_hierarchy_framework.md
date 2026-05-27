# Hierarchical Prompt Generation Framework

## Formal Definition

A **prompt hierarchy** of depth *N* is a sequence of (context, prompt) pairs:

```
Level 0:  p₀ = "do X"                                    — naive prompt
Level 1:  p₁ = f(c₀, p₀)                                — contextualized prompt
Level 2:  p₂ = g(c₁) → p₁                               — meta-prompt (generates p₁)
Level 3:  p₃ = h(c₂) → p₂                               — meta²-prompt (generates p₂)
  ...
Level N:  pₙ = φ(cₙ₋₁) → pₙ₋₁
```

Where:

| Symbol | Name | Role |
|--------|------|------|
| **X** | Task | The thing you ultimately want done |
| **pₙ** | Level-N prompt | The instruction at abstraction level N |
| **cₙ** | Level-N context | Principles/knowledge that govern generation at level N+1 |
| **f, g, h, φ** | Generation functions | The LLM call that transforms (context, lower-prompt) into a prompt |

**Key invariant:** Each `cₙ` answers a different question:

| Context | Question it answers |
|---------|-------------------|
| c₀ | *"What do I need to know to do X well?"* — domain knowledge |
| c₁ | *"What makes a good prompt that does X?"* — prompt engineering principles |
| c₂ | *"What makes a good prompt-generator for this class of X?"* — meta-generation principles |
| c₃ | *"What makes a good framework for generating prompt-generators?"* — architectural principles |

**Observation:** As N increases, contexts shift from **domain-specific** → **structural/procedural** → **epistemological/architectural**. The higher you go, the more the context is about *form* rather than *content*.

---

## Example 1: "What is the weather in Phoenix?"

A deliberately simple X to show that even trivial tasks have non-trivial depth.

### Level 0 — Naive Prompt

| Component | Content |
|-----------|---------|
| **p₀** | "What is the weather in Phoenix?" |
| **Output** | A vague or outdated answer, no source, ambiguous "Phoenix" |

### Level 1 — Contextualized Prompt

| Component | Content |
|-----------|---------|
| **c₀** | Domain context: Phoenix AZ (not Phoenix OR or the mythological bird). User wants *current* conditions. Useful weather info includes: temperature, humidity, wind, UV index, air quality (dust storms are common). User is in the Phoenix metro area. Preferred units: Fahrenheit. |
| **p₁** | "You are a weather assistant for a user in Phoenix, Arizona. Provide current conditions including temperature (°F), humidity, wind speed/direction, UV index, and any active weather advisories (especially dust storms or excessive heat warnings). Use a reliable real-time data source. Be concise." |
| **Output** | Accurate, localized, actionable weather report |

### Level 2 — Meta-Prompt (generates p₁)

| Component | Content |
|-----------|---------|
| **c₁** | Prompt engineering principles for real-time factual queries: (1) Specify the data source or tool to use (web search, API). (2) Disambiguate named entities. (3) Define output schema — what fields matter for this domain. (4) Set persona/tone. (5) Declare units and locale. (6) Include edge cases (seasonal hazards, time-of-day relevance). (7) Constrain verbosity. |
| **p₂** | "Given a user's location and the type of real-time information they need, generate a prompt that: disambiguates the location, specifies the data source, lists the exact output fields relevant to that location's climate and hazards, sets appropriate units, and constrains response length. Apply this to: user in Phoenix, AZ wanting current weather." |
| **Output** | A well-structured p₁ like the one above |

### Level 3 — Meta²-Prompt (generates p₂)

| Component | Content |
|-----------|---------|
| **c₂** | Principles for generating meta-prompts for real-time factual queries as a class: (1) Factual queries require grounding — meta-prompts must enforce tool/source specification. (2) Location-based queries have a disambiguation pattern — the meta-prompt should include a "resolve ambiguity" step. (3) Domain-specific output schemas vary — the meta-prompt should instruct the generator to research what fields matter (e.g., UV for desert, air quality for cities). (4) The meta-prompt itself should be parameterizable: `{location}`, `{query_type}`, `{user_preferences}`. (5) Include a self-check: does the generated p₁ actually require a tool call, or could the LLM hallucinate? |
| **p₃** | "You are a prompt architect for real-time factual query systems. Given a *class* of factual queries (weather, stocks, sports scores, etc.), generate a meta-prompt template that: (a) enforces tool/API grounding, (b) includes entity disambiguation logic, (c) dynamically determines the relevant output schema by researching the domain, (d) uses parameterized slots for user context, and (e) includes a hallucination guard. Apply this framework to generate a meta-prompt for location-based weather queries." |
| **Output** | A reusable p₂ template for any location-based real-time query |

---

## Example 2: Generate ODD Protocol for "The Garbage Can Model"

### Level 0 — Naive Prompt

| Component | Content |
|-----------|---------|
| **p₀** | "Generate an ODD protocol for the Garbage Can Model." |
| **Output** | Superficial, likely mixes up ODD versions, misses submodels, no formal structure |

### Level 1 — Contextualized Prompt

| Component | Content |
|-----------|---------|
| **c₀** | Domain context: (1) The ODD protocol (Overview, Design concepts, Details) is a standard format for describing agent-based models, updated in Grimm et al. 2020 (ODD+2). (2) The full protocol structure from https://www.jasss.org/23/2/7.html includes 7 elements: Purpose and patterns, Entities/state variables/scales, Process overview and scheduling, Design concepts (11 sub-concepts), Initialization, Input data, Submodels. (3) The Garbage Can Model (Cohen, March & Olsen 1972) simulates organizational decision-making where problems, solutions, participants, and choice opportunities are loosely coupled. Key entities: problems, solutions, decision-makers, choice opportunities. Key processes: attachment, detachment, resolution by oversight/flight/decision. (4) Good ODD descriptions are precise enough to reimplement the model from the description alone. |
| **p₁** | "Using the ODD+2 protocol (Grimm et al. 2020), generate a complete ODD description for the Garbage Can Model of organizational choice (Cohen, March & Olsen 1972). Follow all 7 elements strictly. For each element, be precise enough that another modeler could reimplement the model. The entities are: problems, solutions, participants, choice opportunities. Key parameters: energy distribution, net energy load. Include the 11 design concepts. For Submodels, provide pseudocode or mathematical definitions for: attachment rules, energy allocation, resolution conditions (oversight, flight, decision). Cite the original paper where assumptions are drawn from it." |
| **Output** | A complete, structured ODD document |

### Level 2 — Meta-Prompt (generates p₁)

| Component | Content |
|-----------|---------|
| **c₁** | Principles for generating good ODD-generation prompts: (1) The prompt must enforce the full ODD structure — missing sections produce incomplete documentation. Enumerate all 7 elements and all 11 design concepts explicitly. (2) The prompt must inject enough information about the *target model* that the LLM can distinguish it from superficially similar models. (3) Precision standard: "reimplementable from description alone" — the prompt should state this as the quality bar. (4) Submodels are where most ODD documents fail — the prompt should explicitly request pseudocode or equations, not prose. (5) The prompt should instruct the LLM to separate *model design choices* from *ODD documentation conventions*. (6) Source fidelity: the prompt should tell the LLM to cite the original paper and flag any assumptions not in the original. |
| **p₂** | "You are an expert in agent-based model documentation. Given (a) a specific ABM to document and (b) the ODD+2 protocol specification, generate a prompt that will produce a complete ODD document. Your generated prompt must: enumerate all 7 ODD elements and all 11 design concepts as explicit section requirements; include a summary of the target model's entities, processes, and key parameters sufficient to distinguish it from similar models; set the quality bar as 'reimplementable from this description'; require pseudocode or math for all submodels; instruct the documenter to cite original sources and flag assumptions. Apply this to: The Garbage Can Model (Cohen, March & Olsen 1972), using ODD+2 from Grimm et al. 2020." |
| **Output** | A well-crafted p₁ |

### Level 3 — Meta²-Prompt (generates p₂)

| Component | Content |
|-----------|---------|
| **c₂** | Principles for generating ODD-prompt-generators as a reusable system: (1) ODD documentation is a *structured translation* task: source = model spec/paper, target = ODD format. Meta-prompts should enforce both sides: understanding the source and adhering to the target format. (2) Different ABMs have different documentation challenges — some are spatially explicit, some are equation-heavy, some have emergent behavior that's hard to specify. The meta-prompt-generator should include a *diagnostic step* that identifies which aspects of the target model will be hardest to document. (3) The ODD standard itself evolves (ODD → ODD+D → ODD+2) — the generator should be parameterized by protocol version. (4) Quality control: the generator should include a self-review step where the LLM checks its own ODD output against the "could someone reimplement this?" criterion. (5) Integration with Good Modeling Practice: the generator should consider whether the ODD will be used standalone or as part of a model card / TRACE / reproducibility package. (6) The generator should handle the cold-start problem: what if the user provides only a paper, vs. a paper + code, vs. just a verbal description? |
| **p₃** | "You are designing a reusable ODD-generation system. Given a class of agent-based models and a version of the ODD protocol, produce a meta-prompt that can generate model-specific ODD-writing prompts. Your meta-prompt must: (a) include a diagnostic step that identifies the target model's documentation challenges (spatial? stochastic? emergent? equation-heavy?); (b) be parameterized by ODD protocol version; (c) handle varying input quality (full paper, code, or verbal description); (d) enforce the 'reimplementable' quality bar with a self-review loop; (e) consider downstream use (standalone, TRACE, model card); (f) separate ODD structural requirements from model-specific content injection. Apply this to build a meta-prompt for generating ODD documents for classic organizational/social science ABMs using ODD+2." |
| **Output** | A reusable p₂ that can generate ODD prompts for any ABM in the class |

---

## Example 3: Generate a Software Production Factory

X = "a collection of Claude skills, hooks, and agents that can work on different software creation projects"

### Level 0 — Naive Prompt

| Component | Content |
|-----------|---------|
| **p₀** | "Generate a software production factory using Claude skills, hooks, and agents." |
| **Output** | Generic boilerplate, no coherent architecture, skills don't compose |

### Level 1 — Contextualized Prompt

| Component | Content |
|-----------|---------|
| **c₀** | Domain context: (1) Claude Code skills are markdown instruction files (SKILL.md) with associated scripts, triggered by description matching. (2) Hooks are event-driven scripts (pre/post tool call, notification) that enforce process. (3) Agents here means Claude Code sub-agents spawned via `claude --print` or Task with specific roles. (4) A "factory" implies: project intake → architecture → implementation → testing → review → delivery, with each stage handled by specialized agents. (5) Key patterns: git worktree isolation per agent, CLAUDE.md as shared memory, slash commands for workflow control, MCP servers for tool access. (6) The factory must be project-agnostic — it takes a PRD/spec as input and produces working software. (7) Reference architectures: Boris Cherny's workflow, Claude Squad, Task Master AI patterns. |
| **p₁** | "Design a software production factory for Claude Code consisting of: **Skills** — reusable SKILL.md files for: (a) project scaffolding from PRD, (b) architecture decision records, (c) test-driven implementation, (d) code review, (e) documentation generation, (f) CI/CD setup. **Hooks** — enforcement scripts for: (a) pre-commit linting/testing, (b) post-task CLAUDE.md state updates, (c) notification on stage completion. **Agents** — specialized sub-agents for: (a) Architect (decomposes PRD into tasks), (b) Implementer (writes code in isolated worktrees), (c) Reviewer (adversarial code review), (d) Tester (generates and runs test suites), (e) Integrator (merges worktrees, resolves conflicts). Define the orchestration flow, shared state format (CLAUDE.md schema), and the interface contract between agents. The system should accept a PRD as input and produce a tested, documented codebase." |
| **Output** | A concrete factory design with all components specified |

### Level 2 — Meta-Prompt (generates p₁)

| Component | Content |
|-----------|---------|
| **c₁** | Principles for generating good software-factory prompts: (1) A factory is a *pipeline* — the prompt must enforce stage sequencing and interface contracts between stages. (2) Each agent needs: role definition, input/output contract, isolation strategy, failure modes. (3) Skills must be self-contained and composable — the prompt should enforce the SKILL.md contract (description triggers, file structure, dependencies). (4) Hooks are the "immune system" — the prompt should identify what invariants need enforcement (tests pass, state updated, no regressions). (5) The prompt must address the *coordination problem*: how do agents share state, avoid conflicts, and maintain consistency? (6) The prompt should be parameterizable by project type (web app, CLI tool, library, data pipeline) so the factory adapts. (7) Quality bar: the factory should produce software that passes a "fresh eyes" test — a new developer can understand and extend it. |
| **p₂** | "You are a Claude Code automation architect. Given the primitives available (skills, hooks, sub-agents, CLAUDE.md, git worktrees, MCP servers), generate a detailed factory specification prompt. Your generated prompt must: define each agent's role with explicit I/O contracts; specify skills as SKILL.md files with trigger descriptions and dependencies; design hooks that enforce pipeline invariants; solve the coordination problem (shared state schema, conflict resolution, sequencing); be parameterizable by project type; and set a quality bar for the factory's output. The factory takes a PRD as input and produces a tested, documented, deployable codebase. Generate this prompt targeting a senior Claude Code user who will implement the factory." |
| **Output** | A detailed p₁ like the one above, tailored to the user's tooling |

### Level 3 — Meta²-Prompt (generates p₂)

| Component | Content |
|-----------|---------|
| **c₂** | Principles for generating software-factory-generator-generators (the architectural layer): (1) Software factories are instances of a general pattern: *multi-agent pipelines with shared state and quality gates*. The meta²-prompt should encode this pattern abstractly, not specific to Claude Code. (2) The key design dimensions for any agent factory are: **decomposition** (how is work split?), **coordination** (how do agents communicate?), **isolation** (how are side effects contained?), **quality** (how are invariants enforced?), **adaptation** (how does the factory handle novel project types?). (3) The generator should produce factory specs that are *introspectable* — the factory should be able to explain its own architecture and decisions. (4) The generator should include a *bootstrapping* capability — the factory should be able to improve its own skills and hooks over time based on project outcomes. (5) Failure taxonomy: the generator should anticipate failure modes (agent divergence, state corruption, infinite loops, quality regression) and build in mitigations. (6) The generator should be parameterized by the *agent platform* (Claude Code, OpenAI Agents, LangGraph, CrewAI) so it's not locked to one ecosystem. |
| **p₃** | "You are designing a *meta-framework* for generating AI-driven software production factories. Given any agent platform (Claude Code, LangGraph, CrewAI, etc.), produce a meta-prompt that generates platform-specific factory specification prompts. Your meta-prompt must encode: (a) the five design dimensions of multi-agent pipelines (decomposition, coordination, isolation, quality, adaptation); (b) platform-specific primitive mapping (what does 'skill', 'hook', 'agent' mean in each platform?); (c) a failure taxonomy with mitigation patterns; (d) a bootstrapping mechanism so the factory can improve itself; (e) introspection capabilities so the factory can explain its decisions. The meta-prompt should accept as parameters: target platform, project class (web, CLI, data, ML), team size, and quality requirements. Generate this meta-framework, then apply it to produce a meta-prompt for Claude Code targeting solo developers building web applications." |
| **Output** | A platform-agnostic p₂ generator, plus a Claude-Code-specific p₂ instance |

---

## Cross-Cutting Observations

### The Context Gradient

| Level | Context type | Stability | Reusability |
|-------|-------------|-----------|-------------|
| c₀ | Domain knowledge | Changes per task | Low (task-specific) |
| c₁ | Prompt engineering patterns | Changes per task *class* | Medium (class-specific) |
| c₂ | Meta-generation architecture | Changes per *domain* | High (domain-portable) |
| c₃+ | Epistemological/philosophical | Near-universal | Very high |

### When to Stop Going Higher

Diminishing returns set in when:
- The context becomes so abstract it no longer constrains generation usefully
- The LLM's ability to follow multi-level indirection breaks down (empirically, 2-3 levels is the practical ceiling for current models)
- The overhead of maintaining the hierarchy exceeds the consistency gains

### The Practical Sweet Spot

For most real work, **Level 2 (meta-prompt)** is the sweet spot:
- Level 0-1: Fine for one-off tasks
- Level 2: Necessary when you need *consistent generation across instances of a task class*
- Level 3: Useful when building *reusable tooling/frameworks* that others will use
- Level 4+: Theoretical interest; practical value only in system-of-systems design

### Relationship to Existing Concepts

| This framework | Existing concept |
|---------------|-----------------|
| c₀ | System prompt / context injection |
| p₁ | "Good prompt" in prompt engineering guides |
| p₂ | DSPy optimizers, prompt compilers, Claude's CLAUDE.md |
| p₃ | Framework design, platform architecture |
| The hierarchy itself | Type theory (types, kinds, sorts...), currying, metaclasses |
