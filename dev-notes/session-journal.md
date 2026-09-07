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

## 2026-09-07 — Calibration review and targeted fix
- Verified Typing Quest origin; incorporated all five pre-existing source-checkout diffs into this worktree without editing the source checkout. Base is 82306d5 plus local changes.
- Fixed off-center drag snapping and restricted gesture hit areas to calibration circles; made aspect-preserving image rendering explicit while retaining v1 coordinates and appearance.
- Added geometry/legacy compatibility matrix, isolated persistence/resize/corrupt-data regression, and UI off-center-click regression. Documented test quality audit and prioritized follow-ups in calibration-review.md.
- Final unit-only run passed 360 tests. Earlier integrated UI run: 15/23 passed, 8 failed finding controls; off-center-click and drag/reset passed. Duplicate bundle IDs observed; no confirmed monitor-specific drift or sound cause. Full interactive testing stopped; no OS permissions accepted by agent.
- Build available in this worktree's build/Build/Products/Debug/Typing Quest.app. No push, publication, installation, or overwrite of original checkout. Runtime make-run repetition omitted to avoid interfering with user's active app.

## 2026-09-07 — Close UI failures and stabilize calibration viewport
- Isolated UI builds/preferences under com.typinggame.app.uitesting; added nonce/product-path/focus guards, nine-character fixtures, serial bounded runner and opt-in interactive workflow. Smoke defaults to isolated unit checks; CI retains every UI case through the same runner.
- Removed unconditional preference deletion from XCTest view-model initialization, fixed popup accessibility identifier propagation, overlaid calibration controls to keep viewport stable, and added vertical scroll fallback for short windows.
- Strengthened exact zoom/reset/initial metrics/completion/Enter checks and added UI regressions for toggle geometry, native resize, persistence relaunch, and reaching the keyboard in a short window.
- Validation: all 27 UI cases passed individually in bounded serial runs, including all eight prior failures; final 360 unit tests passed; production/test builds and Python/shell/diff checks passed. Logs and xcresults remain under build/ui-isolated; calibration-review.md contains audit, paths and limitations.
- No publication, push, install replacement, automatic OS permission changes or level expansion. Original local diffs retained. Physical multi-monitor switching remains untested; normal compiled app is in build/Build/Products/Debug/Typing Quest.app.

## 2026-09-07 — Native window controls follow-up
- Confirmed personal PID 71207 used the old original-project build, not the corrected worktree binary. Kept personal session and floating voice panel untouched.
- Reproduced focus interference near maximized traffic lights: second Option+green showed Codex in front; used unobscured native menu to validate zoom/restore/close without attributing all symptoms to NSWindow.
- Forwarded Cmd/Ctrl events to the responder chain and added explicit Window → Toggle Full Screen with Ctrl+Cmd+F. No native titlebar/style-mask overrides.
- Focused validation passed: native red close, menu Zoom/restore/close, green fullscreen entry → shortcut exit → shrink both axes → red close, one-character typing, and modifier-forwarding unit regression. Test and normal production builds passed; no general suite rerun. Detailed evidence/limits in native-window-review.md.
- Updated app remains in worktree build/Build/Products/Debug/Typing Quest.app. No installed app replacement, push, publication, permissions changes or level expansion.

## 2026-09-07 — Install habitual corrected app
- On explicit user authorization, installed the validated normal app in ~/Applications/Typing Quest.app and replaced the original project's built app with the same version. Preserved sources/Git changes; old app retained as verified ZIP outside repo.
- Found Dock pointing to nonexistent Xcode DerivedData app; retargeted only that tile and preserved other Dock entries. Registered stable installation and retired stale/development launch registrations.
- Finder/Dock CUA calls failed (cgWindowNotFound/timeout), with no approval rejection; completed configuration via macOS defaults/Launch Services and restarted Dock.
- Opened stable app. Verified preferred macOS route, Dock URL, active PID 72943 executable path, SHA-256 matching validated build and strict/deep signature. Calibration/zoom unchanged and source diff preserved byte-for-byte.
- No UI tests, push, publication or repository deletion. Backup/settings snapshots in ~/Library/Application Support/Typing Quest/Backups/.

## 2026-09-07 — Automatic fingertip alignment and installed update
- Replaced the old coordinate convention with exact-artwork anatomical defaults and shared image-UV transform; automatic framing keeps ten fingertips visible. Manual adjustment is secondary and old v1 preferences are retained but ignored in favor of v2 defaults/overrides.
- Five focused regression tests passed (18 size/zoom combinations); visually verified four actual SwiftUI renders. One bounded isolated first-launch UI test passed after correcting AX text lookup. Normal build and diff whitespace check passed.
- Backed up and updated both personal app copies, preserved legacy calibration/zoom and original-project source changes, and reopened the verified stable installation. Details: automatic-hand-guide-review.md.

## 2026-09-07 — Reachable dashboard scroll bounds
- Reproduced fixed-height overflow with five error rows: top bar clipped 50 pt above the scroll document. Added measured dashboard/column layouts with finite nested-scroll heights and removed inherited scroll disabling.
- Three bounded isolated UI cases passed (short/normal with errors, normal without); visually verified full upper/lower edges in test captures and the updated installed app. Normal build and diff check passed.
- Updated both authorized app copies with validated ZIP/preference backups; preserved original sources and existing preferences. Stable reopened, SHA 4ae7c2d6…; see scroll-layout-review.md.

## 2026-09-07 — Authorized project closeout
- Preserved the five original local diffs in their own commit, on top of the three preexisting local commits. Prepared the validated hand-guide, native-window, scroll and test-isolation fixes for main; no additional product scope or repeat broad suites.
- Expanded the public README with actual features, macOS/tool requirements, reproducible build/launch steps, practice/controls, automatic guidance and focused validation commands.
- Moved six redundant development/test app bundles and five session-created old-version ZIPs to recoverable Trash. Kept the verified stable app (SHA 4ae7c2d6…), preference snapshots, source/history and test results. Recovery mapping: `~/Library/Application Support/Typing Quest/Backups/cleanup-manifest-20260907.json`.
