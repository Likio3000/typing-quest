import AppKit
import SwiftUI

struct ContentView: View {
    private static let levels = LevelCatalog.levels

    @StateObject private var session: TypingSession
    @State private var selectedLevelID: String
    @State private var activeLevelID: String
    @State private var bestScores: [String: Double]
    @State private var targetFontSize: Double = 22
    @State private var now = Date()
    @State private var handPoints: [FingerIdentifier: CGPoint]
    @State private var handImageZoom: Double
    @State private var isCalibratingHands = false

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let targetFontRange: ClosedRange<Double> = 14...42
    private let leftPanelWidth: CGFloat = 320
    private let rightPanelWidth: CGFloat = 260
    private let scoreTargetWPM: Double = 60
    private let scoreSpeedBonusFactor: Double = 15
    private let scoreUncorrectedPenalty: Double = 3
    private let scoreCorrectedPenalty: Double = 0.5

    init() {
        let initialLevel = ContentView.levels.first ?? LevelCatalog.fallbackLevel
        _session = StateObject(wrappedValue: TypingSession(targetText: ContentView.generateLevelText(for: initialLevel)))
        _selectedLevelID = State(initialValue: initialLevel.id)
        _activeLevelID = State(initialValue: initialLevel.id)
        _bestScores = State(initialValue: LevelScoreStore.loadAll(levels: ContentView.levels))
        _handPoints = State(initialValue: HandCalibration.loadPoints())
        _handImageZoom = State(initialValue: HandImageZoom.load())
    }

    var body: some View {
        let stats = session.stats
        let metrics = session.metrics(now: now)

        VStack(spacing: 16) {
            topBar(metrics: metrics)

            HStack(alignment: .top, spacing: 16) {
                leftPanel
                    .frame(width: leftPanelWidth)
                centerPanel
                rightColumn(stats: stats, metrics: metrics)
                    .frame(width: rightPanelWidth)
            }

            keyboardPanel
        }
        .padding(20)
        .frame(minWidth: 1150, minHeight: 900)
        .background(backgroundGradient)
        .foregroundColor(Theme.primaryText)
        .overlay(keyCaptureView)
        .onReceive(timer) { now = $0 }
        .onChange(of: session.endTime) { newValue in
            guard let completionTime = newValue else { return }
            let metrics = session.metrics(now: completionTime)
            let stats = session.stats
            let score = calculateScore(metrics: metrics, stats: stats, targetLength: session.targetText.count)
            let levelID = activeLevelID
            let currentBest = bestScores[levelID] ?? 0
            if score > currentBest {
                bestScores[levelID] = score
                LevelScoreStore.save(score, for: levelID)
            }
        }
        .onChange(of: handPoints) { newValue in
            HandCalibration.savePoints(newValue)
        }
        .onChange(of: handImageZoom) { newValue in
            HandImageZoom.save(newValue)
        }
    }

    private var leftPanel: some View {
        Panel(title: "Levels") {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected: \(selectedLevel.name)")
                        .font(.system(size: 13, weight: .semibold))
                        .accessibilityIdentifier("selected-level-name")
                    Text(selectedLevel.description)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.mutedText)
                }

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(ContentView.levels) { level in
                            LevelRow(level: level, isSelected: level.id == selectedLevelID, bestScore: bestScores[level.id]) {
                                applyLevel(level)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 4)
                }
                .frame(maxWidth: .infinity, minHeight: 260, alignment: .leading)
                .contentShape(Rectangle())

