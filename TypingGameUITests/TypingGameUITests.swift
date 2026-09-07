import AppKit
import XCTest

final class TypingGameUITests: XCTestCase {
    private let testBundleID = "com.typinggame.app.uitesting"
    private let fixture = "asdf jkl;"

    override func setUpWithError() throws {
        continueAfterFailure = false
        executionTimeAllowance = 30
    }

    private func requireFocus(_ app: XCUIApplication) {
        XCTAssertEqual(app.state, .runningForeground, "Stop: test app lost focus")
        XCTAssertEqual(NSWorkspace.shared.frontmostApplication?.bundleIdentifier, testBundleID,
                       "Stop: another app has focus")
    }

    private func typeFixture(_ app: XCUIApplication, text: String) {
        requireFocus(app)
        for character in text {
            requireFocus(app)
            app.typeText(String(character))
        }
    }

    private func waitForElement(_ app: XCUIApplication, id: String, timeout: TimeInterval = 8) -> XCUIElement {
        let element = app.descendants(matching: .any).matching(identifier: id).firstMatch
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Missing \(id)")
        requireFocus(app)
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

    private func launchApp(reset: Bool = true, height: Int = 900, problems: Bool = false) -> XCUIApplication {
        // Never launch/terminate the personal build, even when Launch Services has duplicates.
        let app = XCUIApplication(bundleIdentifier: testBundleID)
        addTeardownBlock { app.terminate() }
        let token = UUID().uuidString
        app.launchEnvironment["UI_TEST_TOKEN"] = token
        app.launchEnvironment["UI_TEST_WINDOW"] = "1"
        app.launchEnvironment["UI_TEST_HEIGHT"] = String(height)
        app.launchEnvironment["UI_TEST_PROBLEMS"] = problems ? "1" : "0"
        app.launchEnvironment["UI_TEST_RESET"] = reset ? "1" : "0"
        app.launchEnvironment["UI_TEST_TARGET_TEXT"] = fixture
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchArguments.append("-ui-testing")
        app.launch()
        let identity = app.descendants(matching: .any).matching(identifier: "ui-test-identity").firstMatch
        XCTAssertTrue(identity.waitForExistence(timeout: 5), "Isolated build did not identify itself: \(app.debugDescription)")
        let testBundle = Bundle(for: type(of: self)).bundleURL
        let products = (0..<4).reduce(testBundle) { url, _ in url.deletingLastPathComponent() }
        XCTAssertEqual(identity.label, token + "|" + products.appendingPathComponent("Typing Quest.app").path,
                       "Unexpected test build path")
        requireFocus(app)
        return app
    }

    func testNativeCloseButtonClosesWindow() {
        let app = launchApp()
        let window = app.windows.firstMatch
        let close = window.buttons[XCUIIdentifierCloseWindow]
        XCTAssertTrue(close.exists)
        XCTAssertTrue(close.isEnabled)
        XCTAssertTrue(close.isHittable)
        requireFocus(app)
        close.click()
        let closed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        XCTAssertEqual(XCTWaiter.wait(for: [closed], timeout: 4), .completed)
    }

    func testNativeZoomRestoresWindowAndCloseStillWorks() {
        let app = launchApp()
        let window = app.windows.firstMatch
        let original = window.frame
        // The floating voice panel can cover traffic lights at the screen edge.
        // Exercise the same native zoom action through its unobscured menu item.
        requireFocus(app)
        app.menuBars.menuBarItems["Window"].click()
        app.menuItems["Zoom"].click()
        requireFocus(app)
        let zoomed = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            window.exists && (abs(window.frame.width - original.width) > 40 || abs(window.frame.height - original.height) > 40)
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [zoomed], timeout: 4), .completed)
        requireFocus(app)
        app.menuBars.menuBarItems["Window"].click()
        app.menuItems["Zoom"].click()
        requireFocus(app)
        let restored = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            window.exists && abs(window.frame.width - original.width) < 2 && abs(window.frame.height - original.height) < 2
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [restored], timeout: 4), .completed)
        requireFocus(app)
        window.buttons[XCUIIdentifierCloseWindow].click()
        let closed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        XCTAssertEqual(XCTWaiter.wait(for: [closed], timeout: 4), .completed)
    }

    func testNativeFullscreenRoundTripRestoresResizableWindow() {
        let app = launchApp()
        let window = app.windows.firstMatch
        let original = window.frame
        let green = window.buttons[XCUIIdentifierFullScreenWindow]
        XCTAssertTrue(green.exists)
        requireFocus(app)
        green.click()
        let entered = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            app.menuItems["Exit Full Screen"].exists
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [entered], timeout: 5), .completed)
        requireFocus(app)
        // Use the system shortcut to exit without clicking behind the voice overlay.
        app.typeKey("f", modifierFlags: [.control, .command])
        let restored = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            window.exists && abs(window.frame.width - original.width) < 2 && abs(window.frame.height - original.height) < 2
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [restored], timeout: 5), .completed)
        requireFocus(app)
        let edge = window.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5)).withOffset(CGVector(dx: -1, dy: 0))
        edge.press(forDuration: 0.2, thenDragTo: edge.withOffset(CGVector(dx: -100, dy: 0)))
        requireFocus(app)
        XCTAssertLessThan(window.frame.width, original.width - 50)
        let bottom = window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1)).withOffset(CGVector(dx: 0, dy: -1))
        bottom.press(forDuration: 0.2, thenDragTo: bottom.withOffset(CGVector(dx: 0, dy: -100)))
        requireFocus(app)
        XCTAssertLessThan(window.frame.height, original.height - 50)
        window.buttons[XCUIIdentifierCloseWindow].click()
        let closed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: window)
        XCTAssertEqual(XCTWaiter.wait(for: [closed], timeout: 4), .completed)
    }

    func testScrollExtremesWithErrorsInShortWindow() { checkScrollExtremes(height: 700, problems: true) }
    func testScrollExtremesWithErrorsInNormalWindow() { checkScrollExtremes(height: 900, problems: true) }
    func testScrollExtremesWithoutErrors() { checkScrollExtremes(height: 900, problems: false) }

    private func checkScrollExtremes(height: Int, problems: Bool) {
        let app = launchApp(height: height, problems: problems)
        let scroll = app.scrollViews["main-scroll"]
        let top = waitForElement(app, id: "top-bar")
        let keyboard = waitForElement(app, id: "keyboard-panel")
        func capture(_ name: String) {
            let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
            attachment.name = "\(height)-\(problems)-\(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        requireFocus(app)
        scroll.swipeDown()
        scroll.swipeDown()
        capture("top")
        XCTAssertGreaterThanOrEqual(top.frame.minY, scroll.frame.minY - 1, "Top bar is outside the scrollable document")
        XCTAssertTrue(waitForElement(app, id: UIID.restartLevel).isHittable)
        requireFocus(app)
        scroll.swipeUp()
        scroll.swipeUp()
        capture("bottom")
        XCTAssertLessThanOrEqual(keyboard.frame.maxY, scroll.frame.maxY + 1, "Keyboard bottom is outside the scrollable document")
        XCTAssertGreaterThan(keyboard.frame.minY, scroll.frame.minY)
        XCTAssertTrue(keyboard.staticTexts["SPACE"].firstMatch.isHittable)
        XCTAssertTrue(waitForElement(app, id: UIID.handCalibrate).isHittable)
    }

    func testAppLaunchShowsCalibrate() {
        let app = launchApp()
        defer { app.terminate() }
        let calibrate = waitForElement(app, id: UIID.handCalibrate)
        XCTAssertTrue(calibrate.exists)
        XCTAssertEqual(elementText(waitForElement(app, id: "hand-alignment-mode")), "Auto-aligned finger guide")
        XCTAssertFalse(app.buttons[UIID.handZoomPlus].exists, "Adjustment should not be required on launch")
        let screenshot = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        screenshot.name = "Automatic finger guide on first launch"
        screenshot.lifetime = .keepAlways
        add(screenshot)
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
        XCTAssertEqual(after, "90%")
        XCTAssertEqual(before, "88%")
    }

    func testZoomMinusChangesValue() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let zoomValue = waitForElement(app, id: UIID.handZoomValue)
        let before = elementText(zoomValue)
        waitForElement(app, id: UIID.handZoomMinus).click()
        let after = elementText(zoomValue)
        XCTAssertEqual(after, "86%")
        XCTAssertEqual(before, "88%")
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
        XCTAssertEqual(resetValue, original)
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

    func testOffCenterClickDoesNotMoveCalibrationPoint() {
        let app = launchApp()
        defer { app.terminate() }
        waitForElement(app, id: UIID.handCalibrate).click()
        let point = waitForElement(app, id: UIID.handPointLeftIndex)
        let before = elementText(point)
        point.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5)).click()
        XCTAssertEqual(elementText(point), before)
    }

    func testCalibrationToggleKeepsImageAndPointCenters() {
        let app = launchApp()
        let point = waitForElement(app, id: UIID.handPoint("leftPinky"))
        let before = point.frame
        let value = elementText(point)
        waitForElement(app, id: UIID.handCalibrate).click()
        let during = point.frame
        XCTAssertEqual(during.midX, before.midX, accuracy: 1)
        XCTAssertEqual(during.midY, before.midY, accuracy: 1)
        XCTAssertEqual(elementText(point), value)
        let screenshot = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        screenshot.name = "Calibration controls with stable viewport"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        waitForElement(app, id: UIID.handCalibrate).click()
        XCTAssertEqual(point.frame.midY, before.midY, accuracy: 1)
    }

    func testCalibrationPersistsAcrossRelaunch() {
        let app = launchApp()
        waitForElement(app, id: UIID.handCalibrate).click()
        let point = waitForElement(app, id: UIID.handPointLeftIndex)
        let other = waitForElement(app, id: UIID.handPoint("rightIndex"))
        let original = elementText(point)
        let otherOriginal = elementText(other)
        requireFocus(app)
        let start = point.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.2, thenDragTo: start.withOffset(CGVector(dx: 25, dy: 10)))
        let moved = elementText(point)
        XCTAssertNotEqual(moved, original)
        XCTAssertEqual(elementText(other), otherOriginal)
        waitForElement(app, id: UIID.handZoomPlus).click()
        app.terminate()
        let reloaded = launchApp(reset: false)
        waitForElement(reloaded, id: UIID.handCalibrate).click()
        XCTAssertEqual(elementText(waitForElement(reloaded, id: UIID.handPointLeftIndex)), moved)
        XCTAssertEqual(elementText(waitForElement(reloaded, id: UIID.handZoomValue)), "90%")
    }

    func testCalibrationSurvivesWindowResize() {
        let app = launchApp()
        waitForElement(app, id: UIID.handCalibrate).click()
        let point = waitForElement(app, id: UIID.handPointLeftIndex)
        let value = elementText(point)
        let before = point.frame
        let window = app.windows.firstMatch
        let width = window.frame.width
        XCTAssertGreaterThan(width, 1250, "Screen must accommodate an isolated 1300-point test window")
        requireFocus(app)
        let edge = window.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5)).withOffset(CGVector(dx: -1, dy: 0))
        edge.press(forDuration: 0.2, thenDragTo: edge.withOffset(CGVector(dx: -100, dy: 0)))
        requireFocus(app)
        XCTAssertLessThan(window.frame.width, width - 50, "Native window resize did not occur")
        XCTAssertEqual(elementText(point), value)
        XCTAssertNotEqual(point.frame.midX, before.midX)
        let resized = point.frame
        waitForElement(app, id: UIID.handCalibrate).click()
        waitForElement(app, id: UIID.handCalibrate).click()
        XCTAssertEqual(point.frame.midX, resized.midX, accuracy: 1)
        XCTAssertEqual(point.frame.midY, resized.midY, accuracy: 1)
        let screenshot = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        screenshot.name = "Calibration after native window resize"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testShortWindowKeepsTopBarVisibleAndKeyboardReachable() {
        let app = launchApp()
        let window = app.windows.firstMatch
        let restart = waitForElement(app, id: UIID.restartLevel)
        XCTAssertGreaterThan(restart.frame.minY, window.frame.minY + 24)
        let scroll = app.scrollViews["main-scroll"]
        XCTAssertTrue(scroll.exists)
        requireFocus(app)
        scroll.swipeUp()
        requireFocus(app)
        let space = app.staticTexts["SPACE"].firstMatch
        XCTAssertTrue(space.exists)
        XCTAssertLessThan(space.frame.maxY, window.frame.maxY)
        XCTAssertGreaterThan(space.frame.minY, window.frame.minY + 24)
        let screenshot = XCTAttachment(screenshot: window.screenshot())
        screenshot.name = "Keyboard reached by scrolling a short window"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }

    func testSummaryDoesNotShowPendingPill() {
        let app = launchApp()
        defer { app.terminate() }
        let pending = app.descendants(matching: .any).matching(identifier: UIID.summaryPendingValue).firstMatch
        XCTAssertFalse(pending.exists)
    }

    func testTypingUpdatesCorrectOrWrong() {
        let app = launchApp()
        defer { app.terminate() }
        let correct = waitForElement(app, id: UIID.summaryCorrectValue)
        let wrong = waitForElement(app, id: UIID.summaryWrongValue)
        let before = (Int(elementText(correct)) ?? 0) + (Int(elementText(wrong)) ?? 0)
        typeFixture(app, text: "a")
        let after = (Int(elementText(correct)) ?? 0) + (Int(elementText(wrong)) ?? 0)
        XCTAssertEqual(after, before + 1)
    }

    func testRestartResetsSummary() {
        let app = launchApp()
        defer { app.terminate() }
        let correct = waitForElement(app, id: UIID.summaryCorrectValue)
        let wrong = waitForElement(app, id: UIID.summaryWrongValue)
        let uncorrected = waitForElement(app, id: UIID.summaryUncorrectedValue)
        let corrected = waitForElement(app, id: UIID.summaryCorrectedValue)
        let initial = (
            Int(elementText(correct)) ?? 0,
            Int(elementText(wrong)) ?? 0,
            Int(elementText(uncorrected)) ?? 0,
            Int(elementText(corrected)) ?? 0
        )
        typeFixture(app, text: "a")
        waitForElement(app, id: UIID.restartLevel).click()
        let reset = (
            Int(elementText(correct)) ?? 0,
            Int(elementText(wrong)) ?? 0,
            Int(elementText(uncorrected)) ?? 0,
            Int(elementText(corrected)) ?? 0
        )
        XCTAssertEqual(reset.0, initial.0)
        XCTAssertEqual(reset.1, initial.1)
        XCTAssertEqual(reset.2, initial.2)
        XCTAssertEqual(reset.3, initial.3)
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

    func testCompletionHintAppearsAfterLevelCompletionWhenNextUnlockedExists() {
        let app = launchApp()
        defer { app.terminate() }

        let hint = app.descendants(matching: .any).matching(identifier: UIID.summaryCompletionHint).firstMatch
        XCTAssertFalse(hint.exists)

        typeFixture(app, text: fixture)

        XCTAssertTrue(hint.waitForExistence(timeout: 8))
        XCTAssertEqual(elementText(hint), "Press Enter for next level")
        XCTAssertEqual(elementText(waitForElement(app, id: UIID.summaryCorrectValue)), "9")
        requireFocus(app)
        app.typeKey(.return, modifierFlags: [])
        XCTAssertTrue(elementText(waitForElement(app, id: UIID.selectedLevelName)).contains("Left pinky"))
    }

    func testElementExists_01() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.summaryCorrectValue)
        XCTAssertTrue(element.exists)
        XCTAssertEqual(elementText(element), "0")
    }

    func testElementExists_02() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.summaryWrongValue)
        XCTAssertTrue(element.exists)
        XCTAssertEqual(elementText(element), "0")
    }

    func testElementExists_03() {
        let app = launchApp()
        defer { app.terminate() }
        let element = waitForElement(app, id: UIID.summaryUncorrectedValue)
        XCTAssertTrue(element.exists)
        XCTAssertEqual(elementText(element), "0")
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

    func testCompletionPopupAppearsAfterFinishingLevel() {
        let app = launchApp()
        defer { app.terminate() }
        let popup = app.descendants(matching: .any).matching(identifier: UIID.completionPopup).firstMatch
        XCTAssertFalse(popup.exists)
        typeFixture(app, text: fixture)
        XCTAssertTrue(popup.waitForExistence(timeout: 8))
        XCTAssertEqual(elementText(waitForElement(app, id: UIID.summaryCorrectValue)), "9")
        XCTAssertEqual(elementText(waitForElement(app, id: UIID.completionPopupStars)), "3")
    }

}
