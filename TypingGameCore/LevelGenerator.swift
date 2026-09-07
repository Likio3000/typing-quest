import Foundation

public struct LevelGenerator {
    public static func generateText(for level: Level) -> String {
        var rng = SystemRandomNumberGenerator()
        return generateText(for: level, using: &rng)
    }

    public static func generateText<R: RandomNumberGenerator>(for level: Level, using rng: inout R) -> String {
        if let fixedText = level.fixedText, !fixedText.isEmpty {
            return fixedText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard level.length > 0,
              level.wordLengthRange.lowerBound > 0,
              !level.pool.isEmpty else {
            return ""
        }
        var result = ""
        var remaining = level.length

        while remaining > 0 {
            let nextWordLength = min(Int.random(in: level.wordLengthRange, using: &rng), remaining)
            for _ in 0..<nextWordLength {
                if let next = level.pool.randomElement(using: &rng) {
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
}

public struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    public init(seed: UInt64) {
        self.state = seed == 0 ? 0xCAFEF00DDEADBEEF : seed
    }

    public mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
