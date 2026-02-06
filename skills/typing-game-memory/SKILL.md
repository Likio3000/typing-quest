---
name: typing-game-memory
description: Maintain persistent development notes for this repo. Use when starting or finishing work in Typing_game to read relevant context from dev-notes and record durable decisions, gotchas, and session outcomes.
---

# Typing Game Memory

Use this skill to keep project memory accurate across sessions.

## Files to Use

- `dev-notes/project-brief.md`
- `dev-notes/architecture.md`
- `dev-notes/workflow-and-gotchas.md`
- `dev-notes/active-decisions.md`
- `dev-notes/session-journal.md`

## Start-of-Task Workflow

1. Read `dev-notes/project-brief.md` and `dev-notes/active-decisions.md`.
2. Read `dev-notes/workflow-and-gotchas.md` if commands/test strategy matter for the task.
3. Only load `dev-notes/architecture.md` when module-level context is needed.
4. If notes conflict with current code behavior, treat code as source of truth and update notes before finishing.

## End-of-Task Workflow

1. Update only the note files impacted by the task.
2. Append one concise entry to `dev-notes/session-journal.md` when there is meaningful progress.
3. Keep entries factual and short (what changed, why, and any important validation result).
4. Consider the task incomplete until required note updates are written.

## Notes Quality Rules

- Do not duplicate entire code diffs.
- Do not paste raw long logs; summarize outcomes.
- Prefer stable facts and decisions over temporary implementation details.
- Never store secrets.
- Keep language operational and future-session friendly (short bullets, no narrative logs).
