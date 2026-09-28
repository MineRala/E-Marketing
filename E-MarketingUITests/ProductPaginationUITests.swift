//
//  ProductPaginationUITests.swift
//  E-MarketingUITests
//

import XCTest

final class ProductPaginationUITests: XCTestCase {

    func testScrollingLoadsTheNextPage() {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-paged-products",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()
        UITestSession.login(app)

        let productsTab = app.tabBars.buttons["Products"]
        XCTAssertTrue(productsTab.waitForExistence(timeout: 5))
        productsTab.tap()

        XCTAssertTrue(app.staticTexts["Catalog Item 1"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Second Page Serum"].exists)

        let secondPage = app.staticTexts["Second Page Serum"]
        var swipes = 0
        while !secondPage.exists, swipes < 8 {
            app.swipeUp()
            swipes += 1
        }

        XCTAssertTrue(secondPage.waitForExistence(timeout: 5))
    }
}
