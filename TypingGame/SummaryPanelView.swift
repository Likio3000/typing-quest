import SwiftUI
import TypingGameCore

struct SummaryPanelView: View {
    let stats: TypingStats
    let correctedErrors: Int
    let scoreText: String?
    let onRestart: (() -> Void)?

    var body: some View {
        Panel(title: "Summary") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    summaryPill(label: "Pending", value: "\(stats.pending)", valueID: UIID.summaryPendingValue)
                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    summaryPill(label: "Correct", value: "\(stats.correct)", valueID: UIID.summaryCorrectValue)
                    summaryPill(label: "Wrong", value: "\(stats.wrong)", valueID: UIID.summaryWrongValue)
                }

                HStack(spacing: 8) {
                    summaryPill(label: "Uncorrected", value: "\(stats.uncorrectedErrors)", valueID: UIID.summaryUncorrectedValue)
                    summaryPill(label: "Corrected", value: "\(correctedErrors)", valueID: UIID.summaryCorrectedValue)
                }

                if let scoreText {
                    Text("Score \(scoreText)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.accent)
                }

                if let onRestart {
                    Button("Restart") {
                        onRestart()
                    }
                    .buttonStyle(.bordered)
                    .uiTestLabel(UIID.restartLevel)
                }
            }
        }
    }

    private func summaryPill(label: String, value: String, valueID: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: true, vertical: false)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: true, vertical: false)
                .uiTestLabel(valueID, value: value)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Theme.metricBackground)
        .clipShape(Capsule())
        .fixedSize(horizontal: true, vertical: false)
    }
}
