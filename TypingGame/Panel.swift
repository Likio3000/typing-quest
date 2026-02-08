import SwiftUI

struct Panel<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panelColor)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(panelBorderColor))
        .shadow(color: panelShadowColor, radius: 6, x: 0, y: 3)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var panelColor: Color {
        Theme.panel
    }

    private var panelBorderColor: Color {
        Theme.panelBorder
    }

    private var panelShadowColor: Color {
        Theme.panelShadow
    }
}

struct MetricView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.mutedText)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Theme.topBarMetricBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
