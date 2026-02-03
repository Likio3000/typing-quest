import Foundation

public struct ScoreCalculator {
    public var targetWPM: Double = 60
    public var speedBonusFactor: Double = 15
    public var uncorrectedPenalty: Double = 3
    public var correctedPenalty: Double = 0.5

    public init() {}

    public func score(
        metrics: TypingMetrics,
        stats: TypingStats,
        correctedErrors: Int,
        targetLength: Int
    ) -> Double {
        let accuracyScore = metrics.accuracy * 100
        let uncorrectedPenalty = Double(stats.uncorrectedErrors) * uncorrectedPenalty
        let correctedPenalty = Double(correctedErrors) * correctedPenalty
        let expectedSeconds = expectedTimeSeconds(for: targetLength)
        let speedBonus: Double
        if metrics.elapsed > 0, expectedSeconds > 0 {
            speedBonus = speedBonusFactor * log2(expectedSeconds / metrics.elapsed)
        } else {
            speedBonus = 0
        }
        let rawScore = accuracyScore - uncorrectedPenalty - correctedPenalty + speedBonus
        return max(0, rawScore)
    }

    private func expectedTimeSeconds(for targetLength: Int) -> Double {
        guard targetLength > 0 else { return 0 }
        let words = Double(targetLength) / 5.0
        let minutes = words / targetWPM
        return minutes * 60.0
    }
}
