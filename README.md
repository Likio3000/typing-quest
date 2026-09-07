# Typing Quest

A focused macOS typing trainer with per-level practice, live coaching, and performance scoring.

## Features

- 240 generated and curated levels spanning letters, numbers, symbols, stories, and data-entry passages.
- Difficulty-based progression, category filtering, saved best scores, and Enter-to-advance navigation.
- Live time, Net WPM, strict accuracy, completion progress, error summaries, and a rolling speed trend.
- On-screen next-key coaching, problem-key tracking, keyboard highlighting, and a calibratable finger guide.

## Scoring (Best Score)

Score is accuracy‑based (0–100) with penalties for errors and a speed bonus vs a 60 WPM target.
Scores never go below zero; faster can push the score above 100.

## Development

- Build: `make build`
- Timed local run (20 seconds by default): `make run`
- Live local run: `make run-live`
- Regenerate and validate `TypingGame/levels.json`: `make levels`
- Unit tests:
  `xcodebuild -project TypingGame.xcodeproj -scheme TypingGame -configuration Debug -derivedDataPath build test -destination 'platform=macOS,arch=arm64' -only-testing:TypingGameTests`
- Full smoke launch and test suite: `make smoke`

The smoke script accepts either the app bundle or executable path. Its launch and test timeouts can be adjusted with `SMOKE_TIMEOUT` and `SMOKE_TEST_TIMEOUT`.
