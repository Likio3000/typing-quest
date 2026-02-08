import AppKit
import XCTest
import TypingGameCore
@testable import TypingGame

private func assertStats(
    target: String,
    typed: String,
    correct: Int,
    wrong: Int,
    pending: Int,
    typedCount: Int,
    file: StaticString = #file,
    line: UInt = #line
) {
    let session = TypingSession(targetText: target)
    session.typedText = typed
    let stats = session.stats
    XCTAssertEqual(stats.correct, correct, file: file, line: line)
    XCTAssertEqual(stats.wrong, wrong, file: file, line: line)
    XCTAssertEqual(stats.pending, pending, file: file, line: line)
    XCTAssertEqual(stats.typedCount, typedCount, file: file, line: line)
}

private func withCleanDefaults(_ keys: [String], _ block: () -> Void) {
    let defaults = UserDefaults.standard
    let backup = keys.map { ($0, defaults.object(forKey: $0)) }
    for key in keys { defaults.removeObject(forKey: key) }
    defer {
        for (key, value) in backup {
            if let value {
                defaults.set(value, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    block()
}

private func colorAt(_ text: NSAttributedString, index: Int, key: NSAttributedString.Key) -> NSColor? {
    guard index >= 0, index < text.length else { return nil }
    let attributes = text.attributes(at: index, effectiveRange: nil)
    return attributes[key] as? NSColor
}

private func assertColorEqual(
    _ actual: NSColor?,
    _ expected: NSColor,
    file: StaticString = #file,
    line: UInt = #line
) {
    guard let actual else {
        XCTFail("Missing color attribute", file: file, line: line)
        return
    }
    XCTAssertTrue(actual.isEqual(expected), file: file, line: line)
}

final class TypingSessionStatsTests: XCTestCase {
    func testStats_case001() {
        assertStats(target: "abcd", typed: "", correct: 0, wrong: 0, pending: 4, typedCount: 0)
    }
    func testStats_case002() {
        assertStats(target: "abcd", typed: "a", correct: 1, wrong: 0, pending: 3, typedCount: 1)
    }
    func testStats_case003() {
        assertStats(target: "abcd", typed: "ab", correct: 2, wrong: 0, pending: 2, typedCount: 2)
    }
    func testStats_case004() {
        assertStats(target: "abcd", typed: "abc", correct: 3, wrong: 0, pending: 1, typedCount: 3)
    }
    func testStats_case005() {
        assertStats(target: "abcd", typed: "abcd", correct: 4, wrong: 0, pending: 0, typedCount: 4)
    }
    func testStats_case006() {
        assertStats(target: "abcd", typed: "abcde", correct: 4, wrong: 0, pending: 0, typedCount: 5)
    }
    func testStats_case007() {
        assertStats(target: "abcd", typed: "abxd", correct: 3, wrong: 1, pending: 0, typedCount: 4)
    }
    func testStats_case008() {
        assertStats(target: "abcd", typed: "xbcd", correct: 3, wrong: 1, pending: 0, typedCount: 4)
    }
    func testStats_case009() {
        assertStats(target: "abcd", typed: "wxyz", correct: 0, wrong: 4, pending: 0, typedCount: 4)
    }
    func testStats_case010() {
        assertStats(target: "abcd", typed: "abcc", correct: 3, wrong: 1, pending: 0, typedCount: 4)
    }
    func testStats_case011() {
        assertStats(target: "abcd", typed: "abce", correct: 3, wrong: 1, pending: 0, typedCount: 4)
    }
    func testStats_case012() {
        assertStats(target: "abcd", typed: "abcdx", correct: 4, wrong: 0, pending: 0, typedCount: 5)
    }
    func testStats_case013() {
        assertStats(target: "aaaa", typed: "", correct: 0, wrong: 0, pending: 4, typedCount: 0)
    }
    func testStats_case014() {
        assertStats(target: "aaaa", typed: "a", correct: 1, wrong: 0, pending: 3, typedCount: 1)
    }
    func testStats_case015() {
        assertStats(target: "aaaa", typed: "aa", correct: 2, wrong: 0, pending: 2, typedCount: 2)
    }
    func testStats_case016() {
        assertStats(target: "aaaa", typed: "aaa", correct: 3, wrong: 0, pending: 1, typedCount: 3)
    }
    func testStats_case017() {
        assertStats(target: "aaaa", typed: "aaaa", correct: 4, wrong: 0, pending: 0, typedCount: 4)
    }
    func testStats_case018() {
        assertStats(target: "aaaa", typed: "aaab", correct: 3, wrong: 1, pending: 0, typedCount: 4)
    }
    func testStats_case019() {
        assertStats(target: "aaaa", typed: "baaa", correct: 3, wrong: 1, pending: 0, typedCount: 4)
    }
    func testStats_case020() {
        assertStats(target: "aaaa", typed: "aaaaa", correct: 4, wrong: 0, pending: 0, typedCount: 5)
    }
    func testStats_case021() {
        assertStats(target: "abcabc", typed: "abc", correct: 3, wrong: 0, pending: 3, typedCount: 3)
    }
    func testStats_case022() {
        assertStats(target: "abcabc", typed: "abx", correct: 2, wrong: 1, pending: 3, typedCount: 3)
    }
    func testStats_case023() {
        assertStats(target: "abcabc", typed: "abcab", correct: 5, wrong: 0, pending: 1, typedCount: 5)
    }
    func testStats_case024() {
        assertStats(target: "abcabc", typed: "abcabc", correct: 6, wrong: 0, pending: 0, typedCount: 6)
    }
    func testStats_case025() {
        assertStats(target: "abcabc", typed: "abcabd", correct: 5, wrong: 1, pending: 0, typedCount: 6)
    }
    func testStats_case026() {
        assertStats(target: "abcabc", typed: "xbcabc", correct: 5, wrong: 1, pending: 0, typedCount: 6)
    }
    func testStats_case027() {
        assertStats(target: "abcabc", typed: "abcabx", correct: 5, wrong: 1, pending: 0, typedCount: 6)
    }
    func testStats_case028() {
        assertStats(target: "abcabc", typed: "abcabcx", correct: 6, wrong: 0, pending: 0, typedCount: 7)
    }
    func testStats_case029() {
        assertStats(target: "kitten", typed: "k", correct: 1, wrong: 0, pending: 5, typedCount: 1)
    }
    func testStats_case030() {
        assertStats(target: "kitten", typed: "ki", correct: 2, wrong: 0, pending: 4, typedCount: 2)
    }
    func testStats_case031() {
        assertStats(target: "kitten", typed: "kit", correct: 3, wrong: 0, pending: 3, typedCount: 3)
    }
    func testStats_case032() {
        assertStats(target: "kitten", typed: "kitt", correct: 4, wrong: 0, pending: 2, typedCount: 4)
    }
    func testStats_case033() {
        assertStats(target: "kitten", typed: "kitte", correct: 5, wrong: 0, pending: 1, typedCount: 5)
    }
    func testStats_case034() {
        assertStats(target: "kitten", typed: "kitten", correct: 6, wrong: 0, pending: 0, typedCount: 6)
    }
    func testStats_case035() {
        assertStats(target: "kitten", typed: "kittex", correct: 5, wrong: 1, pending: 0, typedCount: 6)
    }
    func testStats_case036() {
        assertStats(target: "kitten", typed: "mitten", correct: 5, wrong: 1, pending: 0, typedCount: 6)
    }
    func testStats_case037() {
        assertStats(target: "kitten", typed: "kittan", correct: 5, wrong: 1, pending: 0, typedCount: 6)
    }
    func testStats_case038() {
        assertStats(target: "12345", typed: "", correct: 0, wrong: 0, pending: 5, typedCount: 0)
    }
    func testStats_case039() {
        assertStats(target: "12345", typed: "1", correct: 1, wrong: 0, pending: 4, typedCount: 1)
    }
    func testStats_case040() {
        assertStats(target: "12345", typed: "12", correct: 2, wrong: 0, pending: 3, typedCount: 2)
    }
    func testStats_case041() {
        assertStats(target: "12345", typed: "123", correct: 3, wrong: 0, pending: 2, typedCount: 3)
    }
    func testStats_case042() {
        assertStats(target: "12345", typed: "12345", correct: 5, wrong: 0, pending: 0, typedCount: 5)
    }
    func testStats_case043() {
        assertStats(target: "12345", typed: "1234", correct: 4, wrong: 0, pending: 1, typedCount: 4)
    }
    func testStats_case044() {
        assertStats(target: "12345", typed: "02345", correct: 4, wrong: 1, pending: 0, typedCount: 5)
    }
    func testStats_case045() {
        assertStats(target: "12345", typed: "123456", correct: 5, wrong: 0, pending: 0, typedCount: 6)
    }
}

final class TypingSessionInputTests: XCTestCase {
    func testFirstInputSetsStartTime() {
        let session = TypingSession(targetText: "abc")
        XCTAssertNil(session.startTime)
        session.handleInput(.character("a"))
        XCTAssertNotNil(session.startTime)
    }

    func testCompletingTargetSetsEndTime() {
        let session = TypingSession(targetText: "ab")
        session.handleInput(.character("a"))
        XCTAssertNil(session.endTime)
        session.handleInput(.character("b"))
        XCTAssertNotNil(session.endTime)
    }

    func testInputIgnoredAfterEndTime() {
        let session = TypingSession(targetText: "a")
        session.handleInput(.character("a"))
        let total = session.totalKeystrokes
        session.handleInput(.character("b"))
        XCTAssertEqual(session.totalKeystrokes, total)
        XCTAssertEqual(session.typedText, "a")
    }

    func testBackspaceOnEmptyDoesNotChangeTypedText() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "")
        XCTAssertEqual(session.totalKeystrokes, 1)
    }

    func testBackspaceRemovesCharacter() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "a")
    }

    func testBackspaceIncrementsCorrectedErrorsWhenRemovingWrongChar() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("x"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.correctedErrors, 1)
    }

    func testBackspaceDoesNotIncrementCorrectedErrorsWhenRemovingCorrectChar() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.correctedErrors, 0)
    }

    func testEnterCharacterIsAcceptedDuringActiveTyping() {
        let session = TypingSession(targetText: "a\nb")
        session.handleInput(.character("a"))
        session.handleInput(.character("\n"))
        XCTAssertEqual(session.typedText, "a\n")
        XCTAssertNil(session.endTime)
    }

    func testWrongKeyAddsErrorCountForExpectedCharacter() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("x"))
        XCTAssertEqual(session.errorCounts["a"], 1)
    }

    func testWrongKeyAddsTimestampForMappedKey() {
        let session = TypingSession(targetText: "a")
        session.handleInput(.character("s"))
        XCTAssertNotNil(session.wrongKeyTimestamps["s"])
    }

    func testTypingPastTargetDoesNotExtendTypedText() {
        let session = TypingSession(targetText: "a")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        XCTAssertEqual(session.typedText, "a")
        XCTAssertEqual(session.totalKeystrokes, 1)
    }

    func testSetTargetTextResetsSessionState() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.totalKeystrokes = 5
        session.correctedErrors = 2
        session.setTargetText("xy")
        XCTAssertEqual(session.typedText, "")
        XCTAssertEqual(session.totalKeystrokes, 0)
        XCTAssertEqual(session.correctedErrors, 0)
    }

    func testSequence_case001() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        XCTAssertEqual(session.typedText, "a")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 1)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case002() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        XCTAssertEqual(session.typedText, "ab")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case003() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.character("c"))
        XCTAssertEqual(session.typedText, "abc")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 3)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case004() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.character("c"))
        session.handleInput(.character("d"))
        XCTAssertEqual(session.typedText, "abc")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 3)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case005() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "a")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 3)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case006() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 4)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case007() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("x"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "a")
        XCTAssertEqual(session.correctedErrors, 1)
        XCTAssertEqual(session.totalKeystrokes, 3)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case008() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("x"))
        session.handleInput(.backspace)
        session.handleInput(.character("d"))
        XCTAssertEqual(session.typedText, "ad")
        XCTAssertEqual(session.correctedErrors, 1)
        XCTAssertEqual(session.totalKeystrokes, 4)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case009() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case010() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.backspace)
        session.handleInput(.character("a"))
        XCTAssertEqual(session.typedText, "a")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case011() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        session.handleInput(.character("d"))
        XCTAssertEqual(session.typedText, "ad")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 4)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case012() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        session.handleInput(.character("c"))
        XCTAssertEqual(session.typedText, "ac")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 4)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case013() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        session.handleInput(.backspace)
        session.handleInput(.character("c"))
        XCTAssertEqual(session.typedText, "c")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 5)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case014() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        session.handleInput(.character("c"))
        session.handleInput(.character("d"))
        XCTAssertEqual(session.typedText, "acd")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 5)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case015() {
        let session = TypingSession(targetText: "abc")
        session.handleInput(.character("a"))
        session.handleInput(.character("b"))
        session.handleInput(.backspace)
        session.handleInput(.character("c"))
        session.handleInput(.character("c"))
        XCTAssertEqual(session.typedText, "acc")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 5)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case016() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        XCTAssertEqual(session.typedText, "x")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 1)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case017() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("y"))
        XCTAssertEqual(session.typedText, "y")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 1)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case018() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        session.handleInput(.character("y"))
        XCTAssertEqual(session.typedText, "xy")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case019() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        session.handleInput(.character("y"))
        session.handleInput(.character("z"))
        XCTAssertEqual(session.typedText, "xy")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case020() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        session.handleInput(.backspace)
        session.handleInput(.character("y"))
        XCTAssertEqual(session.typedText, "y")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 3)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case021() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case022() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.backspace)
        session.handleInput(.character("x"))
        XCTAssertEqual(session.typedText, "x")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNil(session.endTime)
    }
    func testSequence_case023() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        session.handleInput(.character("x"))
        XCTAssertEqual(session.typedText, "xx")
        XCTAssertEqual(session.correctedErrors, 0)
        XCTAssertEqual(session.totalKeystrokes, 2)
        XCTAssertNotNil(session.endTime)
    }
    func testSequence_case024() {
        let session = TypingSession(targetText: "xy")
        session.handleInput(.character("x"))
        session.handleInput(.backspace)
        session.handleInput(.character("y"))
        session.handleInput(.backspace)
        XCTAssertEqual(session.typedText, "")
        XCTAssertEqual(session.correctedErrors, 1)
        XCTAssertEqual(session.totalKeystrokes, 4)
        XCTAssertNil(session.endTime)
    }
}

