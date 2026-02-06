# Active Decisions

## UX / Product

- Keep levels panel visually close to original layout.
- Category control is minimal and readable.
- Top bar is intentionally 3 metrics (Time, Net WPM, Accuracy).
- Top bar includes a horizontal level-completion progress bar.
- Progress bar width is context-aware: wider in fullscreen, standard width in windowed mode.
- Fullscreen progress width grows toward the center by keeping trailing alignment fixed.
- Progress bar is unlabeled (no "Progress" text) to keep the top bar visually clean.

## Progression

- Levels are gated by difficulty.
- Baseline unlock includes lower difficulties.
- Higher difficulty unlock is based on scored completions.

## Accuracy Measurement

- Accuracy is strict/effective: corrected mistakes count against accuracy.
- Formula in `TypingSession.metrics`: `correct / (typedCount + correctedErrors)`.

## Content Scale

- Use deterministic generation pipeline for large level expansion.
- Keep metadata-driven sorting and categorization.
