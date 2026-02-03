import Foundation
import TypingGameCore

final class TypingSession: ObservableObject {
    @Published var targetText: String {
        didSet { targetCharacters = Array(targetText) }
    }
    @Published var typedText = ""
    @Published var totalKeystrokes = 0
    @Published var correctedErrors = 0
    @Published var errorCounts: [Character: Int] = [:]
    @Published var wrongKeyTimestamps: [String: Date] = [:]
    @Published var startTime: Date?
    @Published var endTime: Date?

    private var targetCharacters: [Character]

    init(targetText: String) {
        self.targetText = targetText
        self.targetCharacters = Array(targetText)
    }

    var stats: TypingStats {
        let typedCharacters = Array(typedText)
        let comparisonCount = min(typedCharacters.count, targetCharacters.count)
        var correct = 0
        var wrong = 0

        if comparisonCount > 0 {
            for index in 0..<comparisonCount {
                if typedCharacters[index] == targetCharacters[index] {
                    correct += 1
                } else {
                    wrong += 1
                }
            }
        }

        let pending = max(0, targetCharacters.count - typedCharacters.count)
        return TypingStats(
            correct: correct,
            wrong: wrong,
            pending: pending,
            uncorrectedErrors: wrong,
            typedCount: typedCharacters.count
        )
    }

    func metrics(now: Date) -> TypingMetrics {
        let elapsed = elapsedTime(now: now)
        let minutes = elapsed / 60.0
        guard minutes > 0 else {
            return TypingMetrics(elapsed: elapsed, grossWPM: 0, netWPM: 0, accuracy: 0, kpm: 0)
        }

        let grossWPM = (Double(totalKeystrokes) / 5.0) / minutes
        let netWPM = max(0, grossWPM - (Double(stats.uncorrectedErrors) / minutes))
        let accuracy = stats.typedCount > 0 ? Double(stats.correct) / Double(stats.typedCount) : 0
        let kpm = Double(totalKeystrokes) / minutes

        return TypingMetrics(elapsed: elapsed, grossWPM: grossWPM, netWPM: netWPM, accuracy: accuracy, kpm: kpm)
    }

    func handleInput(_ input: KeyInput) {
        guard endTime == nil else { return }
        if startTime == nil {
            startTime = Date()
        }
        totalKeystrokes += 1

        switch input {
        case .backspace:
            handleBackspace()
        case .character(let character):
            handleCharacter(character)
        }
    }

    func setTargetText(_ text: String) {
        targetText = text
        resetSession()
    }

    func resetSession() {
        typedText = ""
        totalKeystrokes = 0
        correctedErrors = 0
        errorCounts = [:]
        wrongKeyTimestamps = [:]
        startTime = nil
        endTime = nil
    }

    func problemKeys(limit: Int) -> [(Character, Int)] {
        let sorted = errorCounts.sorted { $0.value > $1.value }
        return Array(sorted.prefix(limit))
    }

    func nextExpectedCharacter() -> Character? {
        let index = typedText.count
        guard index < targetCharacters.count else { return nil }
        return targetCharacters[index]
    }

    private func handleBackspace() {
        guard !typedText.isEmpty else { return }
        let removeIndex = typedText.index(before: typedText.endIndex)
        let removedCharacter = typedText[removeIndex]
        let position = typedText.count - 1

        if position < targetCharacters.count {
            let expectedCharacter = targetCharacters[position]
            if removedCharacter != expectedCharacter {
                correctedErrors += 1
            }
        }

        typedText.removeLast()
    }

    private func handleCharacter(_ character: Character) {
        guard typedText.count < targetCharacters.count else { return }

        let position = typedText.count
        let expectedCharacter = targetCharacters[position]
        typedText.append(character)

        if character != expectedCharacter {
            errorCounts[expectedCharacter, default: 0] += 1
            if let keyID = KeyMapping.keyDescriptor(for: character)?.baseKey {
                wrongKeyTimestamps[keyID] = Date()
            }
        }

        if typedText.count == targetCharacters.count {
            endTime = Date()
        }
    }

    private func elapsedTime(now: Date) -> TimeInterval {
        guard let startTime else { return 0 }
        let end = endTime ?? now
        return max(0, end.timeIntervalSince(startTime))
    }

    func wrongKeyOpacities(now: Date, fadeDuration: TimeInterval) -> [String: Double] {
        guard fadeDuration > 0 else { return [:] }
        var result: [String: Double] = [:]
        for (keyID, timestamp) in wrongKeyTimestamps {
            let elapsed = now.timeIntervalSince(timestamp)
            if elapsed >= 0 && elapsed < fadeDuration {
                result[keyID] = max(0, 1 - (elapsed / fadeDuration))
            }
        }
        return result
    }
}
