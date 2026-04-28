# Cuemate Agent System

This folder is a local-only coordination surface for agents working in this repository.

It is intentionally present in the repo directory so agents can read and update shared project context, but it must not be committed to git.

Start here:

1. Read `EXECUTION.md` for the current command surface.
2. Read `agents/rules.md` before making changes.
3. Read the relevant files under `context/` before editing product or architecture-sensitive code.
4. Record meaningful updates in `logs/updates.md`.

Folder guide:

- `agents/`: working rules and update protocol
- `context/`: product, architecture, and decision context
- `tasks/`: backlog and active work notes
- `memory/`: recurring learnings and bugs
- `logs/`: execution trail and handoff notes

