import Foundation

enum Hand {
    case left
    case right
    case both
    case unknown
}

enum ShiftSide {
    case left
    case right
    case either
    case unknown
}

struct KeyDescriptor {
    let baseKey: String
    let needsShift: Bool
    let shiftSide: ShiftSide
}

struct KeyCoachInfo {
    let displayKey: String
    let combo: String
    let finger: String
    let shiftSide: String?
}

struct KeyMapping {
    static func coachInfo(for character: Character) -> KeyCoachInfo? {
        let displayKey = displayKeyName(for: character)
        guard let (baseKey, needsShift) = baseKeyAndShift(for: character) else {
            return nil
        }

        let finger = fingerForBaseKey(baseKey)
        let hand = handForBaseKey(baseKey)
        let side = shiftSide(for: needsShift, hand: hand)
        let shiftSide = needsShift ? shiftSideName(for: side) : nil
        let combo = comboName(baseKey: baseKey, needsShift: needsShift)

        return KeyCoachInfo(displayKey: displayKey, combo: combo, finger: finger, shiftSide: shiftSide)
    }

    static func keyDescriptor(for character: Character) -> KeyDescriptor? {
        guard let (baseKey, needsShift) = baseKeyAndShift(for: character) else {
            return nil
        }
        let hand = handForBaseKey(baseKey)
        let shiftSide = shiftSide(for: needsShift, hand: hand)
        return KeyDescriptor(baseKey: baseKey, needsShift: needsShift, shiftSide: shiftSide)
    }

    static func displayKeyName(for character: Character) -> String {
        switch character {
        case " ":
            return "SPACE"
        case "\n":
            return "RETURN"
        case "\t":
            return "TAB"
        default:
            return String(character)
        }
    }

    private static func comboName(baseKey: String, needsShift: Bool) -> String {
        if baseKey == "space" {
            return "Space"
        }
        if baseKey == "return" {
            return "Return"
        }
        if baseKey == "tab" {
            return "Tab"
        }
        if needsShift {
            return "Shift + \(baseKey)"
        }
        return baseKey
    }

    private static func shiftSide(for needsShift: Bool, hand: Hand) -> ShiftSide {
        guard needsShift else { return .unknown }
        switch hand {
        case .left:
            return .right
        case .right:
            return .left
        case .both:
            return .either
        case .unknown:
            return .unknown
        }
    }

    private static func shiftSideName(for side: ShiftSide) -> String? {
        switch side {
        case .left:
            return "Left Shift"
        case .right:
            return "Right Shift"
        case .either:
            return "Either Shift"
        case .unknown:
            return "Shift"
        }
    }

    private static func baseKeyAndShift(for character: Character) -> (String, Bool)? {
        if character == " " { return ("space", false) }
        if character == "\n" { return ("return", false) }
        if character == "\t" { return ("tab", false) }

        let stringChar = String(character)
        if let lower = stringChar.lowercased().first, lower.isLetter {
            let needsShift = stringChar != String(lower)
            return (String(lower), needsShift)
        }
        if character.isNumber {
            return (stringChar, false)
        }

        if let mapped = symbolMap[character] {
            return mapped
        }
        return nil
    }

    private static func fingerForBaseKey(_ baseKey: String) -> String {
        fingerMap[baseKey] ?? "Unknown"
    }

    private static func handForBaseKey(_ baseKey: String) -> Hand {
        if baseKey == "space" { return .both }
        if leftHandKeys.contains(baseKey) { return .left }
        if rightHandKeys.contains(baseKey) { return .right }
        return .unknown
    }

    private static let symbolMap: [Character: (String, Bool)] = [
        "!": ("1", true),
        "@": ("2", true),
        "#": ("3", true),
        "$": ("4", true),
        "%": ("5", true),
        "^": ("6", true),
        "&": ("7", true),
        "*": ("8", true),
        "(": ("9", true),
        ")": ("0", true),
        "-": ("-", false),
        "_": ("-", true),
        "=": ("=", false),
        "+": ("=", true),
        "[": ("[", false),
        "{": ("[", true),
        "]": ("]", false),
        "}": ("]", true),
        "\\": ("\\", false),
        "|": ("\\", true),
        ";": (";", false),
        ":": (";", true),
        "'": ("'", false),
        "\"": ("'", true),
        ",": (",", false),
        "<": (",", true),
        ".": (".", false),
        ">": (".", true),
        "/": ("/", false),
        "?": ("/", true),
        "`": ("`", false),
        "~": ("`", true)
    ]

    private static let fingerMap: [String: String] = [
        "`": "Left pinky",
        "1": "Left pinky",
        "q": "Left pinky",
        "a": "Left pinky",
        "z": "Left pinky",
        "2": "Left ring",
        "w": "Left ring",
        "s": "Left ring",
        "x": "Left ring",
        "3": "Left middle",
        "e": "Left middle",
        "d": "Left middle",
        "c": "Left middle",
        "4": "Left index",
        "5": "Left index",
        "r": "Left index",
        "t": "Left index",
        "f": "Left index",
        "g": "Left index",
        "v": "Left index",
        "b": "Left index",
        "6": "Right index",
        "7": "Right index",
        "y": "Right index",
        "u": "Right index",
        "h": "Right index",
        "j": "Right index",
        "n": "Right index",
        "m": "Right index",
        "8": "Right middle",
        "i": "Right middle",
        "k": "Right middle",
        ",": "Right middle",
        "9": "Right ring",
        "o": "Right ring",
        "l": "Right ring",
        ".": "Right ring",
        "0": "Right pinky",
        "p": "Right pinky",
        ";": "Right pinky",
        "/": "Right pinky",
        "-": "Right pinky",
        "=": "Right pinky",
        "[": "Right pinky",
        "]": "Right pinky",
        "\\": "Right pinky",
        "'": "Right pinky",
        "space": "Thumbs",
        "return": "Right pinky",
        "tab": "Left pinky"
    ]

    private static let leftHandKeys: Set<String> = [
        "`", "1", "2", "3", "4", "5",
        "q", "w", "e", "r", "t",
        "a", "s", "d", "f", "g",
        "z", "x", "c", "v", "b"
    ]

    private static let rightHandKeys: Set<String> = [
        "6", "7", "8", "9", "0",
        "y", "u", "i", "o", "p",
        "h", "j", "k", "l",
        "n", "m", ",", ".", "/",
        ";", "-", "=", "[", "]", "\\", "'",
        "return"
    ]
}
