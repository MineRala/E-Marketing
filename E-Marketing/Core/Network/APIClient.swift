//
//  APIClient.swift
//  E-Marketing
//

import Foundation

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ urlRequest: URLRequest, authenticated: Bool) async throws -> T
}

extension APIClientProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        try await self.request(urlRequest, authenticated: true)
    }
}

final class APIClient: APIClientProtocol, Sendable {

    private let interceptor: any RequestInterceptor
    private let session: any HTTPDataLoading
    private let onUnauthorized: @Sendable () async -> Void

    init(interceptor: any RequestInterceptor, session: any HTTPDataLoading, onUnauthorized: @escaping @Sendable () async -> Void) {
        self.interceptor = interceptor
        self.session = session
        self.onUnauthorized = onUnauthorized
    }

    func request<T: Decodable>(_ urlRequest: URLRequest, authenticated: Bool) async throws -> T {
        try Task.checkCancellation()

        let outgoingRequest: URLRequest
        if authenticated {
            do {
                outgoingRequest = try interceptor.adapt(urlRequest)
            } catch let error as AppError where error == .unauthorized {
                await onUnauthorized()
                throw error
            }
        } else {
            outgoingRequest = urlRequest
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: outgoingRequest)
        } catch is CancellationError {
            throw CancellationError()
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw CancellationError()
        } catch {
            throw NetworkErrorMapper.map(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let mapped = NetworkErrorMapper.map(
                statusCode: httpResponse.statusCode,
                authenticated: authenticated
            )

            if mapped == .unauthorized {
                await onUnauthorized()
            }

            throw mapped
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw AppError.decoding
        }
    }
}