                HStack {
                    Spacer()
                    Button("Regenerate level") {
                        applyLevel(selectedLevel)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("level-regenerate")
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var centerPanel: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 16
            let totalHeight = proxy.size.height
            let targetHeight = max(140, min(210, totalHeight * 0.26))
            let handsHeight = max(300, totalHeight - targetHeight - spacing)

            VStack(spacing: spacing) {
                targetPanel
                    .frame(height: targetHeight)
                handPanel
                    .frame(height: handsHeight)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var targetPanel: some View {
        Panel(title: "Target") {
            VStack(alignment: .leading, spacing: 8) {
                targetZoomControls
                let attributed = targetAttributedText()
                let scrollIndex = min(session.typedText.count, attributed.length)
                TargetTextScrollView(attributedText: attributed, scrollIndex: scrollIndex)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private func rightColumn(stats: TypingStats, metrics: TypingMetrics) -> some View {
        VStack(spacing: 16) {
            rightPanel
            problemKeysPanel
            summaryPanel(stats: stats, metrics: metrics)
        }
    }

    private var rightPanel: some View {
        Panel(title: "Next key") {
            if let nextCharacter = session.nextExpectedCharacter(),
               let info = KeyMapping.coachInfo(for: nextCharacter) {
                let displayKey = info.displayKey
                let displayFontSize = displayKey == "SPACE" ? nextKeyFontSize * 0.6 : nextKeyFontSize

                Text(displayKey)
                    .font(.system(size: displayFontSize, weight: .bold, design: .monospaced))
                    .foregroundColor(KeyCapView.nextKeyColor)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("Done")
                    .font(.system(size: nextKeyFontSize * 0.75, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var handPanel: some View {
        let activeFingers = activeFingerIdentifiers()
        return Panel(title: "Hands") {
            VStack(alignment: .leading, spacing: 8) {
                if isCalibratingHands {
                    Text("Drag dots to align fingers.")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.mutedText)
                }

                HandGuideView(
                    activeFingers: activeFingers,
                    points: $handPoints,
                    zoom: CGFloat(handImageZoom),
                    isCalibrating: isCalibratingHands
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, -40)

                if isCalibratingHands {
                    HStack {
                        HStack(spacing: 8) {
                            Text("Image Zoom")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Theme.mutedText)
                            Button("Zoom -") {
                                handImageZoom = HandImageZoom.clamp(handImageZoom - HandImageZoom.step)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("hand-zoom-minus")
                            Text("\(Int(handImageZoom * 100))%")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Theme.mutedText)
                                .frame(width: 44, alignment: .center)
                                .accessibilityIdentifier("hand-zoom-value")
                                .accessibilityLabel("\(Int(handImageZoom * 100))%")
                                .accessibilityValue("\(Int(handImageZoom * 100))%")
                            Button("Zoom +") {
                                handImageZoom = HandImageZoom.clamp(handImageZoom + HandImageZoom.step)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("hand-zoom-plus")
                        }
                        Spacer()
                        Button("Reset") {
                            handPoints = HandCalibration.defaultPoints
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("hand-reset-points")
                        Button("Reset Zoom") {
                            handImageZoom = HandImageZoom.defaultZoom
                        }
                        .buttonStyle(.bordered)
                    }
                }

                HStack {
                    Spacer()
                    Button(isCalibratingHands ? "Done" : "Calibrate") {
                        isCalibratingHands.toggle()
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("hand-calibrate")
                    Spacer()
                }
            }
        }
    }

    private func topBar(metrics: TypingMetrics) -> some View {
        ZStack {
            HStack(spacing: 16) {
                MetricView(label: "Time", value: formatTime(metrics.elapsed))
                MetricView(label: "Gross WPM", value: formatNumber(metrics.grossWPM))
                MetricView(label: "Net WPM", value: formatNumber(metrics.netWPM))
                MetricView(label: "Accuracy", value: formatPercent(metrics.accuracy))
                MetricView(label: "KPM", value: formatNumber(metrics.kpm))
            }

            HStack {
                Spacer()
                Button("Restart") {
                    session.resetSession()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("restart-level")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(topBarColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func summaryPanel(stats: TypingStats, metrics: TypingMetrics) -> some View {
        return Panel(title: "Summary") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    summaryPill(label: "Pending", value: "\(stats.pending)", valueID: "summary-pending-value")
                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    summaryPill(label: "Correct", value: "\(stats.correct)", valueID: "summary-correct-value")
                    summaryPill(label: "Wrong", value: "\(stats.wrong)", valueID: "summary-wrong-value")
                }

                HStack(spacing: 8) {
                    summaryPill(label: "Uncorrected", value: "\(stats.uncorrectedErrors)", valueID: "summary-uncorrected-value")
                    summaryPill(label: "Corrected", value: "\(session.correctedErrors)", valueID: "summary-corrected-value")
                }

                if session.endTime != nil {
                    let score = calculateScore(metrics: metrics, stats: stats, targetLength: session.targetText.count)
                    Text("Score \(formatScore(score))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.accent)
                }
            }
        }
    }

    private var problemKeysPanel: some View {
        Panel(title: "Problem keys") {
            ProblemKeyChartView(problems: session.problemKeys(limit: 5))
        }
    }

    private var keyboardPanel: some View {
        let descriptor = session.nextExpectedCharacter().flatMap { KeyMapping.keyDescriptor(for: $0) }
        let highlightedKey = descriptor?.baseKey
        let highlightedShiftKeys = highlightedShiftKeys(for: descriptor)
        let wrongKeyOpacities = session.wrongKeyOpacities(now: now, fadeDuration: 2)

        return Panel(title: "Keyboard") {
            KeyboardView(
                highlightedKey: highlightedKey,
                highlightedShiftKeys: highlightedShiftKeys,
                wrongKeyOpacities: wrongKeyOpacities
            )
        }
    }

    private func targetAttributedText() -> NSAttributedString {
        let typedCharacters = Array(session.typedText)
        let targetCharacters = Array(session.targetText)
        let caretIndex = typedCharacters.count
        let font = NSFont.monospacedSystemFont(ofSize: targetFontSize, weight: .regular)
        let result = NSMutableAttributedString()

        for index in 0..<targetCharacters.count {
            let character = String(targetCharacters[index])
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: targetTextColor
            ]

            if index < typedCharacters.count {
                if typedCharacters[index] == targetCharacters[index] {
                    attributes[.backgroundColor] = correctBackgroundColor
                } else {
                    attributes[.backgroundColor] = wrongBackgroundColor
                }
            }

            if index == caretIndex {
                attributes[.backgroundColor] = caretHighlightBackground
                attributes[.foregroundColor] = nextKeyTextColor
            }

            result.append(NSAttributedString(string: character, attributes: attributes))
        }

        if caretIndex >= targetCharacters.count {
            let caretAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: caretIndicatorNSColor
            ]
            result.append(NSAttributedString(string: "|", attributes: caretAttributes))
        }

        return result
    }

    private var selectedLevel: Level {
        ContentView.levels.first(where: { $0.id == selectedLevelID }) ?? LevelCatalog.fallbackLevel
    }

    private func applyLevel(_ level: Level) {
        selectedLevelID = level.id
        activeLevelID = level.id
        session.setTargetText(ContentView.generateLevelText(for: level))
    }

    private static func generateLevelText(for level: Level) -> String {
        if let fixedText = level.fixedText, !fixedText.isEmpty {
            return fixedText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard !level.pool.isEmpty else { return "" }
        var result = ""
        var remaining = level.length

        while remaining > 0 {
            let nextWordLength = min(Int.random(in: level.wordLengthRange), remaining)
            for _ in 0..<nextWordLength {
                if let next = level.pool.randomElement() {
                    result.append(next)
                    remaining -= 1
                }
            }
            if level.includeSpaces && remaining > 0 {
                result.append(" ")
                remaining -= 1
            }
        }

        return result.trimmingCharacters(in: .whitespaces)
    }

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

    private func summaryPill(label: String, value: String, valueID: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: true, vertical: false)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityIdentifier(valueID)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Theme.metricBackground)
        .clipShape(Capsule())
        .fixedSize(horizontal: true, vertical: false)
    }

    private func calculateScore(metrics: TypingMetrics, stats: TypingStats, targetLength: Int) -> Double {
        let accuracyScore = metrics.accuracy * 100
        let uncorrectedPenalty = Double(stats.uncorrectedErrors) * scoreUncorrectedPenalty
        let correctedPenalty = Double(session.correctedErrors) * scoreCorrectedPenalty
        let expectedSeconds = expectedTimeSeconds(for: targetLength)
        let speedBonus: Double
        if metrics.elapsed > 0, expectedSeconds > 0 {
            speedBonus = scoreSpeedBonusFactor * log2(expectedSeconds / metrics.elapsed)
        } else {
            speedBonus = 0
        }
        let rawScore = accuracyScore - uncorrectedPenalty - correctedPenalty + speedBonus
        return max(0, rawScore)
    }

    private func expectedTimeSeconds(for targetLength: Int) -> Double {
        guard targetLength > 0 else { return 0 }
        let words = Double(targetLength) / 5.0
        let minutes = words / scoreTargetWPM
        return minutes * 60.0
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

    private func activeFingerIdentifiers() -> Set<FingerIdentifier> {
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

    private var topBarColor: Color {
        Theme.topBar
    }

    private var keyCaptureView: some View {
        KeyCaptureView { input in
            session.handleInput(input)
        }
        .frame(width: 1, height: 1)
        .opacity(0.01)
        .allowsHitTesting(false)
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

    private var targetZoomControls: some View {
        HStack(spacing: 10) {
            Text("Text zoom")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.mutedText)
            Button {
                targetFontSize = max(targetFontRange.lowerBound, targetFontSize - 2)
            } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("-", modifiers: [.command])

            Text("\(Int(targetFontSize)) pt")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .frame(minWidth: 64, alignment: .leading)

            Button {
                targetFontSize = min(targetFontRange.upperBound, targetFontSize + 2)
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("=", modifiers: [.command])

            Button("Reset") {
                targetFontSize = 22
            }
            .buttonStyle(.borderless)

            Spacer()
        }
        .padding(.bottom, 4)
    }
}

enum Theme {
    static let backgroundTop = Color(.sRGB, red: 0.09, green: 0.11, blue: 0.16, opacity: 1)
    static let backgroundBottom = Color(.sRGB, red: 0.06, green: 0.08, blue: 0.12, opacity: 1)
    static let topBar = Color(.sRGB, red: 0.12, green: 0.15, blue: 0.22, opacity: 0.98)
    static let panel = Color(.sRGB, red: 0.14, green: 0.17, blue: 0.25, opacity: 1)
    static let panelBorder = Color(.sRGB, red: 0.24, green: 0.28, blue: 0.38, opacity: 1)
    static let panelShadow = Color(.sRGB, red: 0.0, green: 0.0, blue: 0.0, opacity: 0.35)
    static let surface = Color(.sRGB, red: 0.13, green: 0.16, blue: 0.24, opacity: 1)
    static let border = Color(.sRGB, red: 0.24, green: 0.28, blue: 0.38, opacity: 1)
    static let metricBackground = Theme.accent.opacity(0.2)
    static let keyBase = Color(.sRGB, red: 0.15, green: 0.19, blue: 0.28, opacity: 1)
    static let keyBorder = Color(.sRGB, red: 0.27, green: 0.32, blue: 0.44, opacity: 1)
    static let accent = Color(.sRGB, red: 0.98, green: 0.62, blue: 0.18, opacity: 1)
    static let primaryText = Color(.sRGB, red: 0.94, green: 0.95, blue: 0.98, opacity: 1)
    static let mutedText = Color(.sRGB, red: 0.82, green: 0.85, blue: 0.92, opacity: 1)
    static let placeholderText = Color(.sRGB, red: 0.68, green: 0.73, blue: 0.84, opacity: 1)
}

struct Level: Identifiable {
    let id: String
    let name: String
    let description: String
    let pool: [Character]
    let length: Int
    let wordLengthRange: ClosedRange<Int>
    let includeSpaces: Bool
    let fixedText: String?

    init(
        id: String,
        name: String,
        description: String,
        pool: [Character],
        length: Int,
        wordLengthRange: ClosedRange<Int>,
        includeSpaces: Bool,
        fixedText: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.pool = pool
        self.length = length
        self.wordLengthRange = wordLengthRange
        self.includeSpaces = includeSpaces
        self.fixedText = fixedText
    }

    var displayLength: Int {
        fixedText?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? length
    }
}

enum LevelCatalog {
    static let lettersLower = Array("abcdefghijklmnopqrstuvwxyz")
    static let lettersUpper = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let numbers = Array("0123456789")
    static let homeRow = Array("asdfjkl;")
    static let leftHand = Array("qwertasdfgzxcvb")
    static let rightHand = Array("yuiophjkl;nm,./")
    static let topRow = Array("qwertyuiop")
    static let bottomRow = Array("zxcvbnm")
    static let vowels = Array("aeiou")
    static let leftPinkyKeys = Array("`~1!qQaAzZ")
    static let rightPinkyKeys = Array("pP;:/?0)-_=+[]{}\\|'\"")
    static let punctuation = Array(".,;'/")
    static let brackets = Array("[]{}()")
    static let operators = Array("-=+*/")
    static let shiftSymbols = Array("!@#$%^&*()")
    static let storyNightMarket = """
At 6:05 PM, the night market lit up, and Mina wrote "List #3" on her wrist. She bought 2 pies for $7.50, paid with a card, and got a receipt that read: TAX=8%. A small cat followed her, jumping over crates marked [A-12] and (B-4). "Stay close," she said; the bell chimed, and the vendor nodded.
"""
    static let storySignalLog = """
The radio log started with: "Day 19, 04:17 @ Ridge Station." We tested a new antenna, toggled switch A/B, and the meter jumped from 0.9 to 1.3. The old map had notes like "north-3" and "west+2", but the signal only stabilized when we set gain=7 and the lamp blinked 3 times.
"""
    static let storyClockworkLetter = """
In the attic, a folded letter said: "Meet me at Gate 5 - bring the brass key." Jae checked the clock (11:02) and scribbled 2+2=4 on the envelope. The note smelled of oil & smoke, and a tiny gear with 8 teeth fell onto the table.
"""
    static let storyWorkshopReport = """
Report 07: The prototype "Vega" failed test #42. We saw a 3.14 cm crack, a 12% voltage drop, and a fuse marked 10A/250V. Still, the crew cheered when the reboot finished in 9.8s; the console flashed OK>READY and the room went quiet.
"""
    static let dataEntryInvoice = """
Invoice #48371 | Date: 2026-01-27 | Vendor: Northwind Parts
Item: Gear Set (GS-442) Qty: 3 Unit: $79.95 Line: $239.85
Item: Belt Kit (BK-210) Qty: 1 Unit: $34.50 Line: $34.50
Subtotal: $274.35  Tax 8.25%: $22.64  Total: $296.99  Paid: CC-4582
"""
    static let dataEntryContacts = """
Contact Log: 3 entries
1) Rivera, Ana | Dept: Ops | Ext: 224 | Email: ana.rivera@acme.co
2) Chen, Li | Dept: IT | Ext: 318 | Email: li.chen@acme.co
3) Patel, Omar | Dept: Sales | Ext: 105 | Email: omar.patel@acme.co
"""
    static let dataEntryShipment = """
Shipment Record: ID SHP-90218
Origin: 4501 W 3rd St, Austin, TX 78703
Dest: 18 Harbor Way, Newark, NJ 07102
Weight: 42.6 lb  Boxes: 4  Carrier: FDX-2Day  ETA: 01/30/26
"""
    static let dataEntryInventory = """
Inventory Update (Cycle B): Aisle 7
SKU: HN-1442 | Desc: Hand Nut 10mm | On Hand: 860 | Reorder: 500 | Bin: B-07-14
SKU: BX-9901 | Desc: Box, 12x10x8 | On Hand: 120 | Reorder: 60 | Bin: C-02-03
SKU: CL-5530 | Desc: Clamp 3/4in | On Hand: 48 | Reorder: 75 | Bin: A-01-09
"""
    static let dataEntryTimesheet = """
Timesheet: Week 04 (Employee ID: 77102)
Mon 01/20: 8.0  Tue 01/21: 7.5  Wed 01/22: 8.0
Thu 01/23: 8.5  Fri 01/24: 6.5  OT: 1.5  Total: 38.0
Notes: "Inventory count + customer follow-ups."
"""
    static let dataEntrySupportTicket = """
Ticket #A-77530 | Priority: P2 | Status: OPEN
User: Kim, Jordan | Asset: LTP-4471 | OS: macOS 14.2
Issue: "Printer queue shows error 79" | Started: 09:14 | Attempts: 2
Resolution: Clear spooler, reboot, re-add printer PRN-04.
"""

    static let levels: [Level] = [
        Level(
            id: "letters-home-row",
            name: "Letters: Home row",
            description: "asdf jkl; focused warmup.",
            pool: homeRow,
            length: 160,
            wordLengthRange: 4...6,
            includeSpaces: true
        ),
        Level(
            id: "left-pinky-keys",
            name: "Letters: Left pinky",
            description: "q a z 1 with ` and ~.",
            pool: leftPinkyKeys,
            length: 180,
            wordLengthRange: 3...6,
            includeSpaces: true
        ),
        Level(
            id: "right-pinky-keys",
            name: "Letters: Right pinky",
            description: "p ; / 0 - = [ ] \\ ' and shifts.",
            pool: rightPinkyKeys,
            length: 200,
            wordLengthRange: 2...6,
            includeSpaces: true
        ),
        Level(
            id: "letters-left-hand",
            name: "Letters: Left hand",
            description: "qwert asdfg zxcvb.",
            pool: leftHand,
            length: 180,
            wordLengthRange: 4...7,
            includeSpaces: true
        ),
        Level(
            id: "letters-right-hand",
            name: "Letters: Right hand",
            description: "yuiop hjkl; nm,./",
            pool: rightHand,
            length: 180,
            wordLengthRange: 4...7,
            includeSpaces: true
        ),
        Level(
            id: "letters-top-row",
            name: "Letters: Top row",
            description: "qwertyuiop only.",
            pool: topRow,
            length: 180,
            wordLengthRange: 4...6,
            includeSpaces: true
        ),
        Level(
            id: "letters-bottom-row",
            name: "Letters: Bottom row",
            description: "zxcvbnm only.",
            pool: bottomRow,
            length: 160,
            wordLengthRange: 4...6,
            includeSpaces: true
        ),
        Level(
            id: "letters-vowels",
            name: "Letters: Vowels",
            description: "aeiou heavy repetition.",
            pool: vowels,
            length: 140,
            wordLengthRange: 3...5,
            includeSpaces: true
        ),
        Level(
            id: "letters-lowercase-mix",
            name: "Letters: Lowercase mix",
            description: "Full lowercase alphabet.",
            pool: lettersLower,
            length: 220,
            wordLengthRange: 4...8,
            includeSpaces: true
        ),
        Level(
            id: "letters-mixed-case",
            name: "Letters: Mixed case",
            description: "Uppercase and lowercase.",
            pool: lettersLower + lettersUpper,
            length: 220,
            wordLengthRange: 4...8,
            includeSpaces: true
        ),
        Level(
            id: "numbers-1-5",
            name: "Numbers: 1-5",
            description: "Low numbers focus.",
            pool: Array("12345"),
            length: 140,
            wordLengthRange: 3...5,
            includeSpaces: true
        ),
        Level(
            id: "numbers-6-0",
            name: "Numbers: 6-0",
            description: "High numbers focus.",
            pool: Array("67890"),
            length: 140,
            wordLengthRange: 3...5,
            includeSpaces: true
        ),
        Level(
            id: "numbers-all",
            name: "Numbers: All digits",
            description: "0-9 mixed.",
            pool: numbers,
            length: 180,
            wordLengthRange: 3...6,
            includeSpaces: true
        ),
        Level(
            id: "symbols-punctuation",
            name: "Symbols: Punctuation",
            description: "., ; ' /",
            pool: punctuation,
            length: 160,
            wordLengthRange: 2...4,
            includeSpaces: true
        ),
        Level(
            id: "symbols-brackets",
            name: "Symbols: Brackets",
            description: "[ ] { } ( )",
            pool: brackets,
            length: 160,
            wordLengthRange: 2...4,
            includeSpaces: true
        ),
        Level(
            id: "symbols-operators",
            name: "Symbols: Operators",
            description: "- = + * /",
            pool: operators,
            length: 160,
            wordLengthRange: 2...4,
            includeSpaces: true
        ),
        Level(
            id: "symbols-shift",
            name: "Symbols: Shifted",
            description: "! @ # $ % ^ & * ( )",
            pool: shiftSymbols,
            length: 160,
            wordLengthRange: 2...4,
            includeSpaces: true
        ),
        Level(
            id: "full-mix",
            name: "Full mix",
            description: "Letters, numbers, punctuation, operators.",
            pool: lettersLower + lettersUpper + numbers + punctuation + brackets + operators + shiftSymbols,
            length: 240,
            wordLengthRange: 4...9,
            includeSpaces: true
        ),
        Level(
            id: "story-night-market",
            name: "Story: Night Market",
            description: "Full text with numbers and symbols.",
            pool: lettersLower,
            length: storyNightMarket.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: storyNightMarket
        ),
        Level(
            id: "story-signal-log",
            name: "Story: Signal Log",
            description: "Full text with mixed case and operators.",
            pool: lettersLower,
            length: storySignalLog.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: storySignalLog
        ),
        Level(
            id: "story-clockwork-letter",
            name: "Story: Clockwork Letter",
            description: "Full text with punctuation and math.",
            pool: lettersLower,
            length: storyClockworkLetter.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: storyClockworkLetter
        ),
        Level(
            id: "story-workshop-report",
            name: "Story: Workshop Report",
            description: "Full text with symbols, units, and caps.",
            pool: lettersLower,
            length: storyWorkshopReport.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: storyWorkshopReport
        ),
        Level(
            id: "data-entry-invoice",
            name: "Data Entry: Invoice",
            description: "Invoice lines with prices, IDs, and totals.",
            pool: lettersLower,
            length: dataEntryInvoice.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: dataEntryInvoice
        ),
        Level(
            id: "data-entry-contacts",
            name: "Data Entry: Contacts",
            description: "Names, departments, extensions, and emails.",
            pool: lettersLower,
            length: dataEntryContacts.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: dataEntryContacts
        ),
        Level(
            id: "data-entry-shipment",
            name: "Data Entry: Shipment",
            description: "Addresses, IDs, and ETA details.",
            pool: lettersLower,
            length: dataEntryShipment.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: dataEntryShipment
        ),
        Level(
            id: "data-entry-inventory",
            name: "Data Entry: Inventory",
            description: "SKUs, counts, bins, and sizes.",
            pool: lettersLower,
            length: dataEntryInventory.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: dataEntryInventory
        ),
        Level(
            id: "data-entry-timesheet",
            name: "Data Entry: Timesheet",
            description: "Dates, hours, totals, and notes.",
            pool: lettersLower,
            length: dataEntryTimesheet.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: dataEntryTimesheet
        ),
        Level(
            id: "data-entry-support-ticket",
            name: "Data Entry: Support Ticket",
            description: "Ticket fields with assets and steps.",
            pool: lettersLower,
            length: dataEntrySupportTicket.count,
            wordLengthRange: 1...1,
            includeSpaces: true,
            fixedText: dataEntrySupportTicket
        )
    ]

    static let fallbackLevel = levels.first ?? Level(
        id: "fallback",
        name: "Warmup",
        description: "Basic letters.",
        pool: lettersLower,
        length: 160,
        wordLengthRange: 4...6,
        includeSpaces: true
    )
}

struct LevelScoreStore {
    static let storageKey = "levels.bestScores.v1"

    static func loadAll(levels: [Level]) -> [String: Double] {
        let payload = loadRaw()
        var result: [String: Double] = [:]
        for level in levels {
            if let score = payload[level.id] {
                result[level.id] = score
            }
        }
        return result
    }

    static func save(_ score: Double, for levelID: String) {
        var payload = loadRaw()
        payload[levelID] = score
        if let data = try? JSONEncoder().encode(payload) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private static func loadRaw() -> [String: Double] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return [:]
        }
        return decoded
    }
}

struct LevelRow: View {
    let level: Level
    let isSelected: Bool
    let bestScore: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.name)
                        .font(.system(size: 13, weight: .semibold))
                    Text(level.description)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.mutedText)
                    Text("Length \(level.displayLength)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.mutedText)
                }
                Spacer(minLength: 0)
                scoreBadge
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? selectedBackground : Color.clear)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? selectedBorder : idleBorder))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .buttonStyle(.plain)
        .accessibilityIdentifier("level-row-\(level.id)")
    }

    private var selectedBackground: Color {
        Theme.metricBackground
    }

    private var selectedBorder: Color {
        Theme.accent
    }

    private var idleBorder: Color {
        Color(.sRGB, red: 0.84, green: 0.86, blue: 0.9, opacity: 1)
    }

    private var scoreBadge: some View {
        Text(bestScoreText)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundColor(bestScore == nil ? Theme.placeholderText : Theme.primaryText)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Theme.metricBackground.opacity(bestScore == nil ? 0.25 : 0.55))
            .clipShape(Capsule())
            .accessibilityIdentifier("level-best-score-\(level.id)")
    }

    private var bestScoreText: String {
        guard let bestScore else { return "—" }
        return String(format: "%.0f", bestScore)
    }
}

struct Panel<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panelColor)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(panelBorderColor))
        .shadow(color: panelShadowColor, radius: 6, x: 0, y: 3)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var panelColor: Color {
        Theme.panel
    }

    private var panelBorderColor: Color {
        Theme.panelBorder
    }

    private var panelShadowColor: Color {
        Theme.panelShadow
    }
}

struct MetricView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.mutedText)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Theme.metricBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

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
                        .accessibilityIdentifier("hand-point-\(finger.rawValue)")
                        .accessibilityLabel(finger.shortLabel)
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

struct KeyboardView: View {
    let highlightedKey: String?
    let highlightedShiftKeys: Set<String>
    let wrongKeyOpacities: [String: Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                KeyboardLegendItem(color: KeyCapView.nextKeyColor, label: "Next key")
                KeyboardLegendItem(color: KeyCapView.shiftKeyColor, label: "Shift")
                KeyboardLegendItem(color: KeyCapView.wrongKeyColor, label: "Wrong key")
                Spacer()
            }
            .font(.system(size: 11, weight: .semibold))

            KeyboardRowView(keys: Self.row1, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row2, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row3, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row4, highlight: highlight(for:))
            KeyboardRowView(keys: Self.row5, highlight: highlight(for:))
        }
    }

    private func highlight(for keyID: String) -> KeyHighlight {
        KeyHighlight(
            isNext: keyID == highlightedKey,
            isShift: highlightedShiftKeys.contains(keyID),
            wrongOpacity: wrongKeyOpacities[keyID] ?? 0
        )
    }

    private static let row1: [KeyCap] = [
        KeyCap(keyID: "`", label: "`", width: 1),
        KeyCap(keyID: "1", label: "1", width: 1),
        KeyCap(keyID: "2", label: "2", width: 1),
        KeyCap(keyID: "3", label: "3", width: 1),
        KeyCap(keyID: "4", label: "4", width: 1),
        KeyCap(keyID: "5", label: "5", width: 1),
        KeyCap(keyID: "6", label: "6", width: 1),
        KeyCap(keyID: "7", label: "7", width: 1),
        KeyCap(keyID: "8", label: "8", width: 1),
        KeyCap(keyID: "9", label: "9", width: 1),
        KeyCap(keyID: "0", label: "0", width: 1),
        KeyCap(keyID: "-", label: "-", width: 1),
        KeyCap(keyID: "=", label: "=", width: 1),
        KeyCap(keyID: "delete", label: "del", width: 1.6)
    ]

    private static let row2: [KeyCap] = [
        KeyCap(keyID: "tab", label: "tab", width: 1.5),
        KeyCap(keyID: "q", label: "q", width: 1),
        KeyCap(keyID: "w", label: "w", width: 1),
        KeyCap(keyID: "e", label: "e", width: 1),
        KeyCap(keyID: "r", label: "r", width: 1),
        KeyCap(keyID: "t", label: "t", width: 1),
        KeyCap(keyID: "y", label: "y", width: 1),
        KeyCap(keyID: "u", label: "u", width: 1),
        KeyCap(keyID: "i", label: "i", width: 1),
        KeyCap(keyID: "o", label: "o", width: 1),
        KeyCap(keyID: "p", label: "p", width: 1),
        KeyCap(keyID: "[", label: "[", width: 1),
        KeyCap(keyID: "]", label: "]", width: 1),
        KeyCap(keyID: "\\", label: "\\", width: 1.5)
    ]

    private static let row3: [KeyCap] = [
        KeyCap(keyID: "caps", label: "caps", width: 1.8),
        KeyCap(keyID: "a", label: "a", width: 1),
        KeyCap(keyID: "s", label: "s", width: 1),
        KeyCap(keyID: "d", label: "d", width: 1),
        KeyCap(keyID: "f", label: "f", width: 1),
        KeyCap(keyID: "g", label: "g", width: 1),
        KeyCap(keyID: "h", label: "h", width: 1),
        KeyCap(keyID: "j", label: "j", width: 1),
        KeyCap(keyID: "k", label: "k", width: 1),
        KeyCap(keyID: "l", label: "l", width: 1),
        KeyCap(keyID: ";", label: ";", width: 1),
        KeyCap(keyID: "'", label: "'", width: 1),
        KeyCap(keyID: "return", label: "return", width: 2.2)
    ]

    private static let row4: [KeyCap] = [
        KeyCap(keyID: "shift-left", label: "shift", width: 2.4),
        KeyCap(keyID: "z", label: "z", width: 1),
        KeyCap(keyID: "x", label: "x", width: 1),
        KeyCap(keyID: "c", label: "c", width: 1),
        KeyCap(keyID: "v", label: "v", width: 1),
        KeyCap(keyID: "b", label: "b", width: 1),
        KeyCap(keyID: "n", label: "n", width: 1),
        KeyCap(keyID: "m", label: "m", width: 1),
        KeyCap(keyID: ",", label: ",", width: 1),
        KeyCap(keyID: ".", label: ".", width: 1),
        KeyCap(keyID: "/", label: "/", width: 1),
        KeyCap(keyID: "shift-right", label: "shift", width: 2.8)
    ]

    private static let row5: [KeyCap] = [
        KeyCap(keyID: "space", label: "space", width: 8)
    ]
}

struct KeyboardRowView: View {
    let keys: [KeyCap]
    let highlight: (String) -> KeyHighlight

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 6
            let totalUnits = keys.reduce(0) { $0 + $1.width }
            let unitWidth = (geometry.size.width - spacing * CGFloat(keys.count - 1)) / totalUnits

