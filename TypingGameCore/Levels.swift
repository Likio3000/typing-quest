import Foundation

public struct Level: Identifiable, Decodable {
    public let id: String
    public let name: String
    public let description: String
    public let category: String
    public let difficulty: Int
    public let tags: [String]
    public let sortOrder: Int
    public let source: String?
    public let pool: [Character]
    public let length: Int
    public let wordLengthRange: ClosedRange<Int>
    public let includeSpaces: Bool
    public let fixedText: String?

    public var displayLength: Int {
        fixedText?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? length
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case difficulty
        case tags
        case sortOrder
        case source
        case pool
        case length
        case wordLengthRange
        case includeSpaces
        case fixedText
    }

    public init(
        id: String,
        name: String,
        description: String,
        category: String = "General",
        difficulty: Int = 1,
        tags: [String] = [],
        sortOrder: Int = 0,
        source: String? = nil,
        pool: [Character],
        length: Int,
        wordLengthRange: ClosedRange<Int>,
        includeSpaces: Bool,
        fixedText: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.tags = tags
        self.sortOrder = sortOrder
        self.source = source
        self.pool = pool
        self.length = length
        self.wordLengthRange = wordLengthRange
        self.includeSpaces = includeSpaces
        self.fixedText = fixedText
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "General"
        difficulty = try container.decodeIfPresent(Int.self, forKey: .difficulty) ?? 1
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        source = try container.decodeIfPresent(String.self, forKey: .source)

        let poolString = try container.decodeIfPresent(String.self, forKey: .pool) ?? ""
        pool = Array(poolString)

        let rangeValues = try container.decodeIfPresent([Int].self, forKey: .wordLengthRange) ?? [1, 1]
        let lower = rangeValues.first ?? 1
        let upper = rangeValues.dropFirst().first ?? lower
        wordLengthRange = lower...upper

        includeSpaces = try container.decodeIfPresent(Bool.self, forKey: .includeSpaces) ?? true
        fixedText = try container.decodeIfPresent(String.self, forKey: .fixedText)

        if let lengthValue = try container.decodeIfPresent(Int.self, forKey: .length) {
            length = lengthValue
        } else {
            length = fixedText?.count ?? 0
        }
    }
}

public enum LevelCatalog {
    public static let levels: [Level] = loadLevels()
    public static let fallbackLevel = Level(
        id: "fallback",
        name: "Warmup",
        description: "Basic letters.",
        pool: Array("abcdefghijklmnopqrstuvwxyz"),
        length: 160,
        wordLengthRange: 4...6,
        includeSpaces: true
    )

    private static func loadLevels() -> [Level] {
        guard let url = Bundle.main.url(forResource: "levels", withExtension: "json") else {
            return [fallbackLevel]
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Level].self, from: data)
            let sorted = decoded.sorted { lhs, rhs in
                if lhs.sortOrder != rhs.sortOrder {
                    return lhs.sortOrder < rhs.sortOrder
                }
                let categoryOrder = lhs.category.localizedCaseInsensitiveCompare(rhs.category)
                if categoryOrder != .orderedSame {
                    return categoryOrder == .orderedAscending
                }
                if lhs.difficulty != rhs.difficulty {
                    return lhs.difficulty < rhs.difficulty
                }
                let nameOrder = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
                if nameOrder != .orderedSame {
                    return nameOrder == .orderedAscending
                }
                return lhs.id < rhs.id
            }
            return sorted.isEmpty ? [fallbackLevel] : sorted
        } catch {
            return [fallbackLevel]
        }
    }
}

public struct LevelScoreStore {
    public static let storageKey = "levels.bestScores.v1"

    public static func loadAll(levels: [Level]) -> [String: Double] {
        let payload = loadRaw()
        var result: [String: Double] = [:]
        for level in levels {
            if let score = payload[level.id] {
                result[level.id] = score
            }
        }
        return result
    }

    public static func save(_ score: Double, for levelID: String) {
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
