import AppKit
import SwiftUI

enum FingerIdentifier: String, CaseIterable, Hashable {
    case leftThumb
    case leftIndex
    case leftMiddle
    case leftRing
    case leftPinky
    case rightThumb
    case rightIndex
    case rightMiddle
    case rightRing
    case rightPinky

    static func from(label: String) -> [FingerIdentifier] {
        switch label {
        case "Left pinky":
            return [.leftPinky]
        case "Left ring":
            return [.leftRing]
        case "Left middle":
            return [.leftMiddle]
        case "Left index":
            return [.leftIndex]
        case "Right index":
            return [.rightIndex]
        case "Right middle":
            return [.rightMiddle]
        case "Right ring":
            return [.rightRing]
        case "Right pinky":
            return [.rightPinky]
        case "Thumbs":
            return [.leftThumb, .rightThumb]
        default:
            return []
        }
    }

    var shortLabel: String {
        switch self {
        case .leftThumb:
            return "LT"
        case .leftIndex:
            return "LI"
        case .leftMiddle:
            return "LM"
        case .leftRing:
            return "LR"
        case .leftPinky:
            return "LP"
        case .rightThumb:
            return "RT"
        case .rightIndex:
            return "RI"
        case .rightMiddle:
            return "RM"
        case .rightRing:
            return "RR"
        case .rightPinky:
            return "RP"
        }
    }
}

struct HandGuideView: View {
    let activeFingers: Set<FingerIdentifier>
    @Binding var points: [FingerIdentifier: CGPoint]
    let zoom: CGFloat
    let isCalibrating: Bool
    @State private var dragOrigin: CGPoint?

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let baseDot = min(28, max(12, min(size.width, size.height) * 0.07))
            let dotSize = isCalibrating ? baseDot * 1.15 : baseDot
            let imageSize = Self.baseImage?.size ?? size
            let layout = HandImageLayout(
                viewSize: size,
                imageSize: imageSize,
                zoom: zoom,
                zoomX: Self.imageZoomX
            )

            ZStack {
                if let image = Self.baseImage {
                    Image(nsImage: image)
                        .resizable()
                        .renderingMode(.original)
                        .brightness(-0.2)
                        .contrast(1.05)
                        .frame(width: layout.imageRect.width, height: layout.imageRect.height)
                        .position(x: layout.imageRect.midX, y: layout.imageRect.midY)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.surface)
                        .overlay(
                            Text("Hands image missing")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.mutedText)
                        )
                }

                ForEach(Self.baseImage == nil ? [] : FingerIdentifier.allCases, id: \.self) { finger in
                    let point = points[finger] ?? HandCalibration.defaultPoints[finger] ?? .zero
                    let pointPosition = layout.position(for: point)
                    let valueText = String(format: "%.3f,%.3f", point.x, point.y)
                    let isActive = activeFingers.contains(finger)
                    let visible = isCalibrating || isActive

                    Circle()
                        .fill(Theme.accent)
                        .frame(width: dotSize, height: dotSize)
                        .contentShape(Circle())
                        .allowsHitTesting(isCalibrating)
                        .opacity(visible ? (isActive ? 0.95 : 0.5) : 0)
                        .shadow(
                            color: Theme.accent.opacity(isActive ? 0.9 : 0.3),
                            radius: 8
                        )
                        .animation(.easeInOut(duration: 0.15), value: activeFingers)
                        .accessibilityElement()
                        .uiTestLabel(UIID.handPoint(finger.rawValue), value: valueText)
                        .accessibilityLabel(UITesting.enabled ? "\(finger.shortLabel) \(valueText)" : finger.shortLabel)
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .named("hands"))
                                .onChanged { value in
                                    guard isCalibrating else { return }
                                    // Preserve the grab offset: clicking the edge must not snap
                                    // the dot's center to the pointer.
                                    if dragOrigin == nil { dragOrigin = point }
                                    let start = layout.position(for: dragOrigin ?? point)
                                    points[finger] = clampPoint(layout.normalizedPoint(from: CGPoint(
                                        x: start.x + value.translation.width,
                                        y: start.y + value.translation.height
                                    )))
                                }
                                .onEnded { _ in dragOrigin = nil }
                        )
                        .position(x: pointPosition.x, y: pointPosition.y)

                    if isCalibrating {
                        Text(finger.shortLabel)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.primaryText)
                            .allowsHitTesting(false)
                            .position(
                                x: pointPosition.x,
                                y: pointPosition.y - dotSize * 0.9
                            )
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .clipped()
            .coordinateSpace(name: "hands")
        }
    }

    private static let imageZoomX: CGFloat = 1.25
    private static let imageOffsetY: CGFloat = 24

    // Landmarks below belong to this exact fixed artwork. A different image must
    // supply its own landmarks instead of silently reusing these coordinates.
    static let imageName = "ChatGPT Image Jan 23, 2026 at 11_17_06 PM"
    static let baseImage: NSImage? = NSImage(named: imageName)

    struct HandImageLayout {
        let viewSize: CGSize
        let imageSize: CGSize
        let zoom: CGFloat
        let zoomX: CGFloat

        var imageRect: CGRect {
            let safeImageSize = CGSize(width: max(1, imageSize.width), height: max(1, imageSize.height))
            let width = max(1, viewSize.width)
            let height = max(1, viewSize.height)
            let margin = min(24, min(width, height) * 0.15)
            let tips = Array(HandCalibration.defaultPoints.values)
            let minX = tips.map(\.x).min() ?? 0
            let maxX = tips.map(\.x).max() ?? 1
            let minY = tips.map(\.y).min() ?? 0
            let maxY = tips.map(\.y).max() ?? 1
            let requestedScale = max(width / safeImageSize.width, height / safeImageSize.height) * zoomX * zoom
            // Keep every fingertip visible even in a wide/short panel or at high
            // zoom. Image and markers share this same uniformly scaled rectangle.
            let fitX = (width - 2 * margin) / (safeImageSize.width * (maxX - minX))
            let fitY = (height - 2 * margin) / (safeImageSize.height * (maxY - minY))
            let scale = max(0.0001, min(requestedScale, fitX, fitY))
            let scaledWidth = safeImageSize.width * scale
            let scaledHeight = safeImageSize.height * scale
            let desiredX = (width - scaledWidth) / 2
            let desiredY = (height - scaledHeight) / 2 + HandGuideView.imageOffsetY
            let origin = CGPoint(
                x: min(max(desiredX, margin - minX * scaledWidth), width - margin - maxX * scaledWidth),
                y: min(max(desiredY, margin - minY * scaledHeight), height - margin - maxY * scaledHeight)
            )
            return CGRect(origin: origin, size: CGSize(width: scaledWidth, height: scaledHeight))
        }

        func position(for normalized: CGPoint) -> CGPoint {
            let rect = imageRect
            return CGPoint(
                x: rect.minX + rect.width * normalized.x,
                y: rect.minY + rect.height * normalized.y
            )
        }

        func normalizedPoint(from location: CGPoint) -> CGPoint {
            let rect = imageRect
            return CGPoint(
                x: (location.x - rect.minX) / rect.width,
                y: (location.y - rect.minY) / rect.height
            )
        }
    }

    private func clampPoint(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(0.98, max(0.02, point.x)),
            y: min(0.98, max(0.02, point.y))
        )
    }
}

