//
//  HomeUITests.swift
//  E-MarketingUITests
//

import XCTest

final class HomeUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = UITestSession.launch()
        UITestSession.login(app)
    }

    func testHomeShowsCampaignAndCategories() {
        XCTAssertTrue(app.staticTexts["home.root"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Summer Sale"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Beauty"].exists)
        XCTAssertTrue(app.staticTexts["Smartphones"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["home.category.beauty"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["home.category.smartphones"].exists)
    }

    func testCategoryCardDoesNotLeaveHome() {
        let beauty = app.staticTexts["Beauty"]
        XCTAssertTrue(beauty.waitForExistence(timeout: 5))
        beauty.tap()

        XCTAssertTrue(app.buttons["home.logout"].exists)
        XCTAssertTrue(app.staticTexts["home.root"].exists)
        XCTAssertFalse(app.buttons["auth.login"].exists)
        XCTAssertFalse(app.staticTexts["Essence Mascara"].exists)
    }

    func testLogoutCancelStaysOnHome() {
        app.buttons["home.logout"].tap()

        let cancel = app.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        cancel.tap()

        XCTAssertTrue(app.buttons["home.logout"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["auth.login"].exists)
    }
}
