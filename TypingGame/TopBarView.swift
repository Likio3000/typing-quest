import SwiftUI

struct TopBarView: View {
    let time: String
    let grossWPM: String
    let netWPM: String
    let accuracy: String
    let kpm: String

    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                MetricView(label: "Time", value: time)
                MetricView(label: "Gross WPM", value: grossWPM)
                MetricView(label: "Net WPM", value: netWPM)
                MetricView(label: "Accuracy", value: accuracy)
                MetricView(label: "KPM", value: kpm)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.topBar)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