struct HandCalibration {
    private struct NormalizedPoint: Codable {
        let x: Double
        let y: Double

        var cgPoint: CGPoint {
            CGPoint(x: x, y: y)
        }
    }

    static let storageKey = "hands.points.v2"
    static let legacyStorageKey = "hands.points.v1"

    // Nail/fingertip centers measured on the 1536 × 1024 artwork, top-left origin.
    // v1 values were not actual image UVs and are deliberately not adopted here.
    // They remain untouched in UserDefaults, so migration is reversible.
    static let defaultPoints: [FingerIdentifier: CGPoint] = [
        .leftPinky: CGPoint(x: 397.0 / 1536, y: 378.0 / 1024),
        .leftRing: CGPoint(x: 476.0 / 1536, y: 330.0 / 1024),
        .leftMiddle: CGPoint(x: 546.0 / 1536, y: 319.0 / 1024),
        .leftIndex: CGPoint(x: 611.0 / 1536, y: 340.0 / 1024),
        .leftThumb: CGPoint(x: 644.0 / 1536, y: 482.0 / 1024),
        .rightThumb: CGPoint(x: 865.0 / 1536, y: 482.0 / 1024),
        .rightIndex: CGPoint(x: 902.0 / 1536, y: 340.0 / 1024),
        .rightMiddle: CGPoint(x: 966.0 / 1536, y: 319.0 / 1024),
        .rightRing: CGPoint(x: 1043.0 / 1536, y: 330.0 / 1024),
        .rightPinky: CGPoint(x: 1116.0 / 1536, y: 378.0 / 1024)
    ]

    static func loadPoints(defaults: UserDefaults = .standard) -> [FingerIdentifier: CGPoint] {
        guard let data = defaults.data(forKey: storageKey) else {
            return defaultPoints
        }
        do {
            let decoded = try JSONDecoder().decode([String: NormalizedPoint].self, from: data)
            var points = defaultPoints
            for (key, value) in decoded {
                if let finger = FingerIdentifier(rawValue: key),
                   value.x.isFinite, value.y.isFinite,
                   (0...1).contains(value.x), (0...1).contains(value.y) {
                    points[finger] = value.cgPoint
                }
            }
            return points
        } catch {
            return defaultPoints
        }
    }

    static func savePoints(_ points: [FingerIdentifier: CGPoint], defaults: UserDefaults = .standard) {
        var payload: [String: NormalizedPoint] = [:]
        for (finger, point) in points {
            payload[finger.rawValue] = NormalizedPoint(x: Double(point.x), y: Double(point.y))
        }
        if let data = try? JSONEncoder().encode(payload) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

struct HandImageZoom {
    static let storageKey = "hands.imageZoom.v1"
    static let defaultZoom: Double = 0.88
    static let range: ClosedRange<Double> = 0.75...1.35
    static let step: Double = 0.02

    static func load() -> Double {
        guard let value = UserDefaults.standard.object(forKey: storageKey) as? Double else {
            return defaultZoom
        }
        return clamp(value)
    }

    static func save(_ value: Double) {
        UserDefaults.standard.set(clamp(value), forKey: storageKey)
    }

    static func clamp(_ value: Double) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
