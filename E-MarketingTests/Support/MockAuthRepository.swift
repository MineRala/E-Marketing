//
//  MockAuthRepository.swift
//  E-MarketingTests
//

@testable import E_Marketing

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {

    var token: String?
    var loginHandler: () async throws -> Void = {}
    var loginCallCount = 0
    var logoutCallCount = 0
    var logoutError: Error?
    var lastUsername: String?
    var lastPassword: String?

    func login(username: String, password: String) async throws {
        loginCallCount += 1
        lastUsername = username
        lastPassword = password
        try await loginHandler()
        if token == nil {
            token = "stored-token"
        }
    }

    func getAccessToken() throws -> String? {
        token
    }

    func logout() throws {
        logoutCallCount += 1
        if let logoutError {
            throw logoutError
        }
        token = nil
    }
}
