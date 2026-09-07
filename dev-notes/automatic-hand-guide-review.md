# Automatic hand guide — 2026-09-07

Alex needs to play without dragging calibration dots. This supersedes the earlier v1 geometry-preservation decision in calibration-review.md.

- Measured ten nail centers on the bundled Jan 23 1536×1024 artwork, including thumbs at y=482 rather than the old lower positions.
- Points now use actual top-left image UVs and exactly the same uniform image rectangle as the artwork. Framing keeps default fingertips visible at supported zooms, including wide/short panels.
- Normal launch says “Auto-aligned finger guide”; “Adjust…” is optional and “Automatic” restores the measured defaults.
- New manual overrides use `hands.points.v2`. Existing v1 data is deliberately ignored and retained for recovery; zoom preferences remain unchanged. Other user data is not reset.

## Focused verification

- Normal build and isolated test build succeeded.
- Five HandLayoutRegressionTests passed, including measured artwork regions, recovery of legacy preferences, override persistence, and 18 size/zoom combinations.
- Visually inspected actual SwiftUI renders at 600×300/88%, 1200×240/135%, 420×550/75%, 900×400/88%. All ten centers sit on the intended fingertips. Renders: `/tmp/typing-auto-alignment/` (temporary).
- No broad UI suite was run for this follow-up. One isolated launch test checks automatic status and absence of adjustment controls; it uses the existing bounded runner.
- The isolated first-launch UI check passed. Its initial failure was a test-only AX label/value lookup mismatch; corrected to use the existing elementText helper.

## Installed delivery

- Updated and signature-verified `~/Applications/Typing Quest.app` and the original project's Debug app copy; executable SHA256 matches in both and the worktree build: `0219e7ce7250124b67558abd8b986a7aa3f1db1f59f429e68ebd22f6e90b27b2`.
- Reopened stable installation; running process and Launch Services preferred path verified. The original-project app was normally quit before replacement.
- Backups: `~/Library/Application Support/Typing Quest/Backups/preferences-before-auto-alignment-20260907.plist` and `Typing-Quest-before-auto-alignment-{0,1}-20260907.zip` (validated). Legacy point and zoom preferences compared unchanged after launch; v2 absent, so anatomical defaults apply.
- Original source diff remains byte-for-byte identical to the imported baseline; no push/publication or level expansion. `git diff --check` passed.
