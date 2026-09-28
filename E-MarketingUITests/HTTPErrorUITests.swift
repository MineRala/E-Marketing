//
//  HTTPErrorUITests.swift
//  E-MarketingUITests
//

import XCTest

final class HTTPErrorUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testUnauthorizedResponseReturnsToLogin() {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-status", "401",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()
        UITestSession.login(app)

        let productsTab = app.tabBars.buttons["Products"]
        XCTAssertTrue(productsTab.waitForExistence(timeout: 5))
        productsTab.tap()

        XCTAssertTrue(app.textFields["auth.username"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["home.logout"].exists)
    }

    func testForbiddenResponseShowsToast() {
        assertProductLoadShowsToast(
            status: "403",
            message: "You do not have permission for this action."
        )
    }

    func testNotFoundResponseShowsToast() {
        assertProductLoadShowsToast(
            status: "404",
            message: "The requested resource was not found."
        )
    }

    func testRateLimitedResponseShowsToast() {
        assertProductLoadShowsToast(
            status: "429",
            message: "Too many requests. Please try again later."
        )
    }

    func testServerErrorResponseShowsToast() {
        assertProductLoadShowsToast(
            status: "500",
            message: "A server error occurred. Please try again later."
        )
    }

    private func assertProductLoadShowsToast(status: String, message: String) {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-status", status,
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()
        UITestSession.login(app)

        let productsTab = app.tabBars.buttons["Products"]
        XCTAssertTrue(productsTab.waitForExistence(timeout: 5))
        productsTab.tap()

        XCTAssertTrue(app.staticTexts[message].waitForExistence(timeout: 8))
    }
}
