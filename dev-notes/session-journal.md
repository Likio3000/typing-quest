# Session Journal

## 2026-02-06

- Added scalable levels infrastructure and generated expanded `levels.json` from `LevelsSource`.
- Added level metadata support (`category`, `difficulty`, `tags`, `sortOrder`, `source`).
- Added minimal category-focused level filtering UI.
- Tuned hands image zoom/offset for full fingertip visibility.
- Simplified top bar KPIs to Time / Net WPM / Accuracy.
- Added difficulty-based progression and lock visualization.
- Updated accuracy to include corrected mistakes.
- Added top-bar level completion progress bar in fullscreen gameplay layout.
- Updated category picker selected text styling to high-contrast white.
- Added persistent repo memory policy (`AGENTS.md`) and memory-skill maintenance rules.
- Verified test pass via `xcodebuild ... test` (349 tests, 0 failures).
- Added `make fresh-run` target to clean, rebuild, and launch the app in one command.
- Updated make run flow to auto-stop after a timed window (`RUN_FOR`, default 20s), plus `make run-live` for manual sessions.
- Set default end-of-task runtime check policy to `make run RUN_FOR=20`.
- Widened top-bar progress line from compact to long format for better visibility.
- Updated make run targets to auto-attempt fullscreen before the timed run window.
- Progress bar now expands further only in fullscreen while keeping prior width in windowed mode.
- Increased fullscreen progress bar width again and kept it trailing-anchored so extra width grows toward center.
- Removed "Progress" label text from the top-bar progress element.
