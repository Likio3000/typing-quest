import SwiftUI

struct HandsPanelView: View {
    let activeFingers: Set<FingerIdentifier>
    @Binding var points: [FingerIdentifier: CGPoint]
    @Binding var zoom: Double
    @Binding var isCalibrating: Bool

    var body: some View {
        Panel(title: "Hands") {
            VStack(alignment: .leading, spacing: 8) {
                if isCalibrating {
                    Text("Drag dots to align fingers.")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.mutedText)
                }

                HandGuideView(
                    activeFingers: activeFingers,
                    points: $points,
                    zoom: CGFloat(zoom),
                    isCalibrating: isCalibrating
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, -40)

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
                        Button("Reset") {
                            points = HandCalibration.defaultPoints
                        }
                        .buttonStyle(.bordered)
                        .uiTestLabel(UIID.handResetPoints)
                        Button("Reset Zoom") {
                            zoom = HandImageZoom.defaultZoom
                        }
                        .buttonStyle(.bordered)
                    }
                }

                HStack {
                    Spacer()
                    Button(isCalibrating ? "Done" : "Calibrate") {
                        isCalibrating.toggle()
                    }
                    .buttonStyle(.bordered)
                    .uiTestLabel(UIID.handCalibrate)
                    Spacer()
                }
            }
        }
    }
}
