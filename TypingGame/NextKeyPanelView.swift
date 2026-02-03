import SwiftUI

struct NextKeyPanelView: View {
    let nextCharacter: Character?
    let nextKeyFontSize: CGFloat

    var body: some View {
        Panel(title: "Next key") {
            let contentHeight = nextKeyFontSize * 1.25

            if let nextCharacter,
               let info = KeyMapping.coachInfo(for: nextCharacter) {
                let displayKey = info.displayKey
                let displayFontSize = displayKey == "SPACE" ? nextKeyFontSize * 0.6 : nextKeyFontSize

                Text(displayKey)
                    .font(.system(size: displayFontSize, weight: .bold, design: .monospaced))
                    .foregroundColor(KeyCapView.nextKeyColor)
                    .frame(maxWidth: .infinity, minHeight: contentHeight, alignment: .center)
            } else {
                Text("Done")
                    .font(.system(size: nextKeyFontSize * 0.75, weight: .bold))
                    .frame(maxWidth: .infinity, minHeight: contentHeight, alignment: .center)
            }
        }
    }
}
