import SwiftUI
import TypingGameCore

struct LevelRow: View {
    let level: Level
    let isSelected: Bool
    let isLocked: Bool
    let bestScore: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(level.name)
                            .font(.system(size: 13, weight: .semibold))
                        if isLocked {
                            Text("LOCKED")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(Theme.placeholderText)
                        }
                    }
                    Text(level.description)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.mutedText)
                    Text("Length \(level.displayLength)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.mutedText)
                }
                Spacer(minLength: 0)
                scoreBadge
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? selectedBackground : Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? selectedBorder : idleBorder))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(isLocked ? 0.7 : 1)
        .disabled(isLocked)
        .buttonStyle(.plain)
        .uiTestLabel(UIID.levelRow(level.id))
    }

    private var selectedBackground: Color {
        Theme.metricBackground
    }

    private var selectedBorder: Color {
        Theme.accent
    }

    private var idleBorder: Color {
        Color(.sRGB, red: 0.84, green: 0.86, blue: 0.9, opacity: 1)
    }

    private var scoreBadge: some View {
        Text(bestScoreText)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(isLocked || bestScore == nil ? Theme.placeholderText : Theme.primaryText)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Theme.metricBackground.opacity(bestScore == nil ? 0.25 : 0.55))
            .clipShape(Capsule())
            .uiTestLabel(UIID.levelBestScore(level.id))
    }

    private var bestScoreText: String {
        if isLocked { return "Locked" }
        guard let bestScore else { return "—" }
        return String(format: "%.0f", bestScore)
    }
}
