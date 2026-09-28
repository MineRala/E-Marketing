//
//  ProductListUITests.swift
//  E-MarketingUITests
//

import XCTest

final class ProductListUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = UITestSession.launch()
        UITestSession.login(app)
        openProducts()
    }

    func testProductListShowsFixtureProduct() {
        XCTAssertTrue(app.descendants(matching: .any)["products.root"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Essence Mascara"].exists)

        let price = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '9.99'")).firstMatch
        XCTAssertTrue(price.waitForExistence(timeout: 5))
    }

    func testSwitchingTabsKeepsTheLoadedProduct() {
        XCTAssertTrue(app.staticTexts["Essence Mascara"].waitForExistence(timeout: 5))

        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["home.root"].waitForExistence(timeout: 5))

        openProducts()
        XCTAssertTrue(app.staticTexts["Essence Mascara"].waitForExistence(timeout: 5))
    }

    private func openProducts() {
        let productsTab = app.tabBars.buttons["Products"]
        XCTAssertTrue(productsTab.waitForExistence(timeout: 5))
        productsTab.tap()
    }
}
