import SwiftUI

struct HandsPanelView: View {
    let activeFingers: Set<FingerIdentifier>
    @Binding var points: [FingerIdentifier: CGPoint]
    @Binding var zoom: Double
    @Binding var isCalibrating: Bool

    var body: some View {
        Panel(title: "Hands") {
            VStack(alignment: .leading, spacing: 8) {
                HandGuideView(
                    activeFingers: activeFingers,
                    points: $points,
                    zoom: CGFloat(zoom),
                    isCalibrating: isCalibrating
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, -40)
                .overlay(alignment: .topLeading) {
                    if isCalibrating {
                        Text("Optional adjustment. Automatic restores the finger guide.")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Theme.mutedText)
                    }
                }
                .overlay(alignment: .bottom) {
                    if isCalibrating {
                        HStack {
                            HStack(spacing: 8) {
                                Text("Image Zoom")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.mutedText)
                                Button("Zoom -") {
                                    zoom = HandImageZoom.clamp(zoom - HandImageZoom.step)
                                }
                                .buttonStyle(.bordered)
                                .uiTestLabel(UIID.handZoomMinus)
                                let zoomValue = "\(Int(zoom * 100))%"
                                Text(zoomValue)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.mutedText)
                                    .frame(width: 44, alignment: .center)
                                    .overlay {
                                        if UITesting.enabled {
                                            Text(zoomValue)
                                                .font(.system(size: 1))
                                                .opacity(0.01)
                                                .accessibilityElement()
                                                .accessibilityIdentifier(UIID.handZoomValue)
                                                .accessibilityLabel(zoomValue)
                                                .accessibilityValue(zoomValue)
                                        }
                                    }
                                Button("Zoom +") {
                                    zoom = HandImageZoom.clamp(zoom + HandImageZoom.step)
                                }
                                .buttonStyle(.bordered)
                                .uiTestLabel(UIID.handZoomPlus)
                            }
                            Spacer()
                            Button("Automatic") {
                                points = HandCalibration.defaultPoints
                            }
                            .buttonStyle(.bordered)
                            .uiTestLabel(UIID.handResetPoints)
                            Button("Reset Zoom") {
                                zoom = HandImageZoom.defaultZoom
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(6)
                        .background(Theme.panel.opacity(0.95))
                    }
                }

                HStack {
                    Text(points == HandCalibration.defaultPoints ? "Auto-aligned finger guide" : "Custom finger guide")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.mutedText)
                        .accessibilityIdentifier("hand-alignment-mode")
                    Spacer()
                    Button(isCalibrating ? "Done" : "Adjust…") {
                        isCalibrating.toggle()
                    }
                    .buttonStyle(.bordered)
                    .uiTestLabel(UIID.handCalibrate)
                }
            }
        }
    }
}
