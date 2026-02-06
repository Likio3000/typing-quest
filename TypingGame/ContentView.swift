import AppKit
import SwiftUI
import TypingGameCore

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var targetRenderer = TargetTextRenderer()
    @State private var targetFontSize: Double = 22
    @State private var now = Date()

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let targetFontRange: ClosedRange<Double> = 14...42
    private let leftPanelWidth: CGFloat = 320
    private let rightPanelWidth: CGFloat = 260

    var body: some View {
        let session = viewModel.session
        let stats = session.stats
        let metrics = session.metrics(now: now)
        let scoreText = session.endTime == nil ? nil : formatScore(viewModel.score(metrics: metrics, stats: stats))

        let mainContent = VStack(spacing: 16) {
            TopBarView(
                time: formatTime(metrics.elapsed),
                netWPM: formatNumber(metrics.netWPM),
                accuracy: formatPercent(metrics.accuracy)
            )

            HStack(alignment: .top, spacing: 16) {
                LevelsPanelView(
                    levels: viewModel.filteredLevels,
                    selectedLevel: viewModel.selectedLevel,
                    selectedLevelID: viewModel.selectedLevelID,
                    bestScores: viewModel.bestScores,
                    maxUnlockedDifficulty: viewModel.maxUnlockedDifficulty,
                    categories: viewModel.categories,
                    selectedCategory: $viewModel.levelFilterCategory,
                    onSelect: { viewModel.applyLevel($0) },
                    onRegenerate: { viewModel.applyLevel(viewModel.selectedLevel) }
                )
                .frame(width: leftPanelWidth)

                centerPanel(session: session)

                rightColumn(stats: stats, scoreText: scoreText)
                    .frame(width: rightPanelWidth)
            }

            keyboardPanel
        }

        ZStack(alignment: .topLeading) {
            mainContent
        }
        .padding(20)
        .frame(minWidth: 1150, minHeight: 900)
        .background(backgroundGradient)
        .foregroundColor(Theme.primaryText)
        .overlay(keyCaptureView)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
        .onReceive(timer) { now = $0 }
    }

    private func centerPanel(session: TypingSession) -> some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 16
            let totalHeight = proxy.size.height
            let targetHeight = max(140, min(210, totalHeight * 0.26))
            let handsHeight = max(300, totalHeight - targetHeight - spacing)

            VStack(spacing: spacing) {
                TargetPanelView(
                    session: session,
                    renderer: targetRenderer,
                    targetFontSize: $targetFontSize,
                    fontRange: targetFontRange,
                    colors: targetTextColors
                )
                .frame(height: targetHeight)

                HandsPanelView(
                    activeFingers: activeFingerIdentifiers(),
                    points: $viewModel.handPoints,
                    zoom: $viewModel.handImageZoom,
                    isCalibrating: $viewModel.isCalibratingHands
                )
                .frame(height: handsHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func rightColumn(stats: TypingStats, scoreText: String?) -> some View {
        VStack(spacing: 16) {
            NextKeyPanelView(
                nextCharacter: viewModel.session.nextExpectedCharacter(),
                nextKeyFontSize: nextKeyFontSize
            )
            ProblemKeysPanelView(problems: viewModel.session.problemKeys(limit: 5))
            SummaryPanelView(
                stats: stats,
                correctedErrors: viewModel.session.correctedErrors,
                scoreText: scoreText,
                onRestart: { viewModel.session.resetSession() }
            )
        }
    }

    private var keyboardPanel: some View {
        let session = viewModel.session
        let descriptor = session.nextExpectedCharacter().flatMap { KeyMapping.keyDescriptor(for: $0) }
        let highlightedKey = descriptor?.baseKey
        let highlightedShiftKeys = highlightedShiftKeys(for: descriptor)
        let wrongKeyOpacities = session.wrongKeyOpacities(now: now, fadeDuration: 2)

        return KeyboardPanelView(
            highlightedKey: highlightedKey,
            highlightedShiftKeys: highlightedShiftKeys,
            wrongKeyOpacities: wrongKeyOpacities
        )
    }

    private func activeFingerIdentifiers() -> Set<FingerIdentifier> {
        let session = viewModel.session
        guard let nextCharacter = session.nextExpectedCharacter(),
              let info = KeyMapping.coachInfo(for: nextCharacter) else {
            return []
        }
        return Set(FingerIdentifier.from(label: info.finger))
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Theme.backgroundTop, Theme.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var keyCaptureView: some View {
        KeyCaptureView { input in
            viewModel.session.handleInput(input)
        }
        .frame(width: 1, height: 1)
        .opacity(0.01)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var targetTextColors: TargetTextColors {
        TargetTextColors(
            text: targetTextColor,
            correctBackground: correctBackgroundColor,
            wrongBackground: wrongBackgroundColor,
            caretBackground: caretHighlightBackground,
            caretText: nextKeyTextColor,
            caretIndicator: caretIndicatorNSColor
        )
    }

    private var targetTextColor: NSColor {
        NSColor(srgbRed: 0.94, green: 0.95, blue: 0.98, alpha: 1)
    }

    private var correctBackgroundColor: NSColor {
        NSColor(srgbRed: 0.28, green: 0.7, blue: 0.36, alpha: 0.4)
    }

    private var wrongBackgroundColor: NSColor {
        NSColor(srgbRed: 0.82, green: 0.25, blue: 0.25, alpha: 0.45)
    }

    private var caretHighlightBackground: NSColor {
        NSColor(srgbRed: 0.16, green: 0.54, blue: 0.68, alpha: 0.35)
    }

    private var caretIndicatorNSColor: NSColor {
        NSColor(srgbRed: 0.18, green: 0.62, blue: 0.64, alpha: 1)
    }

    private var nextKeyTextColor: NSColor {
        NSColor(srgbRed: 0.32, green: 0.6, blue: 0.95, alpha: 1)
    }

    private var nextKeyFontSize: CGFloat { 76 }

    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatNumber(_ value: Double) -> String {
        String(format: "%.1f", value)
    }

    private func formatPercent(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    private func formatScore(_ value: Double) -> String {
        String(format: "%.0f", value)
    }

    private func highlightedShiftKeys(for descriptor: KeyDescriptor?) -> Set<String> {
        guard let descriptor, descriptor.needsShift else { return [] }
        switch descriptor.shiftSide {
        case .left:
            return ["shift-left"]
        case .right:
            return ["shift-right"]
        case .either, .unknown:
            return ["shift-left", "shift-right"]
        }
    }
}

enum UITesting {
    static var enabled: Bool {
        let info = ProcessInfo.processInfo
        if info.environment["UI_TESTING"] == "1" {
            return true
        }
        if info.arguments.contains("-ui-testing") {
            return true
        }
        if info.environment.keys.contains(where: { $0.hasPrefix("XCTest") }) {
            return true
        }
        return info.environment["XCInjectBundle"] != nil
    }
}

extension View {
    @ViewBuilder
    func uiTestLabel(_ id: String, value: String? = nil) -> some View {
        let base = self.accessibilityIdentifier(id)
        if UITesting.enabled {
            if let value {
                base.accessibilityLabel(id).accessibilityValue(value)
            } else {
                base.accessibilityLabel(id)
            }
        } else {
            base
        }
    }
}