final class TypingSessionMetricsTests: XCTestCase {
    func testCompletionProgress_case001() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "ab"
        XCTAssertEqual(session.completionProgress, 0.4, accuracy: 0.0001)
    }

    func testCompletionProgress_case002() {
        let session = TypingSession(targetText: "abc")
        session.typedText = "abcdef"
        XCTAssertEqual(session.completionProgress, 1.0, accuracy: 0.0001)
    }

    func testMetrics_case001() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "a"
        session.totalKeystrokes = 1
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 30.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 2.000000, accuracy: 0.0001)
    }
    func testMetrics_case002() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "ab"
        session.totalKeystrokes = 2
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 2.000000, accuracy: 0.0001)
    }
    func testMetrics_case003() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "abc"
        session.totalKeystrokes = 3
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 120.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.300000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.300000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 1.500000, accuracy: 0.0001)
    }
    func testMetrics_case004() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "abcde"
        session.totalKeystrokes = 5
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 5.000000, accuracy: 0.0001)
    }
    func testMetrics_case005() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "axcde"
        session.totalKeystrokes = 5
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 5.000000, accuracy: 0.0001)
    }
    func testMetrics_case006() {
        let session = TypingSession(targetText: "abcde")
        session.typedText = "axcde"
        session.totalKeystrokes = 10
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 120.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.500000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 5.000000, accuracy: 0.0001)
    }
    func testMetrics_case007() {
        let session = TypingSession(targetText: "hello")
        session.typedText = "hello"
        session.totalKeystrokes = 10
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 30.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 4.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 4.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 20.000000, accuracy: 0.0001)
    }
    func testMetrics_case008() {
        let session = TypingSession(targetText: "hello")
        session.typedText = "hxllo"
        session.totalKeystrokes = 10
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 30.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 4.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 2.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 20.000000, accuracy: 0.0001)
    }
    func testMetrics_case009() {
        let session = TypingSession(targetText: "hello")
        session.typedText = "hxllo"
        session.totalKeystrokes = 15
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 90.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 2.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 1.333333, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 10.000000, accuracy: 0.0001)
    }
    func testMetrics_case010() {
        let session = TypingSession(targetText: "hello")
        session.typedText = ""
        session.totalKeystrokes = 0
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 0.000000, accuracy: 0.0001)
    }
    func testMetrics_case011() {
        let session = TypingSession(targetText: "ab")
        session.typedText = "ab"
        session.totalKeystrokes = 2
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 10.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 2.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 2.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 12.000000, accuracy: 0.0001)
    }
    func testMetrics_case012() {
        let session = TypingSession(targetText: "ab")
        session.typedText = "a"
        session.totalKeystrokes = 1
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 10.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.200000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 1.200000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 6.000000, accuracy: 0.0001)
    }
    func testMetrics_case013() {
        let session = TypingSession(targetText: "ab")
        session.typedText = "b"
        session.totalKeystrokes = 1
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 10.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.200000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 6.000000, accuracy: 0.0001)
    }
    func testMetrics_case014() {
        let session = TypingSession(targetText: "ab")
        session.typedText = "ab"
        session.totalKeystrokes = 4
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 120.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.400000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 2.000000, accuracy: 0.0001)
    }
    func testMetrics_case015() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = "abxd"
        session.totalKeystrokes = 4
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.750000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 4.000000, accuracy: 0.0001)
    }
    func testMetrics_case016() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = "abxd"
        session.totalKeystrokes = 8
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.600000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.600000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.750000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 8.000000, accuracy: 0.0001)
    }
    func testMetrics_case017() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = "abxd"
        session.totalKeystrokes = 8
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 20.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 4.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 1.800000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.750000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 24.000000, accuracy: 0.0001)
    }
    func testMetrics_case018() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = ""
        session.totalKeystrokes = 0
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 20.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 0.000000, accuracy: 0.0001)
    }
    func testMetrics_case019() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = "abcd"
        session.totalKeystrokes = 20
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 180.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.333333, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 1.333333, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 6.666667, accuracy: 0.0001)
    }
    func testMetrics_case020() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = "abcd"
        session.totalKeystrokes = 4
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 180.0)
        session.startTime = start
        session.endTime = end
        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 0.266667, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 0.266667, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 1.000000, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 1.333333, accuracy: 0.0001)
    }

    func testMetrics_accuracyCountsCorrectedErrors() {
        let session = TypingSession(targetText: "abcd")
        session.typedText = "abcd"
        session.totalKeystrokes = 6
        session.correctedErrors = 2
        let start = Date(timeIntervalSince1970: 0)
        let end = Date(timeIntervalSince1970: 60.0)
        session.startTime = start
        session.endTime = end

        let metrics = session.metrics(now: end)
        XCTAssertEqual(metrics.grossWPM, 1.200000, accuracy: 0.0001)
        XCTAssertEqual(metrics.netWPM, 1.200000, accuracy: 0.0001)
        XCTAssertEqual(metrics.accuracy, 0.666667, accuracy: 0.0001)
        XCTAssertEqual(metrics.kpm, 6.000000, accuracy: 0.0001)
    }
}

