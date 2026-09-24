//
//  AuthRequestInterceptorTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class AuthRequestInterceptorTests: XCTestCase {

    func testAddsBearerHeaderFromKeychain() throws {
        let keychain = InMemoryKeychainStore()
        try keychain.save("secret-token", forKey: AuthStorageKey.accessToken)
        let interceptor = AuthRequestInterceptor(keychain: keychain)

        let adapted = try interceptor.adapt(URLRequest(url: APIEndpoint.products))

        XCTAssertEqual(adapted.value(forHTTPHeaderField: "Authorization"), "Bearer secret-token")
    }

    func testDoesNotOverrideExistingAuthorization() throws {
        let keychain = InMemoryKeychainStore()
        try keychain.save("secret-token", forKey: AuthStorageKey.accessToken)
        let interceptor = AuthRequestInterceptor(keychain: keychain)

        var request = URLRequest(url: APIEndpoint.products)
        request.setValue("Bearer custom", forHTTPHeaderField: "Authorization")

        let adapted = try interceptor.adapt(request)

        XCTAssertEqual(adapted.value(forHTTPHeaderField: "Authorization"), "Bearer custom")
    }

    func testLeavesRequestUntouchedWhenTokenMissing() throws {
        let interceptor = AuthRequestInterceptor(keychain: InMemoryKeychainStore())
        let adapted = try interceptor.adapt(URLRequest(url: APIEndpoint.products))
        XCTAssertNil(adapted.value(forHTTPHeaderField: "Authorization"))
    }
}
