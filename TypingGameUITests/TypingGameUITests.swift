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

        let correctValue = app.staticTexts["summary-correct-value"]
        let wrongValue = app.staticTexts["summary-wrong-value"]
        XCTAssertTrue(correctValue.waitForExistence(timeout: 2))
        XCTAssertTrue(wrongValue.waitForExistence(timeout: 2))

        guard let initialCorrect = intValue(correctValue),
              let initialWrong = intValue(wrongValue) else {
            XCTFail("Unable to parse summary values")
            return
        }

        app.typeText("a")
        let updatedCorrect = waitForValueChange(correctValue, from: initialCorrect)
        let updatedWrong = intValue(wrongValue) ?? initialWrong

        XCTAssertEqual(
            updatedCorrect + updatedWrong,
            initialCorrect + initialWrong + 1
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

        let correctValue = app.staticTexts["summary-correct-value"]
        let wrongValue = app.staticTexts["summary-wrong-value"]
        let pendingValue = app.staticTexts["summary-pending-value"]
        XCTAssertTrue(correctValue.waitForExistence(timeout: 2))
        XCTAssertTrue(wrongValue.waitForExistence(timeout: 2))
        XCTAssertTrue(pendingValue.waitForExistence(timeout: 2))

        guard let initialCorrect = intValue(correctValue),
              let initialWrong = intValue(wrongValue),
              let initialPending = intValue(pendingValue) else {
            XCTFail("Unable to parse summary values")
            return
        }

        app.typeText("a")
        let updatedCorrect = waitForValueChange(correctValue, from: initialCorrect)
        XCTAssertNotEqual(initialCorrect, updatedCorrect)

        let restartButton = app.buttons["restart-level"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 2))
        restartButton.click()

        let resetCorrect = waitForValueChange(correctValue, from: updatedCorrect)
        let resetWrong = intValue(wrongValue) ?? initialWrong
        let resetPending = intValue(pendingValue) ?? initialPending
        XCTAssertEqual(initialCorrect, resetCorrect)
        XCTAssertEqual(initialWrong, resetWrong)
        XCTAssertEqual(initialPending, resetPending)
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

    private func intValue(_ element: XCUIElement) -> Int? {
        let text = elementText(element)
        return Int(text)
    }

    private func waitForValueChange(
        _ element: XCUIElement,
        from initial: Int,
        timeout: TimeInterval = 2
    ) -> Int {
        let predicate = NSPredicate { _, _ in
            guard let value = self.intValue(element) else { return false }
            return value != initial
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        _ = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return intValue(element) ?? initial
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
