//
//  AuthRequestInterceptor.swift
//  E-Marketing
//

import Foundation

protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest) throws -> URLRequest
}

/// Attaches `Authorization: Bearer` from Keychain. Never logs the token.
final class AuthRequestInterceptor: RequestInterceptor, @unchecked Sendable {

    private let keychain: KeychainServiceProtocol

    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }

    func adapt(_ request: URLRequest) throws -> URLRequest {
        var request = request

        guard request.value(forHTTPHeaderField: "Authorization") == nil else {
            return request
        }

        guard let token = try keychain.get(forKey: AuthStorageKey.accessToken),
              !token.isEmpty else {
            return request
        }

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
}
