import SwiftUI

struct TopBarView: View {
    let time: String
    let netWPM: String
    let accuracy: String
    let completion: Double
    let isFullscreen: Bool

    private var progressBarWidth: CGFloat {
        isFullscreen ? 720 : 420
    }

    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                MetricView(label: "Time", value: time)
                MetricView(label: "Net WPM", value: netWPM)
                MetricView(label: "Accuracy", value: accuracy)
            }

            HStack {
                LevelProgressBar(progress: completion)
                    .frame(width: progressBarWidth)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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