final class TypingSessionProblemKeyTests: XCTestCase {
    func testProblemKeys_case001() {
        let session = TypingSession(targetText: "abc")
        session.errorCounts["a"] = 3
        session.errorCounts["b"] = 1
        session.errorCounts["c"] = 2
        let result = session.problemKeys(limit: 2)
        XCTAssertLessThanOrEqual(result.count, 2)
        if result.count > 1 {
            XCTAssertGreaterThanOrEqual(result[0].1, result[1].1)
        }
    }
    func testProblemKeys_case002() {
        let session = TypingSession(targetText: "abc")
        session.errorCounts["a"] = 1
        session.errorCounts["b"] = 5
        session.errorCounts["c"] = 2
        let result = session.problemKeys(limit: 1)
        XCTAssertLessThanOrEqual(result.count, 1)
        if result.count > 1 {
            XCTAssertGreaterThanOrEqual(result[0].1, result[1].1)
        }
    }
    func testProblemKeys_case003() {
        let session = TypingSession(targetText: "abc")
        session.errorCounts["x"] = 2
        session.errorCounts["y"] = 2
        let result = session.problemKeys(limit: 5)
        XCTAssertLessThanOrEqual(result.count, 5)
        if result.count > 1 {
            XCTAssertGreaterThanOrEqual(result[0].1, result[1].1)
        }
    }
    func testProblemKeys_case004() {
        let session = TypingSession(targetText: "abc")
        session.errorCounts["m"] = 1
        session.errorCounts["n"] = 4
        session.errorCounts["o"] = 3
        session.errorCounts["p"] = 2
        let result = session.problemKeys(limit: 3)
        XCTAssertLessThanOrEqual(result.count, 3)
        if result.count > 1 {
            XCTAssertGreaterThanOrEqual(result[0].1, result[1].1)
        }
    }
    func testProblemKeys_case005() {
        let session = TypingSession(targetText: "abc")
        session.errorCounts["q"] = 7
        let result = session.problemKeys(limit: 1)
        XCTAssertLessThanOrEqual(result.count, 1)
    }
    func testWrongKeyOpacities_case001() {
        let session = TypingSession(targetText: "abc")
        let now = Date(timeIntervalSince1970: 100)
        session.wrongKeyTimestamps = [
            "a": Date(timeIntervalSince1970: 95),
            "b": Date(timeIntervalSince1970: 50),
            "c": Date(timeIntervalSince1970: 99)
        ]
        let result = session.wrongKeyOpacities(now: now, fadeDuration: 10)
        XCTAssertNotNil(result["a"])
        XCTAssertNil(result["b"])
        XCTAssertNotNil(result["c"])
    }
    func testWrongKeyOpacities_case002() {
        let session = TypingSession(targetText: "abc")
        let now = Date(timeIntervalSince1970: 100)
        session.wrongKeyTimestamps = [
            "a": Date(timeIntervalSince1970: 95),
            "b": Date(timeIntervalSince1970: 50),
            "c": Date(timeIntervalSince1970: 99)
        ]
        let result = session.wrongKeyOpacities(now: now, fadeDuration: 10)
        XCTAssertNotNil(result["a"])
        XCTAssertNil(result["b"])
        XCTAssertNotNil(result["c"])
    }
    func testWrongKeyOpacities_case003() {
        let session = TypingSession(targetText: "abc")
        let now = Date(timeIntervalSince1970: 100)
        session.wrongKeyTimestamps = [
            "a": Date(timeIntervalSince1970: 95),
            "b": Date(timeIntervalSince1970: 50),
            "c": Date(timeIntervalSince1970: 99)
        ]
        let result = session.wrongKeyOpacities(now: now, fadeDuration: 10)
        XCTAssertNotNil(result["a"])
        XCTAssertNil(result["b"])
        XCTAssertNotNil(result["c"])
    }
    func testWrongKeyOpacities_case004() {
        let session = TypingSession(targetText: "abc")
        let now = Date(timeIntervalSince1970: 100)
        session.wrongKeyTimestamps = [
            "a": Date(timeIntervalSince1970: 95),
            "b": Date(timeIntervalSince1970: 50),
            "c": Date(timeIntervalSince1970: 99)
        ]
        let result = session.wrongKeyOpacities(now: now, fadeDuration: 10)
        XCTAssertNotNil(result["a"])
        XCTAssertNil(result["b"])
        XCTAssertNotNil(result["c"])
    }
    func testWrongKeyOpacities_case005() {
        let session = TypingSession(targetText: "abc")
        let now = Date(timeIntervalSince1970: 100)
        session.wrongKeyTimestamps = [
            "a": Date(timeIntervalSince1970: 95),
            "b": Date(timeIntervalSince1970: 50),
            "c": Date(timeIntervalSince1970: 99)
        ]
        let result = session.wrongKeyOpacities(now: now, fadeDuration: 10)
        XCTAssertNotNil(result["a"])
        XCTAssertNil(result["b"])
        XCTAssertNotNil(result["c"])
    }
}

