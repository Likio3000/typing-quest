# Session Journal

## 2026-02-06

- Added scalable levels infrastructure and generated expanded `levels.json` from `LevelsSource`.
- Added level metadata support (`category`, `difficulty`, `tags`, `sortOrder`, `source`).
- Added minimal category-focused level filtering UI.
- Tuned hands image zoom/offset for full fingertip visibility.
- Simplified top bar KPIs to Time / Net WPM / Accuracy.
- Added difficulty-based progression and lock visualization.
- Updated accuracy to include corrected mistakes.
- Added top-bar level completion progress bar in fullscreen gameplay layout.
- Updated category picker selected text styling to high-contrast white.
- Added persistent repo memory policy (`AGENTS.md`) and memory-skill maintenance rules.
- Verified test pass via `xcodebuild ... test` (349 tests, 0 failures).
- Added `make fresh-run` target to clean, rebuild, and launch the app in one command.
- Updated make run flow to auto-stop after a timed window (`RUN_FOR`, default 20s), plus `make run-live` for manual sessions.
- Set default end-of-task runtime check policy to `make run RUN_FOR=20`.
- Widened top-bar progress line from compact to long format for better visibility.
- Updated make run targets to auto-attempt fullscreen before the timed run window.
- Progress bar now expands further only in fullscreen while keeping prior width in windowed mode.
- Increased fullscreen progress bar width again and kept it trailing-anchored so extra width grows toward center.
- Removed "Progress" label text from the top-bar progress element.

## 2026-02-07

- Added completed-level `Enter` shortcut to advance to the next unlocked level in global catalog order.
- Enter-advance now resets level filter to `All` so the newly selected level remains visible.
- Added subtle completion hint text that appears only when a next unlocked level exists.
- Added keypad Enter support (`keyCode` 76) in key capture alongside main Return.
- Added unit coverage for `ContentViewModel` next-level shortcut behavior and newline typing regression.
- Added UI test coverage for completion hint visibility after level completion.
- Validation: `make build` passed; targeted shortcut tests passed via `xcodebuild ... -only-testing`.
- Validation: full `xcodebuild ... test` currently fails in this environment because UI tests cannot activate the app (`Running Background` state).
- Runtime sanity check passed with `make run RUN_FOR=20`.

## 2026-02-08

- Fixed levels panel discoverability after Enter-advance by auto-scrolling the levels list to the currently selected level row.
- Validation: `make build` passed, `xcodebuild ... -only-testing:TypingGameTests` passed (354 tests), and `make run RUN_FOR=20` passed.
- Removed visible text-size controls from the Target panel and kept sizing controls as keyboard shortcuts (`Cmd -`, `Cmd +`) via non-visual bindings.
- Validation: `make build` passed, `xcodebuild ... -only-testing:TypingGameTests` passed (354 tests), and `make run RUN_FOR=20` passed.
- Removed `Unlocked D#` text from the levels category row, leaving only the `Category` label and dropdown.
- Validation: `make build` passed, `xcodebuild ... -only-testing:TypingGameTests` passed (354 tests), and `make run RUN_FOR=20` passed.
- Reworked top-bar layout so the progress bar is centered within the area to the right of the KPI pills instead of being pinned to the right edge.
- Validation: `make build` passed and `make run RUN_FOR=20` passed.
- Simplified Summary to only `Correct`, `Wrong`, `Uncorrected`, and `Corrected` pills (removed `Pending`, score line, hint line, and restart button from Summary).
- Moved `Restart` action to the Target panel as a top-right button.
- Added a level-complete popup with score plus star rewards by accuracy tier (>=95%: 3, >=90%: 2, >=80%: 1, otherwise 0), and reused the Enter-next hint there when applicable.
- Validation: `make build` passed, `xcodebuild ... -only-testing:TypingGameTests` passed (354 tests), and `make run RUN_FOR=20` passed.
- Realigned top-bar progress so it is centered to the full top-bar width (not centered within the area remaining after KPI cards).
- Validation: `make build` passed and `make run RUN_FOR=20` passed.
- Moved `Restart` out of Target overlay and into the top-bar KPI cluster to avoid covering target text.
- Validation: `make build` passed, and visual placement check passed via screenshot capture.
- Lightened top-bar KPI card orange to a brighter tint of the same accent color.
- Validation: `make build` passed.
- Added `Speed Trend` panel below Summary to chart sampled Net WPM over time during active typing.
- Implemented rolling chart behavior with a fixed 30-second window and bounded sample retention so long sessions scroll instead of expanding infinitely.
- Validation: `make build` passed and `xcodebuild ... -only-testing:TypingGameTests` passed (354 tests).
- Captured demo video showing the feature at `/Users/alexbethune/Projects/Typing_game/artifacts/wpm-trend-demo.mov`.
- Added soft-start sampling for Speed Trend (warm-up confidence from elapsed time and keystrokes plus EMA smoothing) to avoid inflated WPM spikes in the first few keystrokes.
- Validation: `make build` passed after smoothing update.
- Replaced warm-up confidence ramp with startup prior stabilization (plus EMA) so early spikes are damped without forcing a constant upward ramp.
- Validation: `make build` passed after startup-smoothing model update.

## 2026-07-13

- Hardened random level generation against non-positive lengths and word ranges so malformed programmatic levels return safely instead of hanging or trapping.
- Made problem-key ranking deterministic for equal counts and safe for non-positive result limits.
- Refreshed the README to match the 240-level catalog, current UI, progression flow, and development commands.
- Validation: level generation, shell/Python syntax checks, full unit suite (358 tests), build, and a 20-second runtime launch all passed.
