---
name: typing-game-dev
description: Project-specific development workflow for the Typing_game macOS app. Use when making code changes in this repo; requires running smoke/test validation and updating dev-notes when decisions or durable findings change.
---

# Typing Game Dev

## Workflow

1. Start by loading the `typing-game-memory` skill workflow and reading relevant files in `dev-notes/`.
2. Make the requested code changes in this repo.
3. Run validation before declaring the task done:
   - Always run: `make run RUN_FOR=20`
   - Preferred: `make smoke`
   - Direct: `scripts/smoke_run.sh \"build/Build/Products/Debug/Typing Quest.app/Contents/MacOS/Typing Quest\"`
   - If smoke is flaky in the environment, run:
     `xcodebuild -project TypingGame.xcodeproj -scheme TypingGame -configuration Debug -derivedDataPath build test -destination 'platform=macOS,arch=arm64'`
4. Update `dev-notes/` if the task introduces durable decisions, architecture changes, or new gotchas.
5. Report validation results in the final response.
