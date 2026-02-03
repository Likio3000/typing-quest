import XCTest

final class TypingGameUITests: XCTestCase {
    private func waitForElement(_ app: XCUIApplication, id: String, timeout: TimeInterval = 8) -> XCUIElement {
        let element = app.descendants(matching: .any).matching(identifier: id).firstMatch
        _ = element.waitForExistence(timeout: timeout)
        return element
    }

    private func elementText(_ element: XCUIElement) -> String {
        if let value = element.value as? String, !value.isEmpty {
            return value
        }
        if !element.label.isEmpty {
            return element.label
        }
        return ""
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchArguments.append("-ui-testing")
        app.launch()
        app.activate()
        return app
    }

    func testAppLaunchShowsCalibrate() {
        let app = launchApp()
        defer { app.terminate() }
        let calibrate = waitForElement(app, id: UIID.handCalibrate)
        XCTAssertTrue(calibrate.exists)
    }

    func testAppShowsSelectedLevelLabel() {
        let app = launchApp()
        defer { app.terminate() }
        let label = waitForElement(app, id: UIID.selectedLevelName)
        XCTAssertTrue(label.exists)
    }

    func testLevelRowExists() {
        let app = launchApp()
        defer { app.terminate() }
        let row = waitForElement(app, id: UIID.levelRow("letters-left-hand"))
        XCTAssertTrue(row.exists)
    }

    func testCalibrateToggleShowsZoomControls() {
        let app = launchApp()
        defer { app.terminate() }
        let calibrate = waitForElement(app, id: UIID.handCalibrate)
        calibrate.click()
        let zoomPlus = waitForElement(app, id: UIID.handZoomPlus)
        XCTAssertTrue(zoomPlus.exists)
    }

    func testZoomPlusChangesValue() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let zoomValue = waitForElement(app, id: UIID.handZoomValue)
        let before = elementText(zoomValue)
        waitForElement(app, id: UIID.handZoomPlus).click()
        let after = elementText(zoomValue)
        XCTAssertNotEqual(before, after)
    }

    func testZoomMinusChangesValue() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let zoomValue = waitForElement(app, id: UIID.handZoomValue)
        let before = elementText(zoomValue)
        waitForElement(app, id: UIID.handZoomMinus).click()
        let after = elementText(zoomValue)
        XCTAssertNotEqual(before, after)
    }

    func testResetPointsSetsDefaultLeftIndex() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let point = waitForElement(app, id: UIID.handPointLeftIndex)
        let original = elementText(point)
        let start = point.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 30, dy: 0))
        start.press(forDuration: 0.2, thenDragTo: end)
        let moved = elementText(point)
        XCTAssertNotEqual(original, moved)
        let reset = waitForElement(app, id: UIID.handResetPoints)
        reset.click()
        let resetValue = elementText(point)
        XCTAssertNotEqual(moved, resetValue)
    }

    func testDragLeftIndexChangesValue() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let point = waitForElement(app, id: UIID.handPointLeftIndex)
        let initial = elementText(point)
        let start = point.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 30, dy: 0))
        start.press(forDuration: 0.2, thenDragTo: end)
        let moved = elementText(point)
        XCTAssertNotEqual(initial, moved)
    }

    func testTypingUpdatesPending() {
        let app = launchApp()
        defer { app.terminate() }
        let pending = waitForElement(app, id: UIID.summaryPendingValue)
        let before = elementText(pending)
        app.typeText("a")
        let after = elementText(pending)
        XCTAssertNotEqual(before, after)
    }

    func testTypingUpdatesCorrectOrWrong() {
        let app = launchApp()
        defer { app.terminate() }
        let correct = waitForElement(app, id: UIID.summaryCorrectValue)
        let wrong = waitForElement(app, id: UIID.summaryWrongValue)
        let before = (Int(elementText(correct)) ?? 0) + (Int(elementText(wrong)) ?? 0)
        app.typeText("a")
        let after = (Int(elementText(correct)) ?? 0) + (Int(elementText(wrong)) ?? 0)
        XCTAssertEqual(after, before + 1)
    }

    func testRestartResetsSummary() {
        let app = launchApp()
        defer { app.terminate() }
        let correct = waitForElement(app, id: UIID.summaryCorrectValue)
        let wrong = waitForElement(app, id: UIID.summaryWrongValue)
        let pending = waitForElement(app, id: UIID.summaryPendingValue)
        let initial = (Int(elementText(correct)) ?? 0, Int(elementText(wrong)) ?? 0, Int(elementText(pending)) ?? 0)
        app.typeText("a")
        waitForElement(app, id: UIID.restartLevel).click()
        let reset = (Int(elementText(correct)) ?? 0, Int(elementText(wrong)) ?? 0, Int(elementText(pending)) ?? 0)
        XCTAssertEqual(reset.0, initial.0)
        XCTAssertEqual(reset.1, initial.1)
        XCTAssertEqual(reset.2, initial.2)
    }

    func testLevelSelectionUpdatesSelectedLabel() {
        let app = launchApp()
        defer { app.terminate() }
        let selected = waitForElement(app, id: UIID.selectedLevelName)
        let before = elementText(selected)
        waitForElement(app, id: UIID.levelRow("letters-right-hand")).click()
        let after = elementText(selected)
        XCTAssertNotEqual(before, after)
    }

    func testElementExists_01() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.summaryCorrectValue)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_02() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.summaryWrongValue)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_03() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.summaryPendingValue)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_04() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let element = waitForElement(app, id: UIID.handZoomPlus)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_05() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let element = waitForElement(app, id: UIID.handZoomMinus)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_06() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let element = waitForElement(app, id: UIID.handZoomValue)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_07() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let element = waitForElement(app, id: UIID.handResetPoints)
        XCTAssertTrue(element.exists)
    }

    func testElementExists_08() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.restartLevel)
        XCTAssertTrue(element.exists)
    }

}
