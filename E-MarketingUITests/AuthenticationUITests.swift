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
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
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
        XCTAssertTrue(app.staticTexts["home.root"].exists)
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

    func testFailedLoginShowsErrorToast() {
        let username = app.textFields["auth.username"]
        let password = app.secureTextFields["auth.password"]

        XCTAssertTrue(username.waitForExistence(timeout: 5))
        username.tap()
        username.typeText("emilys")
        password.tap()
        password.typeText("wrong")
        app.buttons["auth.login"].tap()

        XCTAssertTrue(
            app.staticTexts["Incorrect username or password."].waitForExistence(timeout: 5)
        )
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

        let confirm = app.buttons["home.logout.confirm"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        XCTAssertTrue(app.buttons["auth.login"].waitForExistence(timeout: 5))
    }

    func testLoginHomeThenProductList() {
        let username = app.textFields["auth.username"]
        let password = app.secureTextFields["auth.password"]

        XCTAssertTrue(username.waitForExistence(timeout: 5))
        username.tap()
        username.typeText("emilys")
        password.tap()
        password.typeText("emilyspass")
        app.buttons["auth.login"].tap()

        XCTAssertTrue(app.buttons["home.logout"].waitForExistence(timeout: 5))

        let productsTab = app.tabBars.buttons["Products"]
        XCTAssertTrue(productsTab.waitForExistence(timeout: 5))
        productsTab.tap()

        XCTAssertTrue(app.staticTexts["Essence Mascara"].waitForExistence(timeout: 5))
    }
}