final class KeyMappingTests: XCTestCase {
    func testDisplayKeyName_special01() {
        XCTAssertEqual(KeyMapping.displayKeyName(for: " "), "SPACE")
    }
    func testDisplayKeyName_special02() {
        XCTAssertEqual(KeyMapping.displayKeyName(for: "\n"), "RETURN")
    }
    func testDisplayKeyName_special03() {
        XCTAssertEqual(KeyMapping.displayKeyName(for: "\t"), "TAB")
    }
    func testKeyDescriptor_lower_01() {
        let desc = KeyMapping.keyDescriptor(for: "a")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "a")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_02() {
        let desc = KeyMapping.keyDescriptor(for: "s")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "s")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_03() {
        let desc = KeyMapping.keyDescriptor(for: "d")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "d")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_04() {
        let desc = KeyMapping.keyDescriptor(for: "f")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "f")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_05() {
        let desc = KeyMapping.keyDescriptor(for: "g")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "g")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_06() {
        let desc = KeyMapping.keyDescriptor(for: "h")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "h")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_07() {
        let desc = KeyMapping.keyDescriptor(for: "j")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "j")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_08() {
        let desc = KeyMapping.keyDescriptor(for: "k")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "k")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_09() {
        let desc = KeyMapping.keyDescriptor(for: "l")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "l")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_10() {
        let desc = KeyMapping.keyDescriptor(for: "q")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "q")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_11() {
        let desc = KeyMapping.keyDescriptor(for: "w")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "w")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_12() {
        let desc = KeyMapping.keyDescriptor(for: "e")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "e")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_13() {
        let desc = KeyMapping.keyDescriptor(for: "r")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "r")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_14() {
        let desc = KeyMapping.keyDescriptor(for: "t")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "t")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_lower_15() {
        let desc = KeyMapping.keyDescriptor(for: "y")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "y")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_upper_01() {
        let desc = KeyMapping.keyDescriptor(for: "A")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "a")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_02() {
        let desc = KeyMapping.keyDescriptor(for: "S")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "s")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_03() {
        let desc = KeyMapping.keyDescriptor(for: "D")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "d")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_04() {
        let desc = KeyMapping.keyDescriptor(for: "F")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "f")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_05() {
        let desc = KeyMapping.keyDescriptor(for: "G")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "g")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_06() {
        let desc = KeyMapping.keyDescriptor(for: "H")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "h")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_07() {
        let desc = KeyMapping.keyDescriptor(for: "J")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "j")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_08() {
        let desc = KeyMapping.keyDescriptor(for: "K")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "k")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_09() {
        let desc = KeyMapping.keyDescriptor(for: "L")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "l")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_10() {
        let desc = KeyMapping.keyDescriptor(for: "Q")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "q")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_11() {
        let desc = KeyMapping.keyDescriptor(for: "W")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "w")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_12() {
        let desc = KeyMapping.keyDescriptor(for: "E")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "e")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_13() {
        let desc = KeyMapping.keyDescriptor(for: "R")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "r")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_14() {
        let desc = KeyMapping.keyDescriptor(for: "T")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "t")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_upper_15() {
        let desc = KeyMapping.keyDescriptor(for: "Y")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "y")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_digit_01() {
        let desc = KeyMapping.keyDescriptor(for: "0")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "0")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_02() {
        let desc = KeyMapping.keyDescriptor(for: "1")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "1")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_03() {
        let desc = KeyMapping.keyDescriptor(for: "2")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "2")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_04() {
        let desc = KeyMapping.keyDescriptor(for: "3")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "3")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_05() {
        let desc = KeyMapping.keyDescriptor(for: "4")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "4")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_06() {
        let desc = KeyMapping.keyDescriptor(for: "5")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "5")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_07() {
        let desc = KeyMapping.keyDescriptor(for: "6")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "6")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_08() {
        let desc = KeyMapping.keyDescriptor(for: "7")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "7")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_09() {
        let desc = KeyMapping.keyDescriptor(for: "8")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "8")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_digit_10() {
        let desc = KeyMapping.keyDescriptor(for: "9")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "9")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_01() {
        let desc = KeyMapping.keyDescriptor(for: "!")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "1")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_02() {
        let desc = KeyMapping.keyDescriptor(for: "@")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "2")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_03() {
        let desc = KeyMapping.keyDescriptor(for: "#")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "3")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_04() {
        let desc = KeyMapping.keyDescriptor(for: "$")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "4")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_05() {
        let desc = KeyMapping.keyDescriptor(for: "%")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "5")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_06() {
        let desc = KeyMapping.keyDescriptor(for: "^")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "6")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_07() {
        let desc = KeyMapping.keyDescriptor(for: "&")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "7")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_08() {
        let desc = KeyMapping.keyDescriptor(for: "*")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "8")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_09() {
        let desc = KeyMapping.keyDescriptor(for: "(")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "9")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_10() {
        let desc = KeyMapping.keyDescriptor(for: ")")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "0")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_11() {
        let desc = KeyMapping.keyDescriptor(for: "-")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "-")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_12() {
        let desc = KeyMapping.keyDescriptor(for: "_")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "-")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_13() {
        let desc = KeyMapping.keyDescriptor(for: "=")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "=")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_14() {
        let desc = KeyMapping.keyDescriptor(for: "+")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "=")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_15() {
        let desc = KeyMapping.keyDescriptor(for: "[")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "[")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_16() {
        let desc = KeyMapping.keyDescriptor(for: "{")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "[")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_17() {
        let desc = KeyMapping.keyDescriptor(for: "]")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "]")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_18() {
        let desc = KeyMapping.keyDescriptor(for: "}")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "]")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_19() {
        let desc = KeyMapping.keyDescriptor(for: "\\")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "\\")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_20() {
        let desc = KeyMapping.keyDescriptor(for: "|")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "\\")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_21() {
        let desc = KeyMapping.keyDescriptor(for: ";")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, ";")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_22() {
        let desc = KeyMapping.keyDescriptor(for: ":")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, ";")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_23() {
        let desc = KeyMapping.keyDescriptor(for: "'")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "'")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_24() {
        let desc = KeyMapping.keyDescriptor(for: "\"")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "'")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_25() {
        let desc = KeyMapping.keyDescriptor(for: ",")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, ",")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_26() {
        let desc = KeyMapping.keyDescriptor(for: "<")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, ",")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_27() {
        let desc = KeyMapping.keyDescriptor(for: ".")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, ".")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_28() {
        let desc = KeyMapping.keyDescriptor(for: ">")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, ".")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_29() {
        let desc = KeyMapping.keyDescriptor(for: "/")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "/")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_30() {
        let desc = KeyMapping.keyDescriptor(for: "?")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "/")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testKeyDescriptor_symbol_31() {
        let desc = KeyMapping.keyDescriptor(for: "`")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "`")
        XCTAssertEqual(desc?.needsShift, false)
    }
    func testKeyDescriptor_symbol_32() {
        let desc = KeyMapping.keyDescriptor(for: "~")
        XCTAssertNotNil(desc)
        XCTAssertEqual(desc?.baseKey, "`")
        XCTAssertEqual(desc?.needsShift, true)
    }
    func testCoachInfoFinger_01() {
        let info = KeyMapping.coachInfo(for: "a")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left pinky")
    }
    func testCoachInfoFinger_02() {
        let info = KeyMapping.coachInfo(for: "q")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left pinky")
    }
    func testCoachInfoFinger_03() {
        let info = KeyMapping.coachInfo(for: "s")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left ring")
    }
    func testCoachInfoFinger_04() {
        let info = KeyMapping.coachInfo(for: "e")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left middle")
    }
    func testCoachInfoFinger_05() {
        let info = KeyMapping.coachInfo(for: "t")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left index")
    }
    func testCoachInfoFinger_06() {
        let info = KeyMapping.coachInfo(for: "g")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left index")
    }
    func testCoachInfoFinger_07() {
        let info = KeyMapping.coachInfo(for: "y")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right index")
    }
    func testCoachInfoFinger_08() {
        let info = KeyMapping.coachInfo(for: "u")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right index")
    }
    func testCoachInfoFinger_09() {
        let info = KeyMapping.coachInfo(for: "i")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right middle")
    }
    func testCoachInfoFinger_10() {
        let info = KeyMapping.coachInfo(for: "o")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right ring")
    }
    func testCoachInfoFinger_11() {
        let info = KeyMapping.coachInfo(for: "p")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right pinky")
    }
    func testCoachInfoFinger_12() {
        let info = KeyMapping.coachInfo(for: ";")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right pinky")
    }
    func testCoachInfoFinger_13() {
        let info = KeyMapping.coachInfo(for: " ")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Thumbs")
    }
    func testCoachInfoFinger_14() {
        let info = KeyMapping.coachInfo(for: "\n")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right pinky")
    }
    func testCoachInfoFinger_15() {
        let info = KeyMapping.coachInfo(for: "\t")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left pinky")
    }
    func testCoachInfoFinger_16() {
        let info = KeyMapping.coachInfo(for: "1")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left pinky")
    }
    func testCoachInfoFinger_17() {
        let info = KeyMapping.coachInfo(for: "9")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right ring")
    }
    func testCoachInfoFinger_18() {
        let info = KeyMapping.coachInfo(for: "0")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right pinky")
    }
    func testCoachInfoFinger_19() {
        let info = KeyMapping.coachInfo(for: "b")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Left index")
    }
    func testCoachInfoFinger_20() {
        let info = KeyMapping.coachInfo(for: "m")
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.finger, "Right index")
    }
    func testShiftSide_01() {
        let desc = KeyMapping.keyDescriptor(for: "A")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_02() {
        let desc = KeyMapping.keyDescriptor(for: "S")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_03() {
        let desc = KeyMapping.keyDescriptor(for: "D")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_04() {
        let desc = KeyMapping.keyDescriptor(for: "F")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_05() {
        let desc = KeyMapping.keyDescriptor(for: "J")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_06() {
        let desc = KeyMapping.keyDescriptor(for: "K")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_07() {
        let desc = KeyMapping.keyDescriptor(for: "L")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_08() {
        let desc = KeyMapping.keyDescriptor(for: "P")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_09() {
        let desc = KeyMapping.keyDescriptor(for: "Q")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
    func testShiftSide_10() {
        let desc = KeyMapping.keyDescriptor(for: "Z")
        XCTAssertNotNil(desc)
        if let desc {
            if ["a","s","d","f","q","z"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .right)
            } else if ["j","k","l","p"].contains(desc.baseKey) {
                XCTAssertEqual(desc.shiftSide, .left)
            }
        }
    }
}

final class LevelGeneratorTests: XCTestCase {
    func testFixedTextIsTrimmed() {
        let level = Level(id: "t1", name: "t", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true, fixedText: "  hello  ")
        let text = LevelGenerator.generateText(for: level)
        XCTAssertEqual(text, "hello")
    }

    func testFixedTextIsTrimmedNewlines() {
        let level = Level(id: "t2", name: "t", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true, fixedText: "\nhi\n")
        let text = LevelGenerator.generateText(for: level)
        XCTAssertEqual(text, "hi")
    }

    func testEmptyPoolReturnsEmptyString() {
        let level = Level(id: "t3", name: "t", description: "d", pool: [], length: 10, wordLengthRange: 1...2, includeSpaces: true)
        var rng = SeededGenerator(seed: 1)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        XCTAssertEqual(text, "")
    }

    func testGeneratedTextInvariant_01() {
        let level = Level(id: "g1", name: "t", description: "d", pool: Array("xyz"), length: 21, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 43)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 21 || text.count == 21 - 1)
        } else {
            XCTAssertEqual(text.count, 21)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_02() {
        let level = Level(id: "g2", name: "t", description: "d", pool: Array("xyz"), length: 22, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 44)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 22 || text.count == 22 - 1)
        } else {
            XCTAssertEqual(text.count, 22)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_03() {
        let level = Level(id: "g3", name: "t", description: "d", pool: Array("abcd"), length: 23, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 45)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 23 || text.count == 23 - 1)
        } else {
            XCTAssertEqual(text.count, 23)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_04() {
        let level = Level(id: "g4", name: "t", description: "d", pool: Array("xyz"), length: 24, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 46)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 24 || text.count == 24 - 1)
        } else {
            XCTAssertEqual(text.count, 24)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_05() {
        let level = Level(id: "g5", name: "t", description: "d", pool: Array("xyz"), length: 25, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 47)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 25 || text.count == 25 - 1)
        } else {
            XCTAssertEqual(text.count, 25)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_06() {
        let level = Level(id: "g6", name: "t", description: "d", pool: Array("abcd"), length: 26, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 48)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 26 || text.count == 26 - 1)
        } else {
            XCTAssertEqual(text.count, 26)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_07() {
        let level = Level(id: "g7", name: "t", description: "d", pool: Array("xyz"), length: 27, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 49)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 27 || text.count == 27 - 1)
        } else {
            XCTAssertEqual(text.count, 27)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_08() {
        let level = Level(id: "g8", name: "t", description: "d", pool: Array("xyz"), length: 28, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 50)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 28 || text.count == 28 - 1)
        } else {
            XCTAssertEqual(text.count, 28)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_09() {
        let level = Level(id: "g9", name: "t", description: "d", pool: Array("abcd"), length: 29, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 51)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 29 || text.count == 29 - 1)
        } else {
            XCTAssertEqual(text.count, 29)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_10() {
        let level = Level(id: "g10", name: "t", description: "d", pool: Array("xyz"), length: 30, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 52)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 30 || text.count == 30 - 1)
        } else {
            XCTAssertEqual(text.count, 30)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_11() {
        let level = Level(id: "g11", name: "t", description: "d", pool: Array("xyz"), length: 31, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 53)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 31 || text.count == 31 - 1)
        } else {
            XCTAssertEqual(text.count, 31)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_12() {
        let level = Level(id: "g12", name: "t", description: "d", pool: Array("abcd"), length: 32, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 54)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 32 || text.count == 32 - 1)
        } else {
            XCTAssertEqual(text.count, 32)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_13() {
        let level = Level(id: "g13", name: "t", description: "d", pool: Array("xyz"), length: 33, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 55)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 33 || text.count == 33 - 1)
        } else {
            XCTAssertEqual(text.count, 33)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_14() {
        let level = Level(id: "g14", name: "t", description: "d", pool: Array("xyz"), length: 34, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 56)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 34 || text.count == 34 - 1)
        } else {
            XCTAssertEqual(text.count, 34)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_15() {
        let level = Level(id: "g15", name: "t", description: "d", pool: Array("abcd"), length: 35, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 57)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 35 || text.count == 35 - 1)
        } else {
            XCTAssertEqual(text.count, 35)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_16() {
        let level = Level(id: "g16", name: "t", description: "d", pool: Array("xyz"), length: 36, wordLengthRange: 2...5, includeSpaces: true)
        var rng = SeededGenerator(seed: 58)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 36 || text.count == 36 - 1)
        } else {
            XCTAssertEqual(text.count, 36)
        }
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
    func testGeneratedTextInvariant_17() {
        let level = Level(id: "g17", name: "t", description: "d", pool: Array("xyz"), length: 37, wordLengthRange: 2...4, includeSpaces: false)
        var rng = SeededGenerator(seed: 59)
        let text = LevelGenerator.generateText(for: level, using: &rng)
        if level.includeSpaces {
            XCTAssertTrue(text.count == 37 || text.count == 37 - 1)
        } else {
            XCTAssertEqual(text.count, 37)
        }
        XCTAssertFalse(text.contains(" "))
        for ch in text where ch != " " {
            XCTAssertTrue(level.pool.contains(ch))
        }
    }
}

final class LevelDecodingTests: XCTestCase {
    func testDecode_case01() throws {
        let json = "{\"id\":\"l1\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":10,\"wordLengthRange\":[2,4],\"includeSpaces\":false}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.pool, Array("abc"))
        XCTAssertEqual(level.length, 10)
        XCTAssertEqual(level.wordLengthRange.lowerBound, 2)
        XCTAssertEqual(level.wordLengthRange.upperBound, 4)
        XCTAssertEqual(level.includeSpaces, false)
    }
    func testDecode_case02() throws {
        let json = "{\"id\":\"l2\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":5,\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertTrue(level.includeSpaces)
    }
    func testDecode_case03() throws {
        let json = "{\"id\":\"l3\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"wordLengthRange\":[1,2],\"fixedText\":\"hello\"}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 5)
    }
    func testDecode_case04() throws {
        let json = "{\"id\":\"l4\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":5,\"wordLengthRange\":[3]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.wordLengthRange.lowerBound, 3)
        XCTAssertEqual(level.wordLengthRange.upperBound, 3)
    }
    func testDecode_case05() throws {
        let json = "{\"id\":\"l5\",\"name\":\"n\",\"description\":\"d\",\"length\":5,\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.pool.count, 0)
    }
    func testDecode_case06() throws {
        let json = "{\"id\":\"l6\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":5,\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertTrue(level.includeSpaces)
    }
    func testDecode_case07() throws {
        let json = "{\"id\":\"l7\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"fixedText\":\"  hi  \",\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.displayLength, 2)
    }
    func testDecode_case08() throws {
        let json = "{\"id\":\"l8\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"fixedText\":\"abcd\",\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 4)
    }
    func testDecode_case09() throws {
        let json = "{\"id\":\"l9\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":5}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.wordLengthRange.lowerBound, 1)
        XCTAssertEqual(level.wordLengthRange.upperBound, 1)
    }
    func testDecode_case10() throws {
        let json = "{\"id\":\"l10\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"fixedText\":\"\",\"length\":5,\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.displayLength, 0)
    }
    func testDecode_case11() throws {
        let json = "{\"id\":\"x11\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":11,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 11)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case12() throws {
        let json = "{\"id\":\"x12\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":12,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 12)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case13() throws {
        let json = "{\"id\":\"x13\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":13,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 13)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case14() throws {
        let json = "{\"id\":\"x14\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":14,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 14)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case15() throws {
        let json = "{\"id\":\"x15\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":15,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 15)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case16() throws {
        let json = "{\"id\":\"x16\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":16,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 16)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case17() throws {
        let json = "{\"id\":\"x17\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":17,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 17)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case18() throws {
        let json = "{\"id\":\"x18\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":18,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 18)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case19() throws {
        let json = "{\"id\":\"x19\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":19,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 19)
        XCTAssertEqual(level.pool, Array("xyz"))
    }
    func testDecode_case20() throws {
        let json = "{\"id\":\"x20\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"xyz\",\"length\":20,\"wordLengthRange\":[2,3],\"includeSpaces\":true}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.length, 20)
        XCTAssertEqual(level.pool, Array("xyz"))
    }

    func testDecode_metadataDefaults() throws {
        let json = "{\"id\":\"m1\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":5,\"wordLengthRange\":[1,2]}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.category, "General")
        XCTAssertEqual(level.difficulty, 1)
        XCTAssertEqual(level.tags, [])
        XCTAssertEqual(level.sortOrder, 0)
        XCTAssertNil(level.source)
    }

    func testDecode_metadataValues() throws {
        let json = "{\"id\":\"m2\",\"name\":\"n\",\"description\":\"d\",\"pool\":\"abc\",\"length\":5,\"wordLengthRange\":[1,2],\"category\":\"Letters\",\"difficulty\":3,\"tags\":[\"letters\",\"test\"],\"sortOrder\":42,\"source\":\"spec\"}"
        let data = json.data(using: .utf8)!
        let level = try JSONDecoder().decode(Level.self, from: data)
        XCTAssertEqual(level.category, "Letters")
        XCTAssertEqual(level.difficulty, 3)
        XCTAssertEqual(level.tags, ["letters", "test"])
        XCTAssertEqual(level.sortOrder, 42)
        XCTAssertEqual(level.source, "spec")
    }
}

final class LevelsJSONValidationTests: XCTestCase {
    func testLevelsJSONValid() throws {
        let levels = try loadLevelsFromRepo()
        XCTAssertFalse(levels.isEmpty)

        var ids = Set<String>()
        for level in levels {
            XCTAssertTrue(ids.insert(level.id).inserted, "Duplicate id: \(level.id)")
            XCTAssertFalse(level.name.isEmpty)
            XCTAssertFalse(level.description.isEmpty)
            XCTAssertGreaterThan(level.length, 0)

            if level.fixedText == nil || level.fixedText?.isEmpty == true {
                XCTAssertFalse(level.pool.isEmpty, "Level \(level.id) missing pool")
            }

            let lower = level.wordLengthRange.lowerBound
            let upper = level.wordLengthRange.upperBound
            XCTAssertGreaterThanOrEqual(lower, 1)
            XCTAssertGreaterThanOrEqual(upper, lower)
            XCTAssertLessThanOrEqual(upper, level.length)

            if let fixedText = level.fixedText {
                XCTAssertEqual(fixedText, fixedText.trimmingCharacters(in: .whitespacesAndNewlines))
                for ch in fixedText {
                    let code = ch.unicodeScalars.first?.value ?? 0
                    if ch == "\n" { continue }
                    XCTAssertTrue(code >= 32 && code <= 126, "Level \(level.id) has non-ASCII characters")
                }
            }
        }
    }

    private func loadLevelsFromRepo() throws -> [Level] {
        let testFileURL = URL(fileURLWithPath: #file)
        let repoRoot = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let levelsURL = repoRoot.appendingPathComponent("TypingGame/levels.json")
        let data = try Data(contentsOf: levelsURL)
        return try JSONDecoder().decode([Level].self, from: data)
    }
}

final class ScoreCalculatorTests: XCTestCase {
    func testScore_case01() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 60, grossWPM: 0, netWPM: 0, accuracy: 1.0, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 200)
        XCTAssertEqual(score, 91.225562, accuracy: 0.0001)
    }
    func testScore_case02() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 30, grossWPM: 0, netWPM: 0, accuracy: 0.9, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 1, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 2, targetLength: 150)
        XCTAssertEqual(score, 86.000000, accuracy: 0.0001)
    }
    func testScore_case03() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 120, grossWPM: 0, netWPM: 0, accuracy: 0.8, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 3, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 1, targetLength: 100)
        XCTAssertEqual(score, 31.725562, accuracy: 0.0001)
    }
    func testScore_case04() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 10, grossWPM: 0, netWPM: 0, accuracy: 0.5, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 5, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 4, targetLength: 50)
        XCTAssertEqual(score, 33.000000, accuracy: 0.0001)
    }
    func testScore_case05() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 0, grossWPM: 0, netWPM: 0, accuracy: 1.0, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 100)
        XCTAssertEqual(score, 100.000000, accuracy: 0.0001)
    }
    func testScore_case06() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 20, grossWPM: 0, netWPM: 0, accuracy: 0.0, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 10, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 10, targetLength: 0)
        XCTAssertEqual(score, 0.000000, accuracy: 0.0001)
    }
    func testScore_case07() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 45, grossWPM: 0, netWPM: 0, accuracy: 0.95, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 2, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 180)
        XCTAssertEqual(score, 84.171079, accuracy: 0.0001)
    }
    func testScore_case08() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 80, grossWPM: 0, netWPM: 0, accuracy: 0.6, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 4, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 6, targetLength: 300)
        XCTAssertEqual(score, 38.774438, accuracy: 0.0001)
    }
    func testScore_case09() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 15, grossWPM: 0, netWPM: 0, accuracy: 0.7, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 25)
        XCTAssertEqual(score, 46.225562, accuracy: 0.0001)
    }
    func testScore_case10() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 200, grossWPM: 0, netWPM: 0, accuracy: 0.9, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 1, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 1, targetLength: 500)
        XCTAssertEqual(score, 71.500000, accuracy: 0.0001)
    }
    func testScore_case11() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 75, grossWPM: 0, netWPM: 0, accuracy: 0.85, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 3, targetLength: 220)
        XCTAssertEqual(score, 71.959194, accuracy: 0.0001)
    }
    func testScore_case12() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 90, grossWPM: 0, netWPM: 0, accuracy: 0.4, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 8, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 160)
        XCTAssertEqual(score, 0.000000, accuracy: 0.0001)
    }
    func testScore_case13() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 35, grossWPM: 0, netWPM: 0, accuracy: 1.0, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 5, targetLength: 100)
        XCTAssertEqual(score, 85.389676, accuracy: 0.0001)
    }
    func testScore_case14() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 55, grossWPM: 0, netWPM: 0, accuracy: 0.92, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 2, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 2, targetLength: 140)
        XCTAssertEqual(score, 70.389928, accuracy: 0.0001)
    }
    func testScore_case15() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 65, grossWPM: 0, netWPM: 0, accuracy: 0.88, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 3, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 1, targetLength: 180)
        XCTAssertEqual(score, 65.713358, accuracy: 0.0001)
    }
    func testScore_case16() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 25, grossWPM: 0, netWPM: 0, accuracy: 0.77, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 1, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 2, targetLength: 90)
        XCTAssertEqual(score, 65.891032, accuracy: 0.0001)
    }
    func testScore_case17() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 150, grossWPM: 0, netWPM: 0, accuracy: 0.66, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 6, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 4, targetLength: 260)
        XCTAssertEqual(score, 23.074315, accuracy: 0.0001)
    }
    func testScore_case18() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 18, grossWPM: 0, netWPM: 0, accuracy: 0.83, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 30)
        XCTAssertEqual(score, 59.225562, accuracy: 0.0001)
    }
    func testScore_case19() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 42, grossWPM: 0, netWPM: 0, accuracy: 0.55, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 5, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 3, targetLength: 120)
        XCTAssertEqual(score, 26.389676, accuracy: 0.0001)
    }
    func testScore_case20() {
        let calculator = ScoreCalculator()
        let metrics = TypingMetrics(elapsed: 300, grossWPM: 0, netWPM: 0, accuracy: 0.95, kpm: 0)
        let stats = TypingStats(correct: 0, wrong: 0, pending: 0, uncorrectedErrors: 0, typedCount: 0)
        let score = calculator.score(metrics: metrics, stats: stats, correctedErrors: 0, targetLength: 400)
        XCTAssertEqual(score, 66.396641, accuracy: 0.0001)
    }
}

