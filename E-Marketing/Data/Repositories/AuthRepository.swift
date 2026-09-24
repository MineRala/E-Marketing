//
//  AuthRepository.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

final class AuthRepository: AuthRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let keychain: KeychainServiceProtocol

    init(apiClient: APIClientProtocol, keychain: KeychainServiceProtocol) {
        self.apiClient = apiClient
        self.keychain = keychain
    }

    func login(username: String, password: String) async throws -> LoginResponse {

        let url = URL(
            string:
                "https://dummyjson.com/auth/login"
        )!

        var request =
            URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        let body = LoginRequest(
            username: username,
            password: password
        )

        request.httpBody =
            try JSONEncoder().encode(body)

        let response: LoginResponse =
            try await apiClient.request(
                request,
                authenticated: false
            )

        try keychain.save(
            response.accessToken,
            forKey: AuthStorageKey.accessToken
        )

        return response
    }

    func getAccessToken() throws -> String? {

        try keychain.get(
            forKey: AuthStorageKey.accessToken
        )
    }

    func logout() throws {

        try keychain.delete(
            forKey: AuthStorageKey.accessToken
        )
    }
}
