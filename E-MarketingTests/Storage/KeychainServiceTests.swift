//
//  KeychainServiceTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class KeychainServiceTests: XCTestCase {

    private var sut: KeychainService!
    private var key: String!

    override func setUp() {
        super.setUp()
        sut = KeychainService()
        key = "test.token.\(UUID().uuidString)"
    }

    override func tearDown() {
        if let key {
            try? sut?.delete(forKey: key)
        }
        super.tearDown()
    }

    func testSaveReplacesExistingValue() throws {
        try sut.save("first-token", forKey: key)
        try sut.save("second-token", forKey: key)

        XCTAssertEqual(try sut.get(forKey: key), "second-token")
    }
}