final class LevelScoreStoreTests: XCTestCase {
    func testScoreStore_case01() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l1", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(10.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 10.0)
        }
    }
    func testScoreStore_case02() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l2", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(20.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 20.0)
        }
    }
    func testScoreStore_case03() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l3", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(30.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 30.0)
        }
    }
    func testScoreStore_case04() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l4", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(40.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 40.0)
        }
    }
    func testScoreStore_case05() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l5", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(50.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 50.0)
        }
    }
    func testScoreStore_case06() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l6", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(60.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 60.0)
        }
    }
    func testScoreStore_case07() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l7", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(70.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 70.0)
        }
    }
    func testScoreStore_case08() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l8", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(80.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 80.0)
        }
    }
    func testScoreStore_case09() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l9", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(90.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 90.0)
        }
    }
    func testScoreStore_case10() {
        withCleanDefaults([LevelScoreStore.storageKey]) {
            let level = Level(id: "l10", name: "n", description: "d", pool: Array("abc"), length: 5, wordLengthRange: 1...2, includeSpaces: true)
            XCTAssertTrue(LevelScoreStore.loadAll(levels: [level]).isEmpty)
            LevelScoreStore.save(100.0, for: level.id)
            let loaded = LevelScoreStore.loadAll(levels: [level])
            XCTAssertEqual(loaded[level.id], 100.0)
        }
    }
}

