import AppKit
import SwiftUI

struct TypingGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    SmokeTest.handleIfNeeded()
                }
        }
        .commands {
            CommandGroup(after: .windowSize) {
                Button("Toggle Full Screen") {
                    NSApp.keyWindow?.toggleFullScreen(nil)
                }
                .keyboardShortcut("f", modifiers: [.control, .command])
            }
        }
    }
}
