# `manifest.json` template — structural guidance

`process-designer-output/manifest.json` is the machine-readable contract between `/process-designer` (writer) and a guided installer (reader). Written in Stage 2 alongside the four artifacts.

A future `/process-installer` skill consumes this file to drive a guided install without re-parsing the synthesised `CLAUDE.md` and skill sketches. A reader writing their own install script reads the same file.

---

## Top-level shape

```json
{
  "schema_version": "1",
  "generated_by": "process-designer",
  "generated_at": "<ISO8601 timestamp>",
  "process_name": "<kebab-case slug>",
  "operator": {
    "fluency": "<new|aware|practitioner|fluent>",
    "register": "<plain|professional|technical|specialist>"
  },
  "dimensions": { ... },
  "artifacts": { ... },
  "runtime_paths": [ ... ]
}
```

- `schema_version` — string; bump when the shape changes incompatibly.
- `process_name` — kebab-case slug derived from the reader's use case (e.g. `weekly-engineering-blog-post`).
- `generated_at` — ISO 8601 timestamp from `date -Iseconds`.
- `operator.fluency` — the reader's self-reported familiarity with AI-agent process design. Drives explainer-prelude depth during the interview; informational for the installer (the installer can size its own hand-holding to match).
- `operator.register` — the reader's chosen language register for synthesised artifacts (*plain / professional / technical / specialist*). Drives the prose voice of `CLAUDE.md`, skill sketches, hooks, eval set, and `INSTALL.md`. See [`references/operator-profile.md`](../operator-profile.md) for the full taxonomy.

---

## `dimensions`

```json
{
  "universal": {
    "reversibility": <1-4>,
    "domain_distance": <1-4>,
    "iteration_cost": <1-4>,
    "autonomy": <1-4>,
    "memory_horizon": <1-4>,
    "parallelism": <1-4>
  },
  "use_case_specific": {
    "<dim_slug>": <1-4>
  }
}
```

Snake_case dimension slugs. The installer surfaces these to the reader for confirmation before installing.

---

## `artifacts`

```json
{
  "claude_md": {
    "source": "CLAUDE.md",
    "destination_project": "./CLAUDE.md",
    "destination_user": "~/.claude/CLAUDE.md",
    "merge_strategy": "manual"
  },
  "skills": [
    {
      "name": "<skill-slug>",
      "source": "skills/<skill-slug>/",
      "destination_project": "./.claude/skills/<skill-slug>/",
      "destination_user": "~/.claude/skills/<skill-slug>/",
      "is_sketch": true,
      "gaps": ["<gap text 1>", "<gap text 2>"]
    }
  ],
  "hooks": [
    {
      "name": "<hook-name>",
      "source": "hooks/<hook-name>.sh",
      "destination_project": "./.claude/hooks/<hook-name>.sh",
      "event": "PreToolUse",
      "matcher": "<matcher string>",
      "executable": true
    }
  ],
  "settings_snippet": {
    "source": "hooks/settings-snippet.json",
    "destination_project": "./.claude/settings.json",
    "destination_user": "~/.claude/settings.json",
    "merge_strategy": "deep-merge"
  },
  "eval_set": {
    "source": "evals/eval-set.md",
    "destination_project": "./evals/eval-set.md"
  }
}
```

- `source` paths are relative to `process-designer-output/`.
- `destination_*` are tilde-expanded; the installer picks one per the reader's scope choice.
- `merge_strategy`: `"manual"` (CLAUDE.md — never auto-merge), `"deep-merge"` (settings.json), absent (overwrite is safe).
- `gaps`: one human-readable string per *"gap the reader fills"* listed in the sketch's Section 6.
- `is_sketch: true` signals the installer to install with `disable-model-invocation: true` or walk the gaps interactively.

---

## `runtime_paths`

```json
[
  {"path": "archive/", "type": "directory", "seed": null},
  {"path": "NOTES.md", "type": "file", "seed": null},
  {"path": "voice-fingerprint.md", "type": "file", "seed": "# Voice fingerprint\n\nPopulate by reading the last six posts.\n"}
]
```

Every directory or file the synthesised `CLAUDE.md` references *outside of* `.claude/`. The installer creates each as empty (`seed: null`) or with seeded content. Exhaustive — anything `CLAUDE.md` mentions must appear here, or the install will be incomplete.

---

## Invariants

- Every artifact has `destination_project`, `destination_user`, or both. Hybrid scope (skills user-global, rest project-local) requires both for skills.
- `executable: true` on a hook tells the installer to run `chmod +x` after copy.
- `gaps` is `[]` for finished skills; non-empty for sketches.
- `runtime_paths` order does not matter; the installer creates each independently.

---

## Re-generation

A refinement-loop pass regenerates the manifest. `generated_at` updates; `schema_version` stays unless the shape changes. A future installer can detect mismatches against a previously installed manifest at install time.