final class ContentViewModelProgressionShortcutTests: XCTestCase {
    private let selectedLevelKey = "typinggame.selected-level-id"
    private let activeLevelKey = "typinggame.active-level-id"

    private func makeLevel(id: String, sortOrder: Int, difficulty: Int) -> Level {
        Level(
            id: id,
            name: id,
            description: "Test level \(id)",
            category: "Letters",
            difficulty: difficulty,
            tags: ["test"],
            sortOrder: sortOrder,
            source: "tests",
            pool: Array("abc"),
            length: 6,
            wordLengthRange: 1...3,
            includeSpaces: true,
            fixedText: "abcabc"
        )
    }

    func testAdvanceToNextUnlockedLevelFromCompletionAdvancesAndResetsFilterToAll() {
        withCleanDefaults([selectedLevelKey, activeLevelKey, LevelScoreStore.storageKey]) {
            let first = makeLevel(id: "l1", sortOrder: 10, difficulty: 1)
            let second = makeLevel(id: "l2", sortOrder: 20, difficulty: 1)
            let third = makeLevel(id: "l3", sortOrder: 30, difficulty: 1)
            UserDefaults.standard.set(first.id, forKey: selectedLevelKey)
            UserDefaults.standard.set(first.id, forKey: activeLevelKey)

            let viewModel = ContentViewModel(levels: [first, second, third])
            viewModel.levelFilterCategory = "Letters"
            viewModel.session.endTime = Date()

            let advanced = viewModel.advanceToNextUnlockedLevelFromCompletion()

            XCTAssertTrue(advanced)
            XCTAssertEqual(viewModel.activeLevelID, second.id)
            XCTAssertEqual(viewModel.selectedLevelID, second.id)
            XCTAssertEqual(viewModel.levelFilterCategory, "All")
            XCTAssertNil(viewModel.session.endTime)
        }
    }

