import SwiftUI

enum Theme {
    static let backgroundTop = Color(.sRGB, red: 0.09, green: 0.11, blue: 0.16, opacity: 1)
    static let backgroundBottom = Color(.sRGB, red: 0.06, green: 0.08, blue: 0.12, opacity: 1)
    static let topBar = Color(.sRGB, red: 0.12, green: 0.15, blue: 0.22, opacity: 0.98)
    static let panel = Color(.sRGB, red: 0.14, green: 0.17, blue: 0.25, opacity: 1)
    static let panelBorder = Color(.sRGB, red: 0.24, green: 0.28, blue: 0.38, opacity: 1)
    static let panelShadow = Color(.sRGB, red: 0.0, green: 0.0, blue: 0.0, opacity: 0.35)
    static let surface = Color(.sRGB, red: 0.13, green: 0.16, blue: 0.24, opacity: 1)
    static let border = Color(.sRGB, red: 0.24, green: 0.28, blue: 0.38, opacity: 1)
    static let metricBackground = Theme.accent.opacity(0.2)
    static let keyBase = Color(.sRGB, red: 0.15, green: 0.19, blue: 0.28, opacity: 1)
    static let keyBorder = Color(.sRGB, red: 0.27, green: 0.32, blue: 0.44, opacity: 1)
    static let accent = Color(.sRGB, red: 0.98, green: 0.62, blue: 0.18, opacity: 1)
    static let primaryText = Color(.sRGB, red: 0.94, green: 0.95, blue: 0.98, opacity: 1)
    static let mutedText = Color(.sRGB, red: 0.82, green: 0.85, blue: 0.92, opacity: 1)
    static let placeholderText = Color(.sRGB, red: 0.68, green: 0.73, blue: 0.84, opacity: 1)
}
