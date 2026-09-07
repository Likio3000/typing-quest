# Scroll bounds fix — 2026-09-07

## Reproduction and cause

- Verified the stable and original-project Debug executables were the automatic-guide build (`0219e7ce…`). Both personal copies were running. Personal window inspected with CUA; empty Problem keys state could reach both ends.
- Reproduced with five seeded errors in an isolated 1300×700 content window, without desktop typing. At the upper scroll limit, the top bar began 50 points above the viewport. Screenshot visibly clipped KPI cards.
- `mainContent.frame(height: max(980, viewport.height))` reported less height than its growing children and centered their overflow outside the scrollable document. A simple minimum-height replacement was insufficient: it let the nested levels list request its entire height.

## Change

- `DashboardLayout` measures header/keyboard and reserves the middle row's full minimum height.
- `DashboardColumnsLayout` measures the growing right column, then allocates a finite height to levels and hands. The document can grow beyond 980 without clipping either end or expanding to the entire level catalog.
- Removed inherited `scrollDisabled` at tall window heights; inner target/level scrolling remains enabled.
- Preserved native titlebar, padding, colors, automatic fingertip coordinates and preference storage.

## Focused verification

- Regression cases cover both extremes at 700 and 900 content heights with five error rows, plus 900 without errors. Assertions check full panel bounds and reachable Restart, Adjust and SPACE, not just existence.
- Reviewed before/after actual window captures: top KPI bar entirely below the titlebar at the upper limit; all five keyboard rows and bottom panel border visible at the lower limit, with Regenerate/Adjust reachable.
- Test-only fixture seeds errors only in `com.typinggame.app.uitesting`; it never types into the desktop or changes personal state. Replaced the project's generic fullscreen smoke launch with focused isolated checks to honor Alex's noninterference request.
- All three focused UI cases passed; normal build and `git diff --check` passed. Initial regression failed visibly on the old layout. A later test-only SPACE lookup was scoped to the keyboard because the error chart also contains that text.

## Delivery

- Normally quit both old personal copies via CUA. Backed up both bundles to validated `Typing-Quest-before-scroll-fix-{0,1}-20260907.zip` archives and preferences to `preferences-before-scroll-fix-20260907.plist` under `~/Library/Application Support/Typing Quest/Backups/`.
- Updated stable and original-project Debug apps; both match the normal build SHA256 `4ae7c2d6a55d48438abb468dd8233febf7ffc886024cc49c9279c30d9e493b82`. All preexisting preference keys compared unchanged at installation. Original source diff remains byte-for-byte identical to the imported baseline; no push.
- Reopened stable app; verified running PID 74639 and preferred Launch Services path `~/Applications/Typing Quest.app`. CUA snapshots confirmed top and bottom of the real installed app, including the entire SPACE row and lower border. CUA pointer scrolling could not bind the relaunched window; exposed AX scrollbar values 0/1 worked and screenshots verified the result. Left the app at the top.
