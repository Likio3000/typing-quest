import SwiftUI

struct TargetPanelView: View {
    @ObservedObject var session: TypingSession
    let renderer: TargetTextRenderer
    @Binding var targetFontSize: Double
    let fontRange: ClosedRange<Double>
    let colors: TargetTextColors

    var body: some View {
        Panel(title: "Target") {
            VStack(alignment: .leading, spacing: 8) {
                TargetZoomControlsView(fontSize: $targetFontSize, fontRange: fontRange)
                let attributed = renderer.render(
                    targetText: session.targetText,
                    typedText: session.typedText,
                    fontSize: targetFontSize,
                    colors: colors
                )
                let scrollIndex = min(session.typedText.count, attributed.length)
                TargetTextScrollView(attributedText: attributed, scrollIndex: scrollIndex)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

private struct TargetZoomControlsView: View {
    @Binding var fontSize: Double
    let fontRange: ClosedRange<Double>

    var body: some View {
        HStack(spacing: 10) {
            Text("Text size")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.mutedText)

            Button {
                fontSize = max(fontRange.lowerBound, fontSize - 2)
            } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("-", modifiers: [.command])

            Text("\(Int(fontSize)) pt")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .frame(minWidth: 64, alignment: .leading)

            Button {
                fontSize = min(fontRange.upperBound, fontSize + 2)
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("=", modifiers: [.command])

            Button("Reset") {
                fontSize = 22
            }
            .buttonStyle(.borderless)

            Spacer()
        }
        .padding(.bottom, 4)
    }
}
