import Foundation
import SwiftUI

if SmokeTest.shouldRun {
    SmokeTest.emitReady()
    exit(0)
}

TypingGameApp.main()
