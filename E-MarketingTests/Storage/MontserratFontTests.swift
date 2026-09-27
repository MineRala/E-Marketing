//
//  MontserratFontTests.swift
//  E-MarketingTests
//

import UIKit
import XCTest
@testable import E_Marketing

final class MontserratFontTests: XCTestCase {

    func testMontserratWeightsAreRegistered() {
        for font in [AppFont.regular, .medium, .semiBold, .bold] {
            XCTAssertNotNil(UIFont(name: font.rawValue, size: 16), font.rawValue)
        }
    }
}
