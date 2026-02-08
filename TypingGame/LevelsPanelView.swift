import SwiftUI
import TypingGameCore

struct LevelsPanelView: View {
    let levels: [Level]
    let selectedLevel: Level
    let selectedLevelID: String
    let bestScores: [String: Double]
    let maxUnlockedDifficulty: Int
    let categories: [String]
    @Binding var selectedCategory: String
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

                categoryPicker

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(levels) { level in
                                LevelRow(
                                    level: level,
                                    isSelected: level.id == selectedLevelID,
                                    isLocked: level.difficulty > maxUnlockedDifficulty,
                                    bestScore: bestScores[level.id]
                                ) {
                                    onSelect(level)
                                }
                                .id(level.id)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 4)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260, alignment: .leading)
                    .contentShape(Rectangle())
                    .onAppear {
                        scrollToSelection(using: proxy, animated: false)
                    }
                    .onChange(of: selectedLevelID) { _ in
                        scrollToSelection(using: proxy)
                    }
                    .onChange(of: levels.map(\.id)) { _ in
                        scrollToSelection(using: proxy, animated: false)
                    }
                }

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

    private var categoryPicker: some View {
        return HStack(spacing: 8) {
            Text("Category")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.mutedText)

            Menu {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        if category == selectedCategory {
                            Label(category, systemImage: "checkmark")
                        } else {
                            Text(category)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedCategory)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Theme.border.opacity(0.9), lineWidth: 1)
                        )
                )
            }
            .foregroundStyle(.white)

            Spacer()
        }
    }

    private func scrollToSelection(using proxy: ScrollViewProxy, animated: Bool = true) {
        guard levels.contains(where: { $0.id == selectedLevelID }) else { return }
        let scrollAction = {
            proxy.scrollTo(selectedLevelID, anchor: .center)
        }
        if animated {
            withAnimation(.easeOut(duration: 0.2)) {
                scrollAction()
            }
        } else {
            scrollAction()
        }
    }
}
