import SwiftUI

struct TargetPanelView: View {
    @ObservedObject var session: TypingSession
    let renderer: TargetTextRenderer
    @Binding var targetFontSize: Double
    let fontRange: ClosedRange<Double>
    let colors: TargetTextColors

    var body: some View {
        Panel(title: "Target") {
            let attributed = renderer.render(
                targetText: session.targetText,
                typedText: session.typedText,
                fontSize: targetFontSize,
                colors: colors
            )
            let scrollIndex = min(session.typedText.count, attributed.length)
            TargetTextScrollView(attributedText: attributed, scrollIndex: scrollIndex)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .overlay(alignment: .topLeading) {
                    TargetZoomShortcutsView(fontSize: $targetFontSize, fontRange: fontRange)
                }
        }
    }
}

private struct TargetZoomShortcutsView: View {
    @Binding var fontSize: Double
    let fontRange: ClosedRange<Double>

    var body: some View {
        HStack(spacing: 0) {
            Button {
                fontSize = max(fontRange.lowerBound, fontSize - 2)
            } label: {
                EmptyView()
            }
            .keyboardShortcut("-", modifiers: [.command])

            Button {
                fontSize = min(fontRange.upperBound, fontSize + 2)
            } label: {
                EmptyView()
            }
            .keyboardShortcut("=", modifiers: [.command])
        }
        .frame(width: 0, height: 0)
        .clipped()
        .opacity(0.001)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