    func testAdvanceToNextUnlockedLevelFromCompletionReturnsFalseWhenNotCompleted() {
        withCleanDefaults([selectedLevelKey, activeLevelKey, LevelScoreStore.storageKey]) {
            let first = makeLevel(id: "l1", sortOrder: 10, difficulty: 1)
            let second = makeLevel(id: "l2", sortOrder: 20, difficulty: 1)
            UserDefaults.standard.set(first.id, forKey: selectedLevelKey)
            UserDefaults.standard.set(first.id, forKey: activeLevelKey)

            let viewModel = ContentViewModel(levels: [first, second])
            viewModel.levelFilterCategory = "Letters"

            let advanced = viewModel.advanceToNextUnlockedLevelFromCompletion()

            XCTAssertFalse(advanced)
            XCTAssertEqual(viewModel.activeLevelID, first.id)
            XCTAssertEqual(viewModel.selectedLevelID, first.id)
            XCTAssertEqual(viewModel.levelFilterCategory, "Letters")
        }
    }

    func testAdvanceToNextUnlockedLevelFromCompletionReturnsFalseAtLastUnlockedLevel() {
        withCleanDefaults([selectedLevelKey, activeLevelKey, LevelScoreStore.storageKey]) {
            let first = makeLevel(id: "l1", sortOrder: 10, difficulty: 1)
            let second = makeLevel(id: "l2", sortOrder: 20, difficulty: 2)
            let locked = makeLevel(id: "l3", sortOrder: 30, difficulty: 3)

            let viewModel = ContentViewModel(levels: [first, second, locked])
            viewModel.applyLevel(second)
            viewModel.levelFilterCategory = "Letters"
            viewModel.session.endTime = Date()

            let advanced = viewModel.advanceToNextUnlockedLevelFromCompletion()

            XCTAssertFalse(advanced)
            XCTAssertEqual(viewModel.activeLevelID, second.id)
            XCTAssertEqual(viewModel.selectedLevelID, second.id)
            XCTAssertEqual(viewModel.levelFilterCategory, "Letters")
        }
    }

    func testHasNextUnlockedLevelFromActiveCompletionRequiresCompletionAndNextUnlockedLevel() {
        withCleanDefaults([selectedLevelKey, activeLevelKey, LevelScoreStore.storageKey]) {
            let first = makeLevel(id: "l1", sortOrder: 10, difficulty: 1)
            let second = makeLevel(id: "l2", sortOrder: 20, difficulty: 1)
            UserDefaults.standard.set(first.id, forKey: selectedLevelKey)
            UserDefaults.standard.set(first.id, forKey: activeLevelKey)

            let viewModel = ContentViewModel(levels: [first, second])
            XCTAssertFalse(viewModel.hasNextUnlockedLevelFromActiveCompletion())

            viewModel.session.endTime = Date()
            XCTAssertTrue(viewModel.hasNextUnlockedLevelFromActiveCompletion())

            viewModel.applyLevel(second)
            viewModel.session.endTime = Date()
            XCTAssertFalse(viewModel.hasNextUnlockedLevelFromActiveCompletion())
        }
    }
}

final class HandCalibrationTests: XCTestCase {
    func testHandCalibration_case01() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case02() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case03() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case04() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case05() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case06() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case07() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case08() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case09() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
    func testHandCalibration_case10() {
        withCleanDefaults([HandCalibration.storageKey]) {
            let defaults = HandCalibration.defaultPoints
            XCTAssertEqual(defaults.count, 10)
            var updated = defaults
            updated[.leftIndex] = CGPoint(x: 0.11, y: 0.22)
            HandCalibration.savePoints(updated)
            let loaded = HandCalibration.loadPoints()
            XCTAssertEqual(loaded[.leftIndex]?.x ?? 0, 0.11, accuracy: 0.0001)
            XCTAssertEqual(loaded[.leftIndex]?.y ?? 0, 0.22, accuracy: 0.0001)
        }
    }
}

final class HandImageZoomTests: XCTestCase {
    func testHandImageZoom_case01() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case02() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case03() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case04() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case05() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case06() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case07() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case08() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case09() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
    func testHandImageZoom_case10() {
        withCleanDefaults([HandImageZoom.storageKey]) {
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.defaultZoom, accuracy: 0.0001)
            HandImageZoom.save(10)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.upperBound, accuracy: 0.0001)
            HandImageZoom.save(0.1)
            XCTAssertEqual(HandImageZoom.load(), HandImageZoom.range.lowerBound, accuracy: 0.0001)
        }
    }
}

