//
//  APIClient.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ request: URLRequest ) async throws -> T
}

final class APIClient: APIClientProtocol {

    private let keychain: KeychainServiceProtocol

    private let tokenKey = "accessToken"

    init(
        keychain: KeychainServiceProtocol
    ) {
        self.keychain = keychain
    }

    func request<T: Decodable>(
        _ request: URLRequest
    ) async throws -> T {

        var authenticatedRequest = request

        if let token = try keychain.get(
            forKey: tokenKey
        ),
        !token.isEmpty {

            authenticatedRequest.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        do {
            let (data, response) =
                try await URLSession.shared.data(
                    for: authenticatedRequest
                )

            guard let httpResponse =
                    response as? HTTPURLResponse
            else {
                throw AppError.invalidResponse
            }

            switch httpResponse.statusCode {

            case 200...299:
                break

            case 401, 403:
                throw AppError.invalidCredentials

            default:
                throw AppError.invalidResponse
            }

            do {
                return try JSONDecoder().decode(
                    T.self,
                    from: data
                )
            } catch {
                throw AppError.decoding
            }

        } catch let error as AppError {
            throw error

        } catch {
            throw AppError.network
        }
    }
}
