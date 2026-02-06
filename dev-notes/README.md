# Dev Notes (Agent Memory)

Purpose: persistent project-side memory to reduce repeated discovery work across future Codex sessions.

Use this folder for:
- architecture and workflow facts that stay stable
- active product/technical decisions
- session outcomes and known gotchas

Do not store secrets in this folder.

## Files

- `project-brief.md`: high-level project context and current product state
- `architecture.md`: key modules and responsibilities
- `workflow-and-gotchas.md`: commands, test strategy, and environment pitfalls
- `active-decisions.md`: current decisions and rationale
- `session-journal.md`: concise changelog of meaningful sessions

## Update Rules

1. Keep entries short and factual.
2. Update only what changed.
3. Prefer bullet points over long prose.
4. Add command outputs as summaries, not raw logs.

## Maintenance Policy

- This folder is mandatory operational memory for this repo.
- Every future implementation session must:
  1. read the relevant files at start,
  2. update relevant files at end when durable facts changed.
- If the notes are stale, the session should fix them before declaring completion.
- A task is not complete until this folder is current for that task.
- Preferred update order at task end:
  1. `active-decisions.md` for durable product/technical choices,
  2. `architecture.md` for module responsibility changes,
  3. `workflow-and-gotchas.md` for command/test/run guidance changes,
  4. `session-journal.md` for one concise session summary entry.
