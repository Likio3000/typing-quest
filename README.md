# TypingGame

## Development

- Build: `make build`
- Run: `make run`
- Smoke test after changes: `make smoke`
  - Runs the app smoke launch and `xcodebuild test` (UI + unit tests).
  - Direct script usage (after `make build`):
    `scripts/smoke_run.sh build/Build/Products/Debug/TypingGame.app/Contents/MacOS/TypingGame`