            HStack(spacing: spacing) {
                ForEach(keys, id: \.keyID) { key in
                    KeyCapView(
                        keyID: key.keyID,
                        label: key.label,
                        width: unitWidth * key.width,
                        highlight: highlight(key.keyID)
                    )
                }
            }
        }
        .frame(height: 34)
    }
}

struct KeyCapView: View {
    let keyID: String
    let label: String
    let width: CGFloat
    let highlight: KeyHighlight

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Self.baseColor)

            if let overlay = fullOverlayColor {
                RoundedRectangle(cornerRadius: 6)
                    .fill(overlay)
            }

            Text(label.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(textColor)
                .padding(spaceNextHighlight ? EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 12) : .init())
                .background(
                    Group {
                        if spaceNextHighlight {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Self.nextKeyColor)
                        }
                    }
                )
        }
        .frame(width: width, height: 32)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderColor))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .animation(.linear(duration: 0.05), value: highlight.wrongOpacity)
    }

    private var fullOverlayColor: Color? {
        if spaceNextHighlight {
            return nil
        }
        if highlight.isNext {
            return Self.nextKeyColor
        }
        if highlight.wrongOpacity > 0 {
            return Self.wrongKeyColor.opacity(highlight.wrongOpacity)
        }
        if highlight.isShift {
            return Self.shiftKeyColor
        }
        return nil
    }

    private var textColor: Color {
        if highlight.isNext || highlight.isShift || highlight.wrongOpacity > 0 {
            return Color.white
        }
        return Theme.primaryText
    }

    private var spaceNextHighlight: Bool {
        keyID == "space" && highlight.isNext
    }

    private var borderColor: Color {
        Theme.keyBorder
    }

    static let baseColor = Theme.keyBase
    static let nextKeyColor = Color(.sRGB, red: 0.88, green: 0.5, blue: 0.2, opacity: 1)
    static let shiftKeyColor = Color(.sRGB, red: 0.31, green: 0.44, blue: 0.62, opacity: 1)
    static let wrongKeyColor = Color(.sRGB, red: 0.86, green: 0.28, blue: 0.28, opacity: 1)

}

struct KeyboardLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
        }
    }
}

struct KeyHighlight {
    let isNext: Bool
    let isShift: Bool
    let wrongOpacity: Double
}

struct KeyCap: Hashable {
    let keyID: String
    let label: String
    let width: CGFloat
}
