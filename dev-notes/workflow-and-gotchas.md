# Workflow and Gotchas

## Common Commands

- Build: `make build`
- Run (20s auto-stop): `make run`
- Clean + build + run: `make fresh-run`
- Live run (no auto-stop): `make run-live`
- Smoke: `make smoke`
- Regenerate levels: `make levels`
- Full tests: `xcodebuild -project TypingGame.xcodeproj -scheme TypingGame -configuration Debug -derivedDataPath build test -destination 'platform=macOS,arch=arm64'`

## Known Environment Gotchas

- `make smoke` may fail in some environments due to CoreSimulator service/runtime issues, even when compile and tests are otherwise healthy.
- UI screenshot automation may require both Screen Recording and Accessibility permissions.
- App executable path includes spaces (`Typing Quest.app`). Quote paths in scripts/commands.
- `make run` and `make fresh-run` now auto-stop the app after `RUN_FOR` seconds (default `20`).
- `make run`/`make fresh-run`/`make run-live` attempt fullscreen automatically by default (`FULLSCREEN=1`). Use `FULLSCREEN=0` to disable.

## Practical Validation Strategy

1. Run `make build` first.
2. Run full `xcodebuild ... test` for deterministic pass/fail when smoke is flaky.
3. Before finishing an implementation task, run `make run RUN_FOR=20` to sanity-check runtime behavior.
4. Use screenshot capture for visual UI verification when requested.
