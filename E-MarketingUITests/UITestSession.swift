//
//  UITestSession.swift
//  E-MarketingUITests
//

import XCTest

enum UITestSession {
    static func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        return app
    }

    static func login(_ app: XCUIApplication) {
        let username = app.textFields["auth.username"]
        XCTAssertTrue(username.waitForExistence(timeout: 8))
        username.tap()
        username.typeText("emilys")
        app.secureTextFields["auth.password"].tap()
        app.secureTextFields["auth.password"].typeText("emilyspass")
        app.buttons["auth.login"].tap()
        XCTAssertTrue(app.buttons["home.logout"].waitForExistence(timeout: 15))
    }
}
