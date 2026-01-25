---
name: typing-game-dev
description: Project-specific development workflow for the Typing_game macOS app. Use when making code changes in this repo; requires running the smoke test (make smoke / scripts/smoke_run.sh) and reporting the result before declaring a task done.
---

# Typing Game Dev

## Workflow

1. Make the requested code changes in this repo.
2. Run the smoke test before declaring the task done:
   - Preferred: `make smoke`
   - Direct: `scripts/smoke_run.sh build/Build/Products/Debug/TypingGame.app/Contents/MacOS/TypingGame`
3. Report the smoke test result in the final response.
4. If smoke fails, do not declare the task done; summarize the failure and ask how to proceed.
