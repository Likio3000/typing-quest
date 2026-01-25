import SwiftUI

struct TypingGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    SmokeTest.handleIfNeeded()
                }
        }
    }
}
