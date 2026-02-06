import SwiftUI

struct TopBarView: View {
    let time: String
    let netWPM: String
    let accuracy: String
    let completion: Double

    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                MetricView(label: "Time", value: time)
                MetricView(label: "Net WPM", value: netWPM)
                MetricView(label: "Accuracy", value: accuracy)
            }

            HStack {
                Spacer()
                LevelProgressBar(progress: completion)
                    .frame(width: 220)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.topBar)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct LevelProgressBar: View {
    let progress: Double

    private var clampedProgress: CGFloat {
        CGFloat(max(0, min(1, progress)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Progress")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.mutedText)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.border.opacity(0.9))

                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: proxy.size.width * clampedProgress)
                }
            }
            .frame(height: 8)
        }
    }
}
