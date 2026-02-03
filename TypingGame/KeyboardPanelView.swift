import SwiftUI

struct KeyboardPanelView: View {
    let highlightedKey: String?
    let highlightedShiftKeys: Set<String>
    let wrongKeyOpacities: [String: Double]

    var body: some View {
        Panel(title: "Keyboard") {
            KeyboardView(
                highlightedKey: highlightedKey,
                highlightedShiftKeys: highlightedShiftKeys,
                wrongKeyOpacities: wrongKeyOpacities
            )
        }
    }
}
