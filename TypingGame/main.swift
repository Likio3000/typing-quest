import Foundation
import SwiftUI

if SmokeTest.shouldRun {
    SmokeTest.emitReady()
    exit(0)
}

// Only the isolated UI-test build may reset its own preferences or use fixtures.
if Bundle.main.bundleIdentifier == "com.typinggame.app.uitesting",
   ProcessInfo.processInfo.environment["UI_TEST_RESET"] == "1" {
    UserDefaults.standard.removePersistentDomain(forName: "com.typinggame.app.uitesting")
}

TypingGameApp.main()
