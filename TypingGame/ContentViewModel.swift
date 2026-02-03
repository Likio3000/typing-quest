import Combine
import Foundation
import TypingGameCore

final class ContentViewModel: ObservableObject {
    let levels: [Level]
    let session: TypingSession

    @Published var selectedLevelID: String
    @Published var activeLevelID: String
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

        let initialLevel = levels.first ?? LevelCatalog.fallbackLevel
        self.session = TypingSession(targetText: LevelGenerator.generateText(for: initialLevel))
        self.selectedLevelID = initialLevel.id
        self.activeLevelID = initialLevel.id
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
}
