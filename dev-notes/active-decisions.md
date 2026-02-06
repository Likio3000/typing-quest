# Active Decisions

## UX / Product

- Keep levels panel visually close to original layout.
- Category control is minimal and readable.
- Top bar is intentionally 3 metrics (Time, Net WPM, Accuracy).
- Top bar includes a horizontal level-completion progress bar.

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