final class TargetTextRendererTests: XCTestCase {
    private let colors = TargetTextColors(
        text: NSColor.white,
        correctBackground: NSColor.green,
        wrongBackground: NSColor.red,
        caretBackground: NSColor.blue,
        caretText: NSColor.black,
        caretIndicator: NSColor.orange
    )

    func testCaretAtStartUsesCaretBackground() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abc", typedText: "", fontSize: 12, colors: colors)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.caretBackground)
    }
    func testCorrectTypedCharUsesCorrectBackground() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abc", typedText: "a", fontSize: 12, colors: colors)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
    }
    func testWrongTypedCharUsesWrongBackground() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abc", typedText: "x", fontSize: 12, colors: colors)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.wrongBackground)
    }
    func testCaretIndicatorAppendsWhenComplete() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "ab", typedText: "ab", fontSize: 12, colors: colors)
        XCTAssertEqual(text.length, 3)
        assertColorEqual(colorAt(text, index: 2, key: .foregroundColor), colors.caretIndicator)
    }
    func testNoCaretIndicatorWhenNotComplete() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "ab", typedText: "a", fontSize: 12, colors: colors)
        XCTAssertEqual(text.length, 2)
    }
    func testRenderReturnsSameInstanceForNoChange() {
        let renderer = TargetTextRenderer()
        let first = renderer.render(targetText: "ab", typedText: "", fontSize: 12, colors: colors)
        let second = renderer.render(targetText: "ab", typedText: "", fontSize: 12, colors: colors)
        XCTAssertTrue(first === second)
    }
    func testRenderReturnsSameInstanceForIncrementalTyping() {
        let renderer = TargetTextRenderer()
        let first = renderer.render(targetText: "ab", typedText: "", fontSize: 12, colors: colors)
        let second = renderer.render(targetText: "ab", typedText: "a", fontSize: 12, colors: colors)
        XCTAssertTrue(first === second)
    }
    func testRenderAttributesInvariant_08() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_09() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_10() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_11() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_12() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_13() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_14() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
    func testRenderAttributesInvariant_15() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "abcd", typedText: "ab", fontSize: 14, colors: colors)
        XCTAssertEqual(text.length, 4)
        assertColorEqual(colorAt(text, index: 0, key: .backgroundColor), colors.correctBackground)
        assertColorEqual(colorAt(text, index: 1, key: .backgroundColor), colors.correctBackground)
    }
}

final class TargetTextRendererSnapshotTests: XCTestCase {
    private let colors = TargetTextColors(
        text: NSColor.white,
        correctBackground: NSColor.green,
        wrongBackground: NSColor.red,
        caretBackground: NSColor.blue,
        caretText: NSColor.yellow,
        caretIndicator: NSColor.magenta
    )

    func testSnapshotCaretAtStart() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "ab", typedText: "", fontSize: 12, colors: colors)
        XCTAssertEqual(snapshotString(text), """
text="a" fg=1.00,1.00,0.00,1.00 bg=0.00,0.00,1.00,1.00 size=12
text="b" fg=1.00,1.00,1.00,1.00 bg=nil size=12
""")
    }

    func testSnapshotCorrectThenCaret() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "ab", typedText: "a", fontSize: 12, colors: colors)
        XCTAssertEqual(snapshotString(text), """
text="a" fg=1.00,1.00,1.00,1.00 bg=0.00,1.00,0.00,1.00 size=12
text="b" fg=1.00,1.00,0.00,1.00 bg=0.00,0.00,1.00,1.00 size=12
""")
    }

    func testSnapshotWrongThenCaret() {
        let renderer = TargetTextRenderer()
        let text = renderer.render(targetText: "ab", typedText: "x", fontSize: 12, colors: colors)
        XCTAssertEqual(snapshotString(text), """
text="a" fg=1.00,1.00,1.00,1.00 bg=1.00,0.00,0.00,1.00 size=12
text="b" fg=1.00,1.00,0.00,1.00 bg=0.00,0.00,1.00,1.00 size=12
""")
    }

    private func snapshotString(_ attributed: NSAttributedString) -> String {
        let range = NSRange(location: 0, length: attributed.length)
        var lines: [String] = []
        attributed.enumerateAttributes(in: range, options: []) { attrs, runRange, _ in
            let text = attributed.attributedSubstring(from: runRange).string
            let foreground = colorString(attrs[.foregroundColor] as? NSColor)
            let background = colorString(attrs[.backgroundColor] as? NSColor)
            let fontSize = Int(((attrs[.font] as? NSFont)?.pointSize ?? 0).rounded())
            lines.append("text=\"\(text)\" fg=\(foreground) bg=\(background) size=\(fontSize)")
        }
        return lines.joined(separator: "\n")
    }

    private func colorString(_ color: NSColor?) -> String {
        guard let color else { return "nil" }
        let normalized = color.usingColorSpace(.sRGB) ?? color
        return String(format: "%.2f,%.2f,%.2f,%.2f", normalized.redComponent, normalized.greenComponent, normalized.blueComponent, normalized.alphaComponent)
    }
}

final class FingerIdentifierTests: XCTestCase {
    func testFromLabel_case01() {
        let result = FingerIdentifier.from(label: "Left pinky")
        XCTAssertEqual(Set(result), Set([.leftPinky]))
    }
    func testFromLabel_case02() {
        let result = FingerIdentifier.from(label: "Left ring")
        XCTAssertEqual(Set(result), Set([.leftRing]))
    }
    func testFromLabel_case03() {
        let result = FingerIdentifier.from(label: "Left middle")
        XCTAssertEqual(Set(result), Set([.leftMiddle]))
    }
    func testFromLabel_case04() {
        let result = FingerIdentifier.from(label: "Left index")
        XCTAssertEqual(Set(result), Set([.leftIndex]))
    }
    func testFromLabel_case05() {
        let result = FingerIdentifier.from(label: "Right index")
        XCTAssertEqual(Set(result), Set([.rightIndex]))
    }
    func testFromLabel_case06() {
        let result = FingerIdentifier.from(label: "Right middle")
        XCTAssertEqual(Set(result), Set([.rightMiddle]))
    }
    func testFromLabel_case07() {
        let result = FingerIdentifier.from(label: "Right ring")
        XCTAssertEqual(Set(result), Set([.rightRing]))
    }
    func testFromLabel_case08() {
        let result = FingerIdentifier.from(label: "Right pinky")
        XCTAssertEqual(Set(result), Set([.rightPinky]))
    }
    func testFromLabel_case09() {
        let result = FingerIdentifier.from(label: "Thumbs")
        XCTAssertEqual(Set(result), Set([.leftThumb, .rightThumb]))
    }
    func testFromLabel_case10() {
        let result = FingerIdentifier.from(label: "Unknown")
        XCTAssertTrue(result.isEmpty)
    }
    func testShortLabel_case01() {
        XCTAssertEqual(FingerIdentifier.leftThumb.shortLabel, "LT")
    }
    func testShortLabel_case02() {
        XCTAssertEqual(FingerIdentifier.leftIndex.shortLabel, "LI")
    }
    func testShortLabel_case03() {
        XCTAssertEqual(FingerIdentifier.leftMiddle.shortLabel, "LM")
    }
    func testShortLabel_case04() {
        XCTAssertEqual(FingerIdentifier.leftRing.shortLabel, "LR")
    }
    func testShortLabel_case05() {
        XCTAssertEqual(FingerIdentifier.leftPinky.shortLabel, "LP")
    }
    func testShortLabel_case06() {
        XCTAssertEqual(FingerIdentifier.rightThumb.shortLabel, "RT")
    }
    func testShortLabel_case07() {
        XCTAssertEqual(FingerIdentifier.rightIndex.shortLabel, "RI")
    }
    func testShortLabel_case08() {
        XCTAssertEqual(FingerIdentifier.rightMiddle.shortLabel, "RM")
    }
    func testShortLabel_case09() {
        XCTAssertEqual(FingerIdentifier.rightRing.shortLabel, "RR")
    }
    func testShortLabel_case10() {
        XCTAssertEqual(FingerIdentifier.rightPinky.shortLabel, "RP")
    }
}
