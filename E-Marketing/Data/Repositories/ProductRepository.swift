//
//  ProductRepository.swift
//  E-Marketing
//

import Foundation

final class ProductRepository: ProductRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts(limit: Int, skip: Int) async throws -> ProductPage {
        guard var components = URLComponents(
            url: APIEndpoint.products,
            resolvingAgainstBaseURL: false
        ) else {
            throw AppError.invalidResponse
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "skip", value: String(skip))
        ]

        guard let url = components.url else {
            throw AppError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let response: ProductPageDTO = try await apiClient.request(request)
        return response.page
    }
}
