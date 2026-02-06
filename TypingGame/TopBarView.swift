import SwiftUI

struct TopBarView: View {
    let time: String
    let netWPM: String
    let accuracy: String

    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                MetricView(label: "Time", value: time)
                MetricView(label: "Net WPM", value: netWPM)
                MetricView(label: "Accuracy", value: accuracy)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.topBar)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
