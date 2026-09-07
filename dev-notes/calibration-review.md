# Calibration and UI review — 2026-09-07

## Base and scope

- Worktree: `82306d5` plus all five pre-existing source-checkout diffs (README, TypingSession, LevelGenerator, unit tests, session journal). Original checkout was not overwritten. Origin task verified GitHub main at `d3427c4`, three commits behind local HEAD.
- Reviewed local history, Xcode frameworks/build phases, scripts, CI, input handling, hand rendering/persistence and level loading. No external package dependencies, download hooks or app networking were found in inspected paths. One author in local metadata is not a security guarantee; installed binaries and current remote state were not audited here.
- No push, commit, publication, replacement of installed app, or level expansion.

## Confirmed fixes

1. Off-center dragging snapped the dot center to the pointer. Dragging now preserves the initial grab offset; hit testing belongs only to calibration circles, and labels cannot intercept it.
2. Image rendering used a widened frame with implicit aspect-fill. The aspect-preserving rectangle is now explicit, retaining the previous appearance and v1 vertical convention (`imageY = 0.5 + (v1Y - 0.5) / 1.25`). Existing points/zoom remain compatible.
3. Entering calibration reduced image height and changed crop. Controls now overlay the image, keeping marker centers stable when toggled.
4. Short windows clipped the top bar and keyboard. A vertical scroll fallback preserves panel sizing and allows access to both; taller windows retain the same layout without scrolling.
5. XCTest launched via an ambiguous bundle ID, lacked a readiness/focus guard, and sent 260 characters for completion. The isolated runner verifies process nonce, exact product path and foreground ID; fixtures use nine real keystrokes with a focus check before each character.
6. View-model initialization erased calibration/zoom on every XCTest launch. Reset is now explicit and limited to the isolated preferences domain; persistence relaunch keeps values.
7. The completion popup's accessibility identifier propagated to its children, hiding the hint/score/star identifiers. An explicit accessibility container preserves the child identities.

## Final validation

- All **27 UI cases passed individually**, in serial bounded runs with stop-on-first-failure. This includes all eight previously failing cases; no tests were deleted to obtain green results.
- UI checks include native window resize (inward from a 1300-point window), stable marker centers on calibration toggle, one-finger drag without changing another finger, actual save/relaunch of points and zoom, exact reset/zoom values, off-center click, nine-character completion, three stars, Enter progression, and scrolling a short window to Space.
- **360 unit tests passed** after the final code changes. Geometry covers four panel aspect ratios × three zoom levels, v1 position compatibility, inverse mapping, isolated persistence reload at another size, missing fingers and malformed JSON.
- Normal production build passed. UI-test build passed. Python runner compile/help, shell syntax and `git diff --check` passed.
- UI per-case logs/result bundles: `build/ui-isolated/bounded-logs/`; machine-readable manifest: `build/ui-isolated/validation-summary.json`.
- Final unit bundle: `build/ui-isolated/Logs/Test/Test-TypingGame-2026.09.07_11-03-25-+1000.xcresult`.
- Window-only screenshot of keyboard reached by scrolling: `build/ui-isolated/qa-assets/5C225720-EE05-40D9-8899-291660E86609.png`. Earlier captures also verified the top bar and overlay placement.

## Test quality audit

- Retained valuable user-behavior tests: typing/correction metrics, restart, level selection, completion, drag/reset and zoom.
- Strengthened weak assertions: zoom expects 90%/86% from a clean 88%; reset compares exact original value; initial metrics equal zero; completion checks nine correct characters, three stars and Enter navigation.
- Added four UI regressions for calibration toggle, persistence relaunch, native resize and short-window scrolling, plus the earlier off-center-click test.
- Ten calibration save/load unit cases and ten zoom clamp cases still largely duplicate each other. They were retained; future consolidation should preserve distinct boundary coverage rather than remove checks merely to reduce failures.
- `testElementExists_01...08` remain low-value standalone coverage compared with the richer flows; the numeric cases now also validate clean initial state. CI explicitly runs all named UI cases with the same isolated runner.
- The unused `AccessibilityMirrorView` is not used as a replacement for actual production controls in these tests.

## Limits

- Physical monitor switching and Retina/non-Retina transitions were not exercised. Neither prior algebra nor resizing evidence confirms a screen-resolution-specific drift; crop changes and drag snapping were confirmed.
- Multiple apps with the old shared bundle ID were observed, but this alone does not establish the cause of all earlier failures. Sound source remains unconfirmed.
- No OS permission dialogs were accepted or permissions changed by the agent. Repeated `make run RUN_FOR=20` was omitted to respect the user's active session; actual isolated UI launches provided runtime validation.
- No CI run was triggered remotely; its updated commands were validated locally.

## Prioritized next work (not implemented)

1. Keyboard nudging and selected-finger feedback for precise calibration/accessibility.
2. Pedagogical coverage audit before new lessons: finger transitions, common bigrams, punctuation/capitalization and mixed consolidation with explicit mastery criteria.
3. Keyboard-layout support beyond the hard-coded US-style mapping.
4. Consolidate duplicate tests into distinct boundary/behavior cases, and add controlled physical multi-monitor QA.
5. Show a diagnostic when level loading falls back to one level instead of silently hiding invalid content.

## Delivery

- Normal app: `build/Build/Products/Debug/Typing Quest.app`.
- Test app: `build/ui-isolated/Build/Products/Debug/Typing Quest.app`, ID `com.typinggame.app.uitesting` with separate preferences.
- The user's original/installed app was not replaced. Changes remain in this worktree for review.
