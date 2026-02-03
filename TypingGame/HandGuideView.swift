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

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let baseDot = min(size.width, size.height) * 0.07
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
                        .aspectRatio(contentMode: .fill)
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

                ForEach(FingerIdentifier.allCases, id: \.self) { finger in
                    let point = points[finger] ?? HandCalibration.defaultPoints[finger] ?? .zero
                    let pointPosition = layout.position(for: point)
                    let valueText = String(format: "%.3f,%.3f", point.x, point.y)
                    let isActive = activeFingers.contains(finger)
                    let visible = isCalibrating || isActive

                    Circle()
                        .fill(Theme.accent)
                        .frame(width: dotSize, height: dotSize)
                        .position(x: pointPosition.x, y: pointPosition.y)
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
                                    let normalized = clampPoint(layout.normalizedPoint(from: value.location))
                                    points[finger] = normalized
                                }
                        )

                    if isCalibrating {
                        Text(finger.shortLabel)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.primaryText)
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

    private static let baseImage: NSImage? = {
        for name in Self.imageNames {
            if let image = NSImage(named: name) {
                return image
            }
            if let url = Bundle.main.url(forResource: name, withExtension: "png"),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }()

    private static let imageNames: [String] = [
        "ChatGPT Image Jan 23, 2026 at 11_17_06 PM",
        "ChatGPT Image Jan 22, 2026 at 10_08_07 PM"
    ]

    private struct HandImageLayout {
        let viewSize: CGSize
        let imageSize: CGSize
        let zoom: CGFloat
        let zoomX: CGFloat

        var imageRect: CGRect {
            let safeImageSize = CGSize(width: max(1, imageSize.width), height: max(1, imageSize.height))
            let scale = max(viewSize.width / safeImageSize.width, viewSize.height / safeImageSize.height)
            let scaledWidth = safeImageSize.width * scale * zoomX * zoom
            let scaledHeight = safeImageSize.height * scale * zoom
            let origin = CGPoint(
                x: (viewSize.width - scaledWidth) / 2.0,
                y: (viewSize.height - scaledHeight) / 2.0
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

    static let storageKey = "hands.points.v1"

    static let defaultPoints: [FingerIdentifier: CGPoint] = [
        .leftPinky: CGPoint(x: 0.23, y: 0.30),
        .leftRing: CGPoint(x: 0.29, y: 0.27),
        .leftMiddle: CGPoint(x: 0.35, y: 0.25),
        .leftIndex: CGPoint(x: 0.41, y: 0.27),
        .leftThumb: CGPoint(x: 0.45, y: 0.62),
        .rightThumb: CGPoint(x: 0.55, y: 0.62),
        .rightIndex: CGPoint(x: 0.59, y: 0.27),
        .rightMiddle: CGPoint(x: 0.65, y: 0.25),
        .rightRing: CGPoint(x: 0.70, y: 0.24),
        .rightPinky: CGPoint(x: 0.77, y: 0.30)
    ]

    static func loadPoints() -> [FingerIdentifier: CGPoint] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return defaultPoints
        }
        do {
            let decoded = try JSONDecoder().decode([String: NormalizedPoint].self, from: data)
            var points = defaultPoints
            for (key, value) in decoded {
                if let finger = FingerIdentifier(rawValue: key) {
                    points[finger] = value.cgPoint
                }
            }
            return points
        } catch {
            return defaultPoints
        }
    }

    static func savePoints(_ points: [FingerIdentifier: CGPoint]) {
        var payload: [String: NormalizedPoint] = [:]
        for (finger, point) in points {
            payload[finger.rawValue] = NormalizedPoint(x: Double(point.x), y: Double(point.y))
        }
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

struct HandImageZoom {
    static let storageKey = "hands.imageZoom.v1"
    static let defaultZoom: Double = 1.0
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
