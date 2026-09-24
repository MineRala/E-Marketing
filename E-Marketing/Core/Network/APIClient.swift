//
//  APIClient.swift
//  E-Marketing
//
//  Created by Mine Rala on 22.09.2026.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(
        _ request: URLRequest,
        authenticated: Bool
    ) async throws -> T
}

extension APIClientProtocol {
    func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        try await self.request(request, authenticated: true)
    }
}

final class APIClient: APIClientProtocol {

    private let interceptor: RequestInterceptor

    init(interceptor: RequestInterceptor) {
        self.interceptor = interceptor
    }

    func request<T: Decodable>(
        _ request: URLRequest,
        authenticated: Bool
    ) async throws -> T {

        let outgoingRequest: URLRequest
        if authenticated {
            outgoingRequest = try interceptor.adapt(request)
        } else {
            outgoingRequest = request
        }

        do {
            let (data, response) =
                try await URLSession.shared.data(
                    for: outgoingRequest
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
