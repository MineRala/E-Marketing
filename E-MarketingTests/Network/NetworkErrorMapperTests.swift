//
//  NetworkErrorMapperTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class NetworkErrorMapperTests: XCTestCase {

    func testLoginFailureCodesMapToInvalidCredentials() {
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 400, authenticated: false), .invalidCredentials)
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 401, authenticated: false), .invalidCredentials)
    }

    func testProtected401MapsToUnauthorized() {
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 401, authenticated: true), .unauthorized)
    }

    func testHTTPStatusMap() {
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 403, authenticated: true), .forbidden)
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 404, authenticated: true), .notFound)
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 429, authenticated: true), .rateLimited)
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 500, authenticated: true), .server)
        XCTAssertEqual(NetworkErrorMapper.map(statusCode: 503, authenticated: true), .server)
    }

    func testURLErrorMap() {
        XCTAssertEqual(NetworkErrorMapper.map(URLError(.timedOut)), .timeout)
        XCTAssertEqual(NetworkErrorMapper.map(URLError(.notConnectedToInternet)), .network)
        XCTAssertEqual(NetworkErrorMapper.map(URLError(.networkConnectionLost)), .network)
    }
}
