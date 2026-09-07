# Active Decisions

## UX / Product

- Keep levels panel visually close to original layout.
- Category control is minimal and readable.
- Top bar is intentionally 3 metrics (Time, Net WPM, Accuracy).
- Top bar includes a horizontal level-completion progress bar.
- Top-bar KPI cards use a lighter accent-orange background for improved readability while staying on the same hue as the app accent.
- Progress bar width is context-aware: wider in fullscreen, standard width in windowed mode.
- Progress bar is centered against the full top-bar width, with KPI cards pinned to the left.
- Progress bar is unlabeled (no "Progress" text) to keep the top bar visually clean.
- Completed levels support `Enter` as a next-level shortcut.
- Completion hint ("Press Enter for next level") appears only when a next unlocked level exists.
- Enter-driven next-level navigation resets level filter to `All` so the new level stays visible.
- No completion hint is shown on the last unlocked level (Enter does nothing).
- Levels list auto-scrolls to keep the current selected level row visible after selection changes.
- Target panel no longer shows text-size controls; sizing remains available via `Cmd -` and `Cmd +`.
- Top bar KPI cluster hosts the `Restart` button (moved out of Summary and away from target text).
- Levels category row only shows the `Category` label and category dropdown (no unlocked-difficulty badge text).
- Summary panel only shows four pills: `Correct`, `Wrong`, `Uncorrected`, and `Corrected` (no `Pending`, no score text, no restart control).
- Right column includes a `Speed Trend` panel below Summary that charts Net WPM over time.
- Speed Trend uses a rolling 30-second window so long sessions scroll instead of growing indefinitely.
- Speed Trend suppresses startup WPM spikes with a short prior-based stabilization plus EMA smoothing, without forcing a monotonic early ramp.
- Level completion uses a centered popup showing score and accuracy-based stars (3 for >=95%, 2 for >=90%, 1 for >=80%, otherwise 0).
- Completion popup shows the Enter-next hint only when a next unlocked level exists.

## Progression

- Levels are gated by difficulty.
- Baseline unlock includes lower difficulties.
- Higher difficulty unlock is based on scored completions.
- Next-level shortcut traversal uses global unlocked order from the catalog (not category-scoped).

## Accuracy Measurement

- Accuracy is strict/effective: corrected mistakes count against accuracy.
- Formula in `TypingSession.metrics`: `correct / (typedCount + correctedErrors)`.

## Content Scale

- Use deterministic generation pipeline for large level expansion.
- Keep metadata-driven sorting and categorization.

## Hand Calibration

- The guide is automatic by default: ten anatomical nail-center landmarks belong to the exact Jan 23 1536×1024 artwork. Do not reuse them with fallback artwork.
- `hands.points.v2` stores literal top-left image UV coordinates. Old `hands.points.v1` remains untouched for recovery but does not override the new defaults.
- Image and points share one aspect-preserving rectangle; framing caps zoom and clamps origin to keep all default fingertips visible across panel sizes.
- Manual adjustment is secondary (`Adjust…`); `Automatic` restores landmarks. Dragging preserves grab offset, labels do not intercept gestures, and adjustment controls overlay the image without changing its viewport.
- The outer scroll document reports its full measured height. DashboardLayout measures header/keyboard; DashboardColumnsLayout measures the growing right column and gives nested levels/hands a bounded height. Never wrap the entire dashboard in a fixed-height frame: five problem rows can overflow it at both ends.
- Keep inner scrolling enabled at all window heights; outer scrolling naturally stops when content fits. Short windows scroll vertically to reach the complete top bar and keyboard.
- UI automation uses an isolated app ID and preferences domain, verifies exact build path/process nonce/focus, and stops at the first failure. Normal smoke runs unit tests; interactive UI tests are explicit.

## Native Windows

- Keep macOS titlebar/traffic-light controls and default style masks. Window → Toggle Full Screen explicitly binds Control–Command–F as an alternative to the green button.
- KeyCaptureNSView forwards Command/Control events through the responder chain instead of silently consuming them; they never enter the typing session.
- Native regression coverage: close red; Window → Zoom/restore then close; green fullscreen entry, shortcut exit, restore original dimensions, shrink both axes, close red.
- Floating voice-panel interference was observed near maximized top-left controls; do not modify other apps or the user's personal window to work around it. Use unobscured native menus/shortcut and report this limit.

## Installed Delivery

- Alex explicitly authorized replacing the habitual installation/accesses on 2026-09-07. Use `~/Applications/Typing Quest.app` as the stable personal installation, not Xcode DerivedData or a worktree path.
- Final closeout authorizes commit/push to main and fast-forwarding the original checkout after preserving its existing diffs in history. Keep only the stable installed app; remove redundant build apps and session-created superseded ZIPs through recoverable Trash. Preserve preference snapshots and test evidence.
- Dock was retargeted from a nonexistent DerivedData app to the stable installation; unrelated Dock items were preserved. Calibration/zoom preferences were verified unchanged after launch.
