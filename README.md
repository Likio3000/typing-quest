# Typing Quest

A focused macOS typing trainer with per-level practice, live coaching, and performance scoring.

## Features

- Multiple curated levels (letters, numbers, symbols, stories, and data-entry style passages).
- Real-time stats (WPM, accuracy, KPM) and error tracking.
- Best score per level, weighted by accuracy, errors, and speed.
- On-screen next-key coaching and finger guide with calibratable hand overlay.

## Scoring (Best Score)

Score is accuracy‑based (0–100) with penalties for errors and a speed bonus vs a 60 WPM target.
Scores never go below zero; faster can push the score above 100.

## Development

- Build: `make build`
- Run: `make run`
- Smoke test after changes: `make smoke`
  - Runs the app smoke launch and `xcodebuild test` (UI + unit tests).
  - Direct script usage (after `make build`):
    `scripts/smoke_run.sh "build/Build/Products/Debug/Typing Quest.app/Contents/MacOS/Typing Quest"`
