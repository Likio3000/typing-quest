import Foundation

public struct TypingStats {
    public let correct: Int
    public let wrong: Int
    public let pending: Int
    public let uncorrectedErrors: Int
    public let typedCount: Int

    public init(correct: Int, wrong: Int, pending: Int, uncorrectedErrors: Int, typedCount: Int) {
        self.correct = correct
        self.wrong = wrong
        self.pending = pending
        self.uncorrectedErrors = uncorrectedErrors
        self.typedCount = typedCount
    }
}

public struct TypingMetrics {
    public let elapsed: TimeInterval
    public let grossWPM: Double
    public let netWPM: Double
    public let accuracy: Double
    public let kpm: Double

    public init(elapsed: TimeInterval, grossWPM: Double, netWPM: Double, accuracy: Double, kpm: Double) {
        self.elapsed = elapsed
        self.grossWPM = grossWPM
        self.netWPM = netWPM
        self.accuracy = accuracy
        self.kpm = kpm
    }
}
