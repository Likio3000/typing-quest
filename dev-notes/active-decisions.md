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
