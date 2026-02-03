import Combine
import Foundation
import TypingGameCore

final class ContentViewModel: ObservableObject {
    let levels: [Level]
    let session: TypingSession

    @Published var selectedLevelID: String {
        didSet { persistSelectedLevel() }
    }
    @Published var activeLevelID: String {
        didSet { persistActiveLevel() }
    }
    @Published var bestScores: [String: Double]
    @Published var handPoints: [FingerIdentifier: CGPoint] {
        didSet { HandCalibration.savePoints(handPoints) }
    }
    @Published var handImageZoom: Double {
        didSet { HandImageZoom.save(handImageZoom) }
    }
    @Published var isCalibratingHands = false

    private let scoreCalculator = ScoreCalculator()
    private var cancellables = Set<AnyCancellable>()

    init(levels: [Level] = LevelCatalog.levels) {
        self.levels = levels

        let defaultLevel = levels.first ?? LevelCatalog.fallbackLevel
        let defaults = UserDefaults.standard
        if UITesting.enabled {
            defaults.removeObject(forKey: StorageKey.selectedLevelID)
            defaults.removeObject(forKey: StorageKey.activeLevelID)
            defaults.removeObject(forKey: HandCalibration.storageKey)
            defaults.removeObject(forKey: HandImageZoom.storageKey)
        }
        let savedSelectedID = defaults.string(forKey: StorageKey.selectedLevelID)
        let savedActiveID = defaults.string(forKey: StorageKey.activeLevelID)
        let selectedLevelID = Self.resolveLevelID(savedSelectedID, levels: levels) ?? defaultLevel.id
        let activeLevelID = Self.resolveLevelID(savedActiveID, levels: levels) ?? selectedLevelID
        let activeLevel = levels.first(where: { $0.id == activeLevelID }) ?? defaultLevel

        self.session = TypingSession(targetText: LevelGenerator.generateText(for: activeLevel))
        self.selectedLevelID = selectedLevelID
        self.activeLevelID = activeLevelID
        self.bestScores = LevelScoreStore.loadAll(levels: levels)
        self.handPoints = HandCalibration.loadPoints()
        self.handImageZoom = HandImageZoom.load()

        session.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        session.$endTime
            .compactMap { $0 }
            .sink { [weak self] completionTime in
                self?.handleSessionCompletion(at: completionTime)
            }
            .store(in: &cancellables)

    }

    var selectedLevel: Level {
        levels.first(where: { $0.id == selectedLevelID }) ?? LevelCatalog.fallbackLevel
    }

    func applyLevel(_ level: Level) {
        selectedLevelID = level.id
        activeLevelID = level.id
        session.setTargetText(LevelGenerator.generateText(for: level))
    }

    func score(metrics: TypingMetrics, stats: TypingStats) -> Double {
        scoreCalculator.score(
            metrics: metrics,
            stats: stats,
            correctedErrors: session.correctedErrors,
            targetLength: session.targetText.count
        )
    }

    private func handleSessionCompletion(at completionTime: Date) {
        let metrics = session.metrics(now: completionTime)
        let stats = session.stats
        let score = score(metrics: metrics, stats: stats)
        let currentBest = bestScores[activeLevelID] ?? 0
        if score > currentBest {
            bestScores[activeLevelID] = score
            LevelScoreStore.save(score, for: activeLevelID)
        }
    }

    private static func resolveLevelID(_ candidate: String?, levels: [Level]) -> String? {
        guard let candidate else { return nil }
        return levels.first(where: { $0.id == candidate })?.id
    }

    private func persistSelectedLevel() {
        UserDefaults.standard.set(selectedLevelID, forKey: StorageKey.selectedLevelID)
    }

    private func persistActiveLevel() {
        UserDefaults.standard.set(activeLevelID, forKey: StorageKey.activeLevelID)
    }
}

private enum StorageKey {
    static let selectedLevelID = "typinggame.selected-level-id"
    static let activeLevelID = "typinggame.active-level-id"
}
