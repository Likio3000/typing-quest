import SwiftUI

struct KeyboardView: View {
    let highlightedKey: String?
    let highlightedShiftKeys: Set<String>
    let wrongKeyOpacities: [String: Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                KeyboardLegendItem(color: KeyCapView.nextKeyColor, label: "Next key")
                KeyboardLegendItem(color: KeyCapView.shiftKeyColor, label: "Shift")
                KeyboardLegendItem(color: KeyCapView.wrongKeyColor, label: "Wrong key")
                Spacer()
            }
            .font(.system(size: 11, weight: .semibold))

            KeyboardRowView(keys: Self.row1, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row2, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row3, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row4, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row5, highlight: highlight(for:))
        }
    }

    private func highlight(for keyID: String) -> KeyHighlight {
        KeyHighlight(
            isNext: keyID == highlightedKey,
            isShift: highlightedShiftKeys.contains(keyID),
            wrongOpacity: wrongKeyOpacities[keyID] ?? 0
        )
    }

    private static let row1: [KeyCap] = [
        KeyCap(keyID: "`", label: "`", width: 1),
        KeyCap(keyID: "1", label: "1", width: 1),
        KeyCap(keyID: "2", label: "2", width: 1),
        KeyCap(keyID: "3", label: "3", width: 1),
        KeyCap(keyID: "4", label: "4", width: 1),
        KeyCap(keyID: "5", label: "5", width: 1),
        KeyCap(keyID: "6", label: "6", width: 1),
        KeyCap(keyID: "7", label: "7", width: 1),
        KeyCap(keyID: "8", label: "8", width: 1),
        KeyCap(keyID: "9", label: "9", width: 1),
        KeyCap(keyID: "0", label: "0", width: 1),
        KeyCap(keyID: "-", label: "-", width: 1),
        KeyCap(keyID: "=", label: "=", width: 1),
        KeyCap(keyID: "delete", label: "del", width: 1.6)
    ]

    private static let row2: [KeyCap] = [
        KeyCap(keyID: "tab", label: "tab", width: 1.5),
        KeyCap(keyID: "q", label: "q", width: 1),
        KeyCap(keyID: "w", label: "w", width: 1),
        KeyCap(keyID: "e", label: "e", width: 1),
        KeyCap(keyID: "r", label: "r", width: 1),
        KeyCap(keyID: "t", label: "t", width: 1),
        KeyCap(keyID: "y", label: "y", width: 1),
        KeyCap(keyID: "u", label: "u", width: 1),
        KeyCap(keyID: "i", label: "i", width: 1),
        KeyCap(keyID: "o", label: "o", width: 1),
        KeyCap(keyID: "p", label: "p", width: 1),
        KeyCap(keyID: "[", label: "[", width: 1),
        KeyCap(keyID: "]", label: "]", width: 1),
        KeyCap(keyID: "\\", label: "\\", width: 1.5)
    ]

    private static let row3: [KeyCap] = [
        KeyCap(keyID: "caps", label: "caps", width: 1.8),
        KeyCap(keyID: "a", label: "a", width: 1),
        KeyCap(keyID: "s", label: "s", width: 1),
        KeyCap(keyID: "d", label: "d", width: 1),
        KeyCap(keyID: "f", label: "f", width: 1),
        KeyCap(keyID: "g", label: "g", width: 1),
        KeyCap(keyID: "h", label: "h", width: 1),
        KeyCap(keyID: "j", label: "j", width: 1),
        KeyCap(keyID: "k", label: "k", width: 1),
        KeyCap(keyID: "l", label: "l", width: 1),
        KeyCap(keyID: ";", label: ";", width: 1),
        KeyCap(keyID: "'", label: "'", width: 1),
        KeyCap(keyID: "return", label: "return", width: 2.2)
    ]

    private static let row4: [KeyCap] = [
        KeyCap(keyID: "shift-left", label: "shift", width: 2.4),
        KeyCap(keyID: "z", label: "z", width: 1),
        KeyCap(keyID: "x", label: "x", width: 1),
        KeyCap(keyID: "c", label: "c", width: 1),
        KeyCap(keyID: "v", label: "v", width: 1),
        KeyCap(keyID: "b", label: "b", width: 1),
        KeyCap(keyID: "n", label: "n", width: 1),
        KeyCap(keyID: "m", label: "m", width: 1),
        KeyCap(keyID: ",", label: ",", width: 1),
        KeyCap(keyID: ".", label: ".", width: 1),
        KeyCap(keyID: "/", label: "/", width: 1),
        KeyCap(keyID: "shift-right", label: "shift", width: 2.8)
    ]

    private static let row5: [KeyCap] = [
        KeyCap(keyID: "space", label: "space", width: 8)
    ]
}

struct KeyboardRowView: View {
    let keys: [KeyCap]
    let highlight: (String) -> KeyHighlight

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 6
            let totalUnits = keys.reduce(0) { $0 + $1.width }
            let unitWidth = (geometry.size.width - spacing * CGFloat(keys.count - 1)) / totalUnits

            HStack(spacing: spacing) {
                ForEach(keys, id: \.keyID) { key in
                    KeyCapView(
                        keyID: key.keyID,
                        label: key.label,
                        width: unitWidth * key.width,
                        highlight: highlight(key.keyID)
                    )
                }
            }
        }
        .frame(height: 34)
    }
}

struct KeyCapView: View {
    let keyID: String
    let label: String
    let width: CGFloat
    let highlight: KeyHighlight

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Self.baseColor)

            if let overlay = fullOverlayColor {
                RoundedRectangle(cornerRadius: 6)
                    .fill(overlay)
            }

            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(textColor)
                .padding(spaceNextHighlight ? EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 12) : .init())
                .background(
                    Group {
                        if spaceNextHighlight {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Self.nextKeyColor)
                        }
                    }
                )
        }
        .frame(width: width, height: 32)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .animation(.linear(duration: 0.05), value: highlight.wrongOpacity)
    }

    private var fullOverlayColor: Color? {
        if spaceNextHighlight {
            return nil
        }
        if highlight.isNext {
            return Self.nextKeyColor
        }
        if highlight.wrongOpacity > 0 {
            return Self.wrongKeyColor.opacity(highlight.wrongOpacity)
        }
        if highlight.isShift {
            return Self.shiftKeyColor
        }
        return nil
    }

    private var textColor: Color {
        if highlight.isNext || highlight.isShift || highlight.wrongOpacity > 0 {
            return Color.white
        }
        return Theme.primaryText
    }

    private var spaceNextHighlight: Bool {
        keyID == "space" && highlight.isNext
    }

    private var borderColor: Color {
        Theme.keyBorder
    }

    static let baseColor = Theme.keyBase
    static let nextKeyColor = Color(.sRGB, red: 0.88, green: 0.5, blue: 0.2, opacity: 1)
    static let shiftKeyColor = Color(.sRGB, red: 0.31, green: 0.44, blue: 0.62, opacity: 1)
    static let wrongKeyColor = Color(.sRGB, red: 0.86, green: 0.28, blue: 0.28, opacity: 1)
}

struct KeyboardLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }
}

struct KeyHighlight {
    let isNext: Bool
    let isShift: Bool
    let wrongOpacity: Double
}

struct KeyCap: Hashable {
    let keyID: String
    let label: String
    let width: CGFloat
}
