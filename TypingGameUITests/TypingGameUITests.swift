import XCTest

final class TypingGameUITests: XCTestCase {
    func testHandZoomButtonsAdjustValue() {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        defer {
            app.terminate()
            XCTAssertTrue(app.wait(for: .notRunning, timeout: 5))
        }

        let calibrateButton = app.buttons["hand-calibrate"]
        XCTAssertTrue(calibrateButton.waitForExistence(timeout: 2))
        calibrateButton.click()

        let zoomValue = app.staticTexts["hand-zoom-value"]
        XCTAssertTrue(zoomValue.waitForExistence(timeout: 2))

        let initialValue = elementText(zoomValue)
        let zoomPlus = app.buttons["hand-zoom-plus"]
        let zoomMinus = app.buttons["hand-zoom-minus"]

        XCTAssertTrue(zoomPlus.exists)
        XCTAssertTrue(zoomMinus.exists)

        zoomPlus.click()
        let increasedValue = elementText(zoomValue)
        XCTAssertNotEqual(initialValue, increasedValue)

        zoomMinus.click()
        let finalValue = elementText(zoomValue)
        XCTAssertEqual(initialValue, finalValue)
    }

    func testTypingUpdatesSummaryCounts() {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        defer {
            app.terminate()
            XCTAssertTrue(app.wait(for: .notRunning, timeout: 5))
        }

        let summary = app.staticTexts["summary-stats"]
        XCTAssertTrue(summary.waitForExistence(timeout: 2))

        let initialText = elementText(summary)
        guard let initialCounts = summaryCounts(from: initialText) else {
            XCTFail("Unable to parse summary counts: \(initialText)")
            return
        }

        app.typeText("a")
        let updatedText = waitForTextChange(summary, from: initialText)
        guard let updatedCounts = summaryCounts(from: updatedText) else {
            XCTFail("Unable to parse summary counts: \(updatedText)")
            return
        }

        XCTAssertEqual(
            updatedCounts.correct + updatedCounts.wrong,
            initialCounts.correct + initialCounts.wrong + 1
        )
    }

    func testLevelSelectionUpdatesSelectedLabel() {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        defer {
            app.terminate()
            XCTAssertTrue(app.wait(for: .notRunning, timeout: 5))
        }

        let selectedLabel = app.staticTexts["selected-level-name"]
        XCTAssertTrue(selectedLabel.waitForExistence(timeout: 2))
        let initialText = elementText(selectedLabel)

        let otherLevel = app.buttons["level-row-letters-left-hand"]
        XCTAssertTrue(otherLevel.waitForExistence(timeout: 2))
        otherLevel.click()

        let updatedText = waitForTextChange(selectedLabel, from: initialText)
        XCTAssertNotEqual(initialText, updatedText)
    }

    func testRestartResetsSummaryCounts() {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        defer {
            app.terminate()
            XCTAssertTrue(app.wait(for: .notRunning, timeout: 5))
        }

        let summary = app.staticTexts["summary-stats"]
        XCTAssertTrue(summary.waitForExistence(timeout: 2))
        let initialText = elementText(summary)
        guard summaryCounts(from: initialText) != nil else {
            XCTFail("Unable to parse summary counts: \(initialText)")
            return
        }

        app.typeText("a")
        let updatedText = waitForTextChange(summary, from: initialText)
        XCTAssertNotEqual(initialText, updatedText)

        let restartButton = app.buttons["restart-level"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 2))
        restartButton.click()

        let resetText = waitForTextChange(summary, from: updatedText)
        XCTAssertEqual(initialText, resetText)
    }

    func testCalibrateDragMovesPoint() {
        let app = XCUIApplication()
        app.launch()
        app.activate()
        defer {
            app.terminate()
            XCTAssertTrue(app.wait(for: .notRunning, timeout: 5))
        }

        let calibrateButton = app.buttons["hand-calibrate"]
        XCTAssertTrue(calibrateButton.waitForExistence(timeout: 2))
        calibrateButton.click()

        let zoomMinus = app.buttons["hand-zoom-minus"]
        XCTAssertTrue(zoomMinus.waitForExistence(timeout: 2))

        let point = app.otherElements["hand-point-leftIndex"]
        XCTAssertTrue(point.waitForExistence(timeout: 2))

        let startFrame = point.frame
        let start = point.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 40, dy: 0))
        start.press(forDuration: 0.2, thenDragTo: end)

        let movedFrame = waitForFrameChange(point, from: startFrame)
        XCTAssertGreaterThan(abs(movedFrame.midX - startFrame.midX), 1)
    }

    private func elementText(_ element: XCUIElement) -> String {
        if !element.label.isEmpty {
            return element.label
        }
        if let value = element.value as? String, !value.isEmpty {
            return value
        }
        return ""
    }

    private func summaryCounts(from text: String) -> (correct: Int, wrong: Int, pending: Int)? {
        let pattern = #"Correct:\s*(\d+)\s+Wrong:\s*(\d+)\s+Pending:\s*(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range) else { return nil }

        func intValue(_ index: Int) -> Int? {
            guard let range = Range(match.range(at: index), in: text) else { return nil }
            return Int(text[range])
        }

        guard let correct = intValue(1),
              let wrong = intValue(2),
              let pending = intValue(3) else {
            return nil
        }

        return (correct, wrong, pending)
    }

    private func waitForTextChange(
        _ element: XCUIElement,
        from initial: String,
        timeout: TimeInterval = 2
    ) -> String {
        let predicate = NSPredicate { _, _ in
            let text = self.elementText(element)
            return !text.isEmpty && text != initial
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return elementText(element)
    }

    private func waitForFrameChange(
        _ element: XCUIElement,
        from initial: CGRect,
        timeout: TimeInterval = 2
    ) -> CGRect {
        let deadline = Date().addingTimeInterval(timeout)
        var current = element.frame
        while Date() < deadline {
            current = element.frame
            if current != initial {
                break
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return current
    }
}
