# Architecture

## Modules

- `TypingGame/`: app UI, view models, interaction/session flow
- `TypingGameCore/`: shared domain logic and model decoding
- `TypingGameTests/`: unit/integration-style tests
- `TypingGameUITests/`: UI behavior tests
- `LevelsSource/`: source-of-truth assets for generated levels
- `scripts/`: automation helpers (`generate_levels.py`, smoke script)

## Core Data Flow

1. `TypingGame/levels.json` is loaded by `LevelCatalog` in `TypingGameCore/Levels.swift`.
2. `ContentViewModel` provides filtered levels and progression gating.
3. `TypingSession` computes typing metrics in real time.
4. `ScoreCalculator` combines accuracy, penalties, and speed bonus for final score.
5. Best scores are persisted in `UserDefaults` via `LevelScoreStore`.

## Level Generation Pipeline

- Source spec: `LevelsSource/spec.json`
- Generator: `scripts/generate_levels.py`
- Output: `TypingGame/levels.json`
- Make target: `make levels`

## Hand Overlay

- `HandGuideView.HandImageLayout` defines one uniform image rectangle and reversible conversion between panel coordinates and literal image UV coordinates (v2).
- Ten default points are measured nail centers on the fixed Jan 23 artwork. Framing keeps those landmarks visible at supported zooms. Legacy v1 preferences are retained but ignored; manual overrides use `hands.points.v2`.
- `ContentViewModel` persists point and zoom changes through property observers; resizing does not write new calibration coordinates.
- Calibration controls are overlays and do not participate in the image viewport's layout. ContentView uses a vertical scroll fallback below the main layout's comfortable height instead of clipping it.
- UI test isolation is configured by `TYPINGGAME_APP_ID`; normal app ID is unchanged. Only the isolated build accepts explicit preference-reset and short-text/window fixtures. View-model initialization never erases preferences merely because XCTest is present.
- Completion popup is an explicit accessibility container so child identifiers remain discoverable.

## Dashboard sizing

- `DashboardLayout` measures the header and keyboard and allocates the middle row from its full minimum height. `DashboardColumnsLayout` measures the right column with an unconstrained height, then gives all columns a finite height. This prevents growing error statistics from overflowing the outer scroll document and avoids measuring the entire nested levels list.
- `main-scroll` always allows scrolling; the content has a minimum height of 980, never a fixed maximum. Nested target/level scrolling must remain enabled on tall windows too.
