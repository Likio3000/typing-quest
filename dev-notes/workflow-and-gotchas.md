# Workflow and Gotchas

## Common Commands

- Build: `make build`
- Run (20s auto-stop): `make run`
- Clean + build + run: `make fresh-run`
- Live run (no auto-stop): `make run-live`
- Smoke: `make smoke`
- Regenerate levels: `make levels`
- Unit tests: `xcodebuild -project TypingGame.xcodeproj -scheme TypingGame -configuration Debug -derivedDataPath build/ui-isolated TYPINGGAME_APP_ID=com.typinggame.app.uitesting test -destination 'platform=macOS,arch=arm64' -only-testing:TypingGameTests`
- Isolated UI build: `make ui-build`
- Explicit, bounded UI cases: `make ui-test UI_TESTS='testCalibrationToggleKeepsImageAndPointCenters testCalibrationPersistsAcrossRelaunch'` (announces/controls only the test copy).

## Known Environment Gotchas

- `make smoke` may fail in some environments due to CoreSimulator service/runtime issues, even when compile and tests are otherwise healthy.
- UI screenshot automation may require both Screen Recording and Accessibility permissions.
- App executable path includes spaces (`Typing Quest.app`). Quote paths in scripts/commands.
- `make run` and `make fresh-run` now auto-stop the app after `RUN_FOR` seconds (default `20`).
- `make run`/`make fresh-run`/`make run-live` attempt fullscreen automatically by default (`FULLSCREEN=1`). Use `FULLSCREEN=0` to disable.

## Practical Validation Strategy

1. Run `make build` first.
2. Run `xcodebuild ... test -only-testing:TypingGameTests` for noninteractive domain checks; use isolated UI cases separately for rendered behavior.
3. Before finishing an implementation task, run `make run RUN_FOR=20` to sanity-check runtime behavior.
4. Use screenshot capture for visual UI verification when requested.

## UI test isolation

- Multiple local builds share `com.typinggame.app`; check instance/build selection before UI testing. Never run the full interactive suite while the user is using another instance.
- UI automation may time out enabling automation mode or fail to find controls. Preserve logs; distinguish runner/environment failures from assertions.
- Prefer `-only-testing:TypingGameTests` for noninteractive geometry/persistence validation. Announce and bound any UI attempt; do not accept OS permissions on the user's behalf.

## Isolated UI runner (2026-09-07)

- `TYPINGGAME_APP_ID` defaults to the regular app ID. `make ui-build` overrides only the app target to `com.typinggame.app.uitesting` and writes `build/ui-isolated/`.
- UI tests launch that ID explicitly and verify a unique launch token, exact product path, and foreground app. They do not launch/terminate the personal bundle. Each case resets only isolated preferences unless it is a persistence relaunch.
- `scripts/test_ui_isolated.py` requires named cases, disables parallel automation, applies per-case XCTest and external timeouts, and stops on failure. Logs remain under `build/ui-isolated/bounded-logs/`.
- `make smoke` defaults to unit tests; `SMOKE_TESTS=ui/all` directs users to the isolated workflow instead of starting broad interactive automation.
- The test fixture is nine characters, only honored by the isolated build. Real typing, metrics, completion UI and Enter navigation still run through production code.
- Do not use `UITesting.enabled` to erase preferences in view-model initialization: it breaks persistence tests and can touch personal preferences in a hosted unit run.
