import SwiftUI

struct ProblemKeysPanelView: View {
    let problems: [(Character, Int)]

    var body: some View {
        Panel(title: "Problem keys") {
            ProblemKeyChartView(problems: problems)
        }
    }
}
