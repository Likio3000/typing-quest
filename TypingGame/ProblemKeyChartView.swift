import SwiftUI

struct ProblemKeyChartView: View {
    let problems: [(Character, Int)]

    var body: some View {
        if problems.isEmpty {
            Text("No mistakes yet.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.mutedText)
        } else {
            let maxCount = problems.map { $0.1 }.max() ?? 1
            VStack(alignment: .leading, spacing: 10) {
                ForEach(problems, id: \.0) { entry in
                    ProblemKeyBar(
                        label: KeyMapping.displayKeyName(for: entry.0),
                        count: entry.1,
                        maxCount: maxCount
                    )
                }
            }
        }
    }
}

struct ProblemKeyBar: View {
    let label: String
    let count: Int
    let maxCount: Int

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .frame(width: 52, alignment: .leading)

            GeometryReader { geometry in
                let ratio = maxCount > 0 ? CGFloat(count) / CGFloat(maxCount) : 0
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.sRGB, red: 0.93, green: 0.94, blue: 0.96, opacity: 1))
                    Capsule()
                        .fill(KeyCapView.nextKeyColor)
                        .frame(width: geometry.size.width * ratio)
                }
            }
            .frame(height: 10)

            Text("\(count)")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.mutedText)
                .frame(width: 28, alignment: .trailing)
        }
        .frame(height: 18)
    }
}
