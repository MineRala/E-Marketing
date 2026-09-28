//
//  FetchCategoriesUseCase.swift
//  E-Marketing
//

import Foundation

protocol FetchCategoriesUseCaseProtocol: Sendable {
    func execute() async throws -> [ProductCategory]
}

struct FetchCategoriesUseCase: FetchCategoriesUseCaseProtocol {
    private let repository: CatalogRepositoryProtocol

    init(repository: CatalogRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ProductCategory] {
        let categories = try await repository.fetchCategories()
        return Catalog.prepare(categories)
    }
}
