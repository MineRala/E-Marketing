//
//  AccessTokenExpiryTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class AccessTokenExpiryTests: XCTestCase {

    func testExpiredClaimIsExpired() {
        let token = JWTFixture.token(exp: 1)
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertTrue(AccessTokenExpiry.isExpired(token, at: now))
    }

    func testFutureClaimIsNotExpired() {
        let token = JWTFixture.token(exp: 1_800_000_000)
        let now = Date(timeIntervalSince1970: 1_700_000_000)

        XCTAssertFalse(AccessTokenExpiry.isExpired(token, at: now))
    }

    func testOpaqueTokenWithoutExpiryIsNotExpired() {
        XCTAssertFalse(AccessTokenExpiry.isExpired("stored-token", at: Date()))
    }
}
