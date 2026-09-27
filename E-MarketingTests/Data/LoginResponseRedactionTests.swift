//
//  LoginResponseRedactionTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class LoginResponseRedactionTests: XCTestCase {

    func testDescriptionDoesNotContainTokens() {
        let response = LoginResponse.fixture()

        XCTAssertFalse(response.description.contains("access-token"))
        XCTAssertFalse(response.debugDescription.contains("refresh-token"))
        XCTAssertFalse("\(response)".contains("access-token"))
    }

    func testDecodesLegacyTokenField() throws {
        let json = """
        {
          "id": 1,
          "username": "emilys",
          "email": "emily@example.com",
          "firstName": "Emily",
          "lastName": "Smith",
          "token": "legacy-token"
        }
        """
        let decoded = try JSONDecoder().decode(LoginResponse.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.accessToken, "legacy-token")
        XCTAssertFalse(decoded.description.contains("legacy-token"))
    }
}
