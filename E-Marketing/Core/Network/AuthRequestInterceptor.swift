//
//  AuthRequestInterceptor.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

protocol RequestInterceptor {
    func adapt(_ request: URLRequest) throws -> URLRequest
}

/// Adds `Authorization: Bearer` from Keychain. Token is never logged.
final class AuthRequestInterceptor: RequestInterceptor {

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
