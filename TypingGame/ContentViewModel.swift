import Combine
import Foundation
import TypingGameCore

final class ContentViewModel: ObservableObject {
    let levels: [Level]
    let session: TypingSession

    @Published var levelFilterCategory: String = "All"
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
        let loadedBestScores = LevelScoreStore.loadAll(levels: levels)
        let initialUnlockedDifficulty = Self.maxUnlockedDifficulty(levels: levels, bestScores: loadedBestScores)
        let firstUnlockedLevel = levels.first(where: { $0.difficulty <= initialUnlockedDifficulty }) ?? defaultLevel

        let selectedLevelID = Self.resolveLevelID(savedSelectedID, levels: levels) ?? defaultLevel.id
        let selectedLevelCandidate = levels.first(where: { $0.id == selectedLevelID }) ?? defaultLevel
        let selectedLevel = selectedLevelCandidate.difficulty <= initialUnlockedDifficulty ? selectedLevelCandidate : firstUnlockedLevel

        let activeLevelID = Self.resolveLevelID(savedActiveID, levels: levels) ?? selectedLevel.id
        let activeLevelCandidate = levels.first(where: { $0.id == activeLevelID }) ?? selectedLevel
        let activeLevel = activeLevelCandidate.difficulty <= initialUnlockedDifficulty ? activeLevelCandidate : selectedLevel

        self.session = TypingSession(targetText: LevelGenerator.generateText(for: activeLevel))
        self.selectedLevelID = selectedLevel.id
        self.activeLevelID = activeLevel.id
        self.bestScores = loadedBestScores
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

    var categories: [String] {
        let unique = Set(levels.map { $0.category })
        return ["All"] + unique.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var filteredLevels: [Level] {
        let category = levelFilterCategory
        guard category != "All" else {
            return levels
        }
        return levels.filter { level in
            level.category == category
        }
    }

    var maxUnlockedDifficulty: Int {
        Self.maxUnlockedDifficulty(levels: levels, bestScores: bestScores)
    }

    func isLevelUnlocked(_ level: Level) -> Bool {
        level.difficulty <= maxUnlockedDifficulty
    }

    func applyLevel(_ level: Level) {
        guard isLevelUnlocked(level) else { return }
        selectedLevelID = level.id
        activeLevelID = level.id
        session.setTargetText(LevelGenerator.generateText(for: level))
    }

    @discardableResult
    func advanceToNextUnlockedLevelFromCompletion() -> Bool {
        guard session.endTime != nil else { return false }
        guard let nextLevel = nextUnlockedLevel(after: activeLevelID) else { return false }
        levelFilterCategory = "All"
        applyLevel(nextLevel)
        return true
    }

    func hasNextUnlockedLevelFromActiveCompletion() -> Bool {
        guard session.endTime != nil else { return false }
        return nextUnlockedLevel(after: activeLevelID) != nil
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

    private static func maxUnlockedDifficulty(levels: [Level], bestScores: [String: Double]) -> Int {
        let maximumConfiguredDifficulty = max(Progression.baseUnlockedDifficulty, levels.map(\.difficulty).max() ?? Progression.baseUnlockedDifficulty)
        var unlocked = Progression.baseUnlockedDifficulty

        while unlocked < maximumConfiguredDifficulty {
            let completions = levels.filter { level in
                guard level.difficulty == unlocked else { return false }
                guard let score = bestScores[level.id] else { return false }
                return score >= Progression.scoreThresholdToProgress
            }.count

            guard completions >= Progression.requiredCompletionsPerDifficulty else {
                break
            }
            unlocked += 1
        }

        return unlocked
    }

    private func persistSelectedLevel() {
        UserDefaults.standard.set(selectedLevelID, forKey: StorageKey.selectedLevelID)
    }

    private func persistActiveLevel() {
        UserDefaults.standard.set(activeLevelID, forKey: StorageKey.activeLevelID)
    }

    private func nextUnlockedLevel(after levelID: String) -> Level? {
        guard let currentIndex = levels.firstIndex(where: { $0.id == levelID }) else { return nil }
        for level in levels.dropFirst(currentIndex + 1) {
            if isLevelUnlocked(level) {
                return level
            }
        }
        return nil
    }
}

private enum StorageKey {
    static let selectedLevelID = "typinggame.selected-level-id"
    static let activeLevelID = "typinggame.active-level-id"
}

private enum Progression {
    static let baseUnlockedDifficulty = 2
    static let scoreThresholdToProgress = 70.0
    static let requiredCompletionsPerDifficulty = 3
}
