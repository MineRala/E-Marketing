//
//  AuthRepository.swift
//  E-Marketing
//

import Foundation

final class AuthRepository: AuthRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol
    private let keychain: KeychainServiceProtocol

    init(apiClient: any APIClientProtocol, keychain: KeychainServiceProtocol) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func login(username: String, password: String) async throws {
        var request = URLRequest(url: APIEndpoint.login)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            LoginRequest(username: username, password: password)
        )

        let response: LoginResponse = try await apiClient.request(
            request,
            authenticated: false
        )

        try keychain.save(response.accessToken, forKey: AuthStorageKey.accessToken)
    }

    func getAccessToken() throws -> String? {
        try keychain.get(forKey: AuthStorageKey.accessToken)
    }

    func logout() throws {
        try keychain.delete(forKey: AuthStorageKey.accessToken)
    }
}
