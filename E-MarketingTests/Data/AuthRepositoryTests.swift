//
//  AuthRepositoryTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class AuthRepositoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
    }

    override func tearDown() {
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testLoginSavesAccessTokenAndDoesNotSendBearer() async throws {
        MockURLProtocol.handler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            return MockHTTP.response(url: request.url!, status: 200, json: LoginResponse.loginJSON)
        }

        let keychain = InMemoryKeychainStore()
        let client = APIClient(
            interceptor: AuthRequestInterceptor(keychain: keychain),
            session: MockHTTP.session(),
            onUnauthorized: {}
        )
        let sut = AuthRepository(apiClient: client, keychain: keychain)

        try await sut.login(username: "emilys", password: "emilyspass")

        XCTAssertEqual(try sut.getAccessToken(), "access-token")
        XCTAssertNil(try keychain.get(forKey: "refreshToken"))
    }

    func testLogoutDeletesToken() throws {
        let keychain = InMemoryKeychainStore()
        try keychain.save("access-token", forKey: AuthStorageKey.accessToken)
        let client = APIClient(
            interceptor: AuthRequestInterceptor(keychain: keychain),
            session: MockHTTP.session(),
            onUnauthorized: {}
        )
        let sut = AuthRepository(apiClient: client, keychain: keychain)

        try sut.logout()

        XCTAssertNil(try sut.getAccessToken())
    }
}
