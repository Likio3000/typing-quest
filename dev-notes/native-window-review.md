# Native window investigation — 2026-09-07

## Exact instance and delivery

- Read-only process inspection found personal PID 71207 at `/Users/alexbethune/Projects/Typing_game/build/Build/Products/Debug/Typing Quest.app/Contents/MacOS/Typing Quest`.
- Its initial executable SHA-256 was `709b33df0f7fdabb5c4d522b3fd93aab30da127a86de5d3908f16c23d51053e2`; this differed from the worktree build (`652fba8f4a274b4997742360f8e83aaef51604eae53863f965e00982d6b87f2f` before this follow-up). The personal instance was not the corrected worktree app.
- No activation, closure, force quit, installation replacement or permission changes were performed on the personal app. Tests use the distinct `.uitesting` bundle ID and exact-path/nonce/focus guards.
- Updated normal app: `build/Build/Products/Debug/Typing Quest.app` in this worktree. Quit the old app normally before opening this specific build to avoid ambiguous duplicate instances.

## Evidence and changes

- Red native close passed in the corrected test copy.
- First Option+green maximized the test copy. After the second click at the screen's top-left controls, recorded video showed Codex in front and the game AX hierarchy temporarily reported a disabled dialog. A floating Codex voice panel occupied that corner. This supports external overlay/focus interference; it does not prove a broken NSWindow button or conclusively attribute every earlier symptom to the panel.
- Using the unobscured native Window → Zoom menu, maximize/restore and red close passed. No titlebar, styleMask or traffic-light overrides were introduced.
- Green fullscreen entry succeeded, but Control–Command–F initially did not leave fullscreen. KeyCaptureNSView silently discarded Command/Control events; it now forwards them to the responder chain. This correction alone did not make the shortcut work in the UI run.
- Added an explicit Window → Toggle Full Screen command with Control–Command–F, invoking the key window's native toggleFullScreen action. The complete round trip then passed, including restored dimensions, shrinking both width and height, and red close.
- Prior responsive fixes remain: smaller minimum height and vertical overflow scrolling avoid content clipped under the titlebar/below the window. The personal old build had not received them.
- Apple's shortcut reference describes Control–Command–F as entering/leaving fullscreen in supported apps: https://support.apple.com/en-us/102650 . The new binding is verified locally, not inferred solely from that reference.

## Focused validation (no general suite rerun)

- `testNativeCloseButtonClosesWindow`: passed.
- `testNativeZoomRestoresWindowAndCloseStillWorks`: passed via native Window → Zoom.
- `testNativeFullscreenRoundTripRestoresResizableWindow`: passed after explicit command; native green entry, shortcut exit, original width/height restored, both axes shrunk by over 50 points, red close.
- `testTypingUpdatesCorrectOrWrong`: passed after key-command changes.
- `KeyCaptureResponderTests/testCommandAndControlEventsContinueThroughResponderChainWithoutTyping`: passed; three modifier combinations reached the next responder and produced zero typing inputs.
- Test build passed; normal production build passed. Prior 27-case UI and 360-unit results remain historical evidence from the preceding phase, not claimed as fresh full-suite runs for this small follow-up.
- Logs: `build/ui-isolated/bounded-logs/testNative*.log`. Fullscreen success bundle: `build/ui-isolated/Logs/Test/Test-TypingGame-2026.09.07_11-25-00-+1000.xcresult`. Key responder bundle: `build/ui-isolated/Logs/Test/Test-TypingGame-2026.09.07_11-21-45-+1000.xcresult`.

## Limits

- Restore/close behind the floating overlay was not forced; the panel and personal session were left untouched. The reliable tested alternatives are Window → Zoom and Control–Command–F.
- Physical monitor switching and live transfer of the user's current session to the updated app were not tested/performed.
- No push, publication or level expansion.

## Subsequent installation authorized and completed

- Alex subsequently authorized updating the habitual installation and accesses. The earlier no-replacement statements describe the investigation phase only.
- Installed the normal validated build at `/Users/alexbethune/Applications/Typing Quest.app` and updated the original project's built app for old direct-path compatibility.
- Dock had pointed to a nonexistent Xcode DerivedData path; changed only its Typing Quest tile to the stable installation, preserving other items. Retired development/test/stale registrations and registered the stable app.
- CUA Finder/Dock inspection failed with cgWindowNotFound/timeout (not an approval rejection). Used the native Dock preference interface and restarted Dock; no UI test input was used during installation.
- Verified macOS preferred bundle lookup, persisted Dock URL and active launched process PID 72943 all resolve to the stable installation. Executable SHA-256 `677aafeb074bebcb15b06c57a96a8b40a8a2e1b306d10116c1cc9b70bfea3af1` matches the validated build; deep/strict code-signature verification passed.
- `hands.points.v1` and `hands.imageZoom.v1` matched the pre-install values exactly. Original source checkout's Git diff matched its pre-install snapshot byte-for-byte.
- Old app ZIP: `~/Library/Application Support/Typing Quest/Backups/Typing-Quest-original-build-20260907.zip`; archive integrity verified. Preference/Dock snapshots are in the same directory; their contents are not stored in repository notes.
