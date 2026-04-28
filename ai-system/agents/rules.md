# Agent Rules

## Working Agreement

- `.ai-system` is the local source of truth for ongoing agent coordination in this repo.
- Read before writing: inspect current source files and relevant `context/` docs before making changes.
- Prefer patching existing files over adding duplicate modules or alternative flows.
- Keep product language aligned with the current Cuemate positioning: a privacy-first, local-first, system-level assistant for live work.
- Do not treat marketing copy as implementation truth when source code says otherwise.

## Update Protocol

After meaningful changes:

- Update `context/product.md` if the product positioning, supported use cases, or roadmap changes.
- Update `context/architecture.md` if implementation structure, runtime flow, or major dependencies change.
- Append a short note to `logs/updates.md` for meaningful progress, blockers, or repo cleanup decisions.
- Update `tasks/in-progress.md`, `tasks/backlog.md`, or `tasks/completed.md` when work status changes materially.
- Record stable lessons or recurring issues in `memory/learnings.md` or `memory/bugs.md`.

## Repo Hygiene

- `.ai-system` must remain local-only and ignored by git.
- Generated artifacts should stay out of version control unless the user explicitly asks otherwise.
- Never delete user work or local coordination files without explicit instruction.
- If repo cleanup is requested, preserve public-source essentials first: `Package.swift`, `Sources/`, `Tests/`, `README.md`, `product.html`, `scripts/`, and `Packaging/` unless the user chooses a different shape.

