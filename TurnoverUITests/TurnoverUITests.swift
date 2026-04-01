//
//  TurnoverUITests.swift
//  TurnoverUITests
//
//  Created by iamce on 3/31/26.
//

import XCTest

final class TurnoverUITests: XCTestCase {
    private var persistenceDirectory: URL!

    override func setUpWithError() throws {
        continueAfterFailure = false
        persistenceDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.removeItem(at: persistenceDirectory)
        try FileManager.default.createDirectory(at: persistenceDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let persistenceDirectory {
            try? FileManager.default.removeItem(at: persistenceDirectory)
        }
    }

    @MainActor
    func testExample() throws {
        let app = makeApp()
        app.launch()

        XCTAssertTrue(app.buttons["start-run-button"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSettingsPersistAcrossRelaunch() throws {
        let app = makeApp()
        app.launch()

        openSettingsTab(in: app)

        let distanceControl = app.segmentedControls["settings-distance-unit"]
        XCTAssertTrue(distanceControl.waitForExistence(timeout: 2))

        let milesButton = distanceControl.buttons["Miles"]
        XCTAssertTrue(milesButton.exists)
        milesButton.tap()
        XCTAssertTrue(milesButton.isSelected)

        app.terminate()
        app.launch()
        openSettingsTab(in: app)

        let relaunchedDistanceControl = app.segmentedControls["settings-distance-unit"]
        XCTAssertTrue(relaunchedDistanceControl.waitForExistence(timeout: 2))
        XCTAssertTrue(relaunchedDistanceControl.buttons["Miles"].isSelected)
    }

    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["TURNOVER_BASE_DIRECTORY"] = persistenceDirectory.path
        return app
    }

    private func openSettingsTab(in app: XCUIApplication) {
        let settingsTab = app.tabBars.buttons.element(boundBy: 3)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 2))
        settingsTab.tap()
    }
}
