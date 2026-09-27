//
//  CatalogRepository.swift
//  E-Marketing
//

import Foundation

final class CatalogRepository: CatalogRepositoryProtocol, Sendable {

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCategories() async throws -> [ProductCategory] {
        var request = URLRequest(url: APIEndpoint.categories)
        request.httpMethod = "GET"
        let response: [ProductCategoryDTO] = try await apiClient.request(request, authenticated: true)
        return response.map(\.category)
    }
}
