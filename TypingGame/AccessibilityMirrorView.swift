import SwiftUI
import TypingGameCore

struct AccessibilityMirrorView: View {
    @ObservedObject var viewModel: ContentViewModel
    let stats: TypingStats

    var body: some View {
        Group {
            if UITesting.enabled {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selected: \(viewModel.selectedLevel.name)")
                        .accessibilityIdentifier(UIID.selectedLevelName)

                    Button(viewModel.isCalibratingHands ? "Done" : "Calibrate") {
                        viewModel.isCalibratingHands.toggle()
                    }
                    .accessibilityIdentifier(UIID.handCalibrate)

                    if viewModel.isCalibratingHands {
                        HStack(spacing: 8) {
                            Button("Zoom -") {
                                viewModel.handImageZoom = HandImageZoom.clamp(
                                    viewModel.handImageZoom - HandImageZoom.step
                                )
                            }
                            .accessibilityIdentifier(UIID.handZoomMinus)

                            Text("\(Int(viewModel.handImageZoom * 100))%")
                                .accessibilityIdentifier(UIID.handZoomValue)

                            Button("Zoom +") {
                                viewModel.handImageZoom = HandImageZoom.clamp(
                                    viewModel.handImageZoom + HandImageZoom.step
                                )
                            }
                            .accessibilityIdentifier(UIID.handZoomPlus)

                            Button("Reset Points") {
                                viewModel.handPoints = HandCalibration.defaultPoints
                            }
                            .accessibilityIdentifier(UIID.handResetPoints)
                        }
                    }

                    Button("Restart") {
                        viewModel.session.resetSession()
                    }
                    .accessibilityIdentifier(UIID.restartLevel)

                    Button("Left Hand") {
                        if let level = viewModel.levels.first(where: { $0.id == "letters-left-hand" }) {
                            viewModel.applyLevel(level)
                        }
                    }
                    .accessibilityIdentifier(UIID.levelRow("letters-left-hand"))

                    HStack(spacing: 8) {
                        Text("\(stats.correct)")
                            .accessibilityIdentifier(UIID.summaryCorrectValue)
                        Text("\(stats.wrong)")
                            .accessibilityIdentifier(UIID.summaryWrongValue)
                        Text("\(stats.pending)")
                            .accessibilityIdentifier(UIID.summaryPendingValue)
                    }

                    handPointProxy
                        .frame(width: 160, height: 160)
                }
            }
        }
    }

    private var handPointProxy: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let point = viewModel.handPoints[.leftIndex] ?? HandCalibration.defaultPoints[.leftIndex] ?? .zero
            let clamped = CGPoint(
                x: min(0.98, max(0.02, point.x)),
                y: min(0.98, max(0.02, point.y))
            )
            let position = CGPoint(x: clamped.x * size.width, y: clamped.y * size.height)

            Circle()
                .fill(Color.black.opacity(0.001))
                .frame(width: 22, height: 22)
                .position(position)
                .contentShape(Circle())
                .accessibilityIdentifier(UIID.handPointLeftIndex)
                .accessibilityLabel(
                    String(format: "%.3f,%.3f", Double(point.x), Double(point.y))
                )
                .accessibilityValue(
                    String(format: "%.3f,%.3f", Double(point.x), Double(point.y))
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard viewModel.isCalibratingHands else { return }
                            let normalized = CGPoint(
                                x: min(0.98, max(0.02, value.location.x / max(size.width, 1))),
                                y: min(0.98, max(0.02, value.location.y / max(size.height, 1)))
                            )
                            var updated = viewModel.handPoints
                            updated[.leftIndex] = normalized
                            viewModel.handPoints = updated
                        }
                )
        }
    }
}
