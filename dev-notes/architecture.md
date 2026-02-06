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
