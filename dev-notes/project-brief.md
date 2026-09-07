# Project Brief

- Product: macOS typing trainer app (display name: `Typing Quest`)
- Repo: `Typing_game`
- Platform: SwiftUI app + core module + unit/UI tests
- Current focus: scalable level catalog, minimal-ui filtering, progression flow, and measurement quality

## Current State Highlights

- Levels expanded from static set to generated catalog (`240` levels in current generated output).
- Level schema supports metadata: category, difficulty, tags, sort order, source.
- Levels panel includes category selection and progression visibility.
- Hands panel automatically aligns indicators to the fixed artwork’s fingertips; manual adjustment is optional.
- Top bar currently shows 3 KPIs: Time, Net WPM, Accuracy.
- Accuracy now counts corrected mistakes (strict/effective accuracy).

## Personal Installation

- Stable installed app: `/Users/alexbethune/Applications/Typing Quest.app` (updated 2026-09-07 with the validated normal build).
- Dock and Launch Services point to the stable installation. Redundant development app bundles are removed at project close; future builds recreate them from the updated checkout.
- Preference/Dock snapshots remain in `~/Library/Application Support/Typing Quest/Backups/`. Superseded app ZIPs and redundant app bundles are moved to Trash at Alex’s request.
