//
//  UITestingAuthRepository.swift
//  E-Marketing
//

import Foundation

/// Deterministic auth used only when the process is launched with `--ui-testing`.
final class UITestingAuthRepository: AuthRepositoryProtocol, Sendable {

    private let keychain: KeychainServiceProtocol

    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }

    func login(username: String, password: String) async throws {
        if username == "emilys", password == "emilyspass" {
            try keychain.save("ui-test-token", forKey: AuthStorageKey.accessToken)
            return
        }
        throw AppError.invalidCredentials
    }

    func getAccessToken() throws -> String? {
        try keychain.get(forKey: AuthStorageKey.accessToken)
    }

    func logout() throws {
        try keychain.delete(forKey: AuthStorageKey.accessToken)
    }
}
