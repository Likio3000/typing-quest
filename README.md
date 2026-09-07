# Typing Quest

A native macOS typing trainer built with SwiftUI. Practice short drills or longer passages while the app shows the next key and the finger to use, tracks mistakes, and saves your best score for each level.

## Features

- 240 curated and generated levels covering letters, numbers, symbols, stories, and data entry.
- Category filters and difficulty-based progression.
- Live elapsed time, Net WPM, accuracy, and completion progress.
- A keyboard guide with next-key, Shift, and recent-error highlights.
- An automatically aligned finger guide; manual adjustment is optional.
- Problem-key tracking, an error summary, and a rolling 30-second speed chart.
- Completion scores, accuracy-based stars, and locally saved best scores.

## Requirements

- macOS 13 Ventura or later.
- Xcode with macOS development tools selected for command-line builds.
- Python 3 for level generation and test helper scripts.

The project targets macOS 13 and was validated with Xcode 26.2 on Apple silicon. There are no third-party package dependencies to install. This repository provides source code; the steps below build a local app.

## Build and launch

```sh
git clone https://github.com/Likio3000/typing-quest.git
cd typing-quest
make build
open "build/Build/Products/Debug/Typing Quest.app"
```

Alternatively, open `TypingGame.xcodeproj` in Xcode, select the **TypingGame** scheme and **My Mac**, then choose **Run**.

To keep a regular installation, copy the built **Typing Quest.app** into your user Applications folder using Finder. Launch that copy for everyday practice. After rebuilding, quit the installed app before replacing it with the new build.

Development helpers:

```sh
make run FULLSCREEN=0 RUN_FOR=20   # Launch, then stop after 20 seconds
make run-live FULLSCREEN=0        # Run until you quit the app
```

The `make run` helpers default to fullscreen when `FULLSCREEN=0` is omitted.

## Practice

1. Choose an unlocked level from **Levels**, optionally narrowing the category.
2. Start typing the target passage. The timer starts with your first input.
3. Follow **Next key**, the highlighted keyboard key, and the orange fingertip indicator. Use Backspace to correct mistakes.
4. Finish the passage to see your score and stars. Press **Enter** to advance when the completion popup offers a next level.

**Restart** clears the current attempt. **Regenerate level** starts a fresh attempt with text generated for the selected level. Best scores and level selection are stored locally.

The hand guide is aligned to its bundled artwork automatically and stays aligned when the panel changes size. **Adjust…** opens optional point dragging and image zoom controls; **Automatic** restores the default finger positions, and **Done** returns to practice.

### Controls and windows

- **Command–minus / Command–plus:** decrease/increase target text size.
- **Window → Zoom:** maximize or restore the window.
- **Control–Command–F**, or **Window → Toggle Full Screen:** enter or leave fullscreen.
- Scroll the main page in shorter windows to reach the full top bar and keyboard. The level list and target text have their own scroll areas. The page also accommodates a growing problem-key panel.

### Accuracy and scoring

Accuracy includes corrected mistakes: fixing an error does not erase it from the accuracy calculation. The score combines accuracy, error penalties, and a speed bonus relative to 60 WPM. It is floored at zero and can exceed 100. Completion stars use accuracy thresholds: 80%, 90%, and 95%.

## Validation and development

Run the unit tests against an isolated preferences domain:

```sh
xcodebuild -project TypingGame.xcodeproj -scheme TypingGame \
  -configuration Debug -derivedDataPath build/ui-isolated \
  TYPINGGAME_APP_ID=com.typinggame.app.uitesting \
  test -destination 'platform=macOS' -only-testing:TypingGameTests
```

`make smoke` performs a short launch check and isolated unit tests. It does not start interactive UI automation. The smoke script accepts an app bundle or executable path; `SMOKE_TIMEOUT` and `SMOKE_TEST_TIMEOUT` control its deadlines.

Run only explicitly selected UI checks:

```sh
make ui-test UI_TESTS='testAppLaunchShowsCalibrate testScrollExtremesWithErrorsInShortWindow'
```

UI checks use a separate bundle identifier, verify their build path and foreground process, run one case at a time with a deadline, and stop on failure. Avoid interacting with the desktop during these checks. Logs are written to `build/ui-isolated/bounded-logs/`. The UI runner currently selects Apple silicon (`arm64`).

To regenerate and validate the level catalog:

```sh
make levels
```

Development context and validation records are in `dev-notes/`. Generated builds and Xcode user state are excluded from Git.
