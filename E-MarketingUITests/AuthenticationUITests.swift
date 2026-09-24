//
//  AuthenticationUITests.swift
//  E-MarketingUITests
//

import XCTest

final class AuthenticationUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
    }

    func testSuccessfulLoginNavigatesToHome() {
        let username = app.textFields["auth.username"]
        let password = app.secureTextFields["auth.password"]
        let login = app.buttons["auth.login"]

        XCTAssertTrue(username.waitForExistence(timeout: 5))
        username.tap()
        username.typeText("emilys")
        password.tap()
        password.typeText("emilyspass")
        login.tap()

        XCTAssertTrue(app.buttons["home.logout"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Home"].exists)
    }

    func testFailedLoginStaysOnAuthentication() {
        let username = app.textFields["auth.username"]
        let password = app.secureTextFields["auth.password"]

        XCTAssertTrue(username.waitForExistence(timeout: 5))
        username.tap()
        username.typeText("emilys")
        password.tap()
        password.typeText("wrong")
        app.buttons["auth.login"].tap()

        XCTAssertTrue(app.buttons["auth.login"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["home.logout"].exists)
    }

    func testLogoutReturnsToAuthentication() {
        let username = app.textFields["auth.username"]
        let password = app.secureTextFields["auth.password"]

        XCTAssertTrue(username.waitForExistence(timeout: 5))
        username.tap()
        username.typeText("emilys")
        password.tap()
        password.typeText("emilyspass")
        app.buttons["auth.login"].tap()

        let logout = app.buttons["home.logout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 5))
        logout.tap()

        XCTAssertTrue(app.buttons["auth.login"].waitForExistence(timeout: 5))
    }
}
