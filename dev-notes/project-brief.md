# Project Brief

- Product: macOS typing trainer app (display name: `Typing Quest`)
- Repo: `Typing_game`
- Platform: SwiftUI app + core module + unit/UI tests
- Current focus: scalable level catalog, minimal-ui filtering, progression flow, and measurement quality

## Current State Highlights

- Levels expanded from static set to generated catalog (`240` levels in current generated output).
- Level schema supports metadata: category, difficulty, tags, sort order, source.
- Levels panel includes category selection and progression visibility.
- Hands panel calibrated to keep fingertips visible in gameplay layout.
- Top bar currently shows 3 KPIs: Time, Net WPM, Accuracy.
- Accuracy now counts corrected mistakes (strict/effective accuracy).
