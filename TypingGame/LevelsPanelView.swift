import SwiftUI
import TypingGameCore

struct LevelsPanelView: View {
    let levels: [Level]
    let selectedLevel: Level
    let selectedLevelID: String
    let bestScores: [String: Double]
    let onSelect: (Level) -> Void
    let onRegenerate: () -> Void

    var body: some View {
        Panel(title: "Levels") {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    let selectedText = "Selected: \(selectedLevel.name)"
                    Text(selectedText)
                        .font(.system(size: 13, weight: .semibold))
                        .uiTestLabel(UIID.selectedLevelName, value: selectedText)
                    Text(selectedLevel.description)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.mutedText)
                }

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(levels) { level in
                            LevelRow(
                                level: level,
                                isSelected: level.id == selectedLevelID,
                                bestScore: bestScores[level.id]
                            ) {
                                onSelect(level)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 4)
                }
                .frame(maxWidth: .infinity, minHeight: 260, alignment: .leading)
                .contentShape(Rectangle())

                HStack {
                    Spacer()
                    Button("Regenerate level") {
                        onRegenerate()
                    }
                    .buttonStyle(.bordered)
                    .uiTestLabel(UIID.levelRegenerate)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
