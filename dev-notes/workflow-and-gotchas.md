# Workflow and Gotchas

## Common Commands

- Build: `make build`
- Run: `make run`
- Smoke: `make smoke`
- Regenerate levels: `make levels`
- Full tests: `xcodebuild -project TypingGame.xcodeproj -scheme TypingGame -configuration Debug -derivedDataPath build test -destination 'platform=macOS,arch=arm64'`

## Known Environment Gotchas

- `make smoke` may fail in some environments due to CoreSimulator service/runtime issues, even when compile and tests are otherwise healthy.
- UI screenshot automation may require both Screen Recording and Accessibility permissions.
- App executable path includes spaces (`Typing Quest.app`). Quote paths in scripts/commands.

## Practical Validation Strategy

1. Run `make build` first.
2. Run full `xcodebuild ... test` for deterministic pass/fail when smoke is flaky.
3. Use screenshot capture for visual UI verification when requested.
