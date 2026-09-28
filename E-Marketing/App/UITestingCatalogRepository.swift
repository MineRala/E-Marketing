//
//  UITestingCatalogRepository.swift
//  E-Marketing
//

import Foundation

final class UITestingCatalogRepository: CatalogRepositoryProtocol, Sendable {

    func fetchCategories() async throws -> [ProductCategory] {
        [
            ProductCategory(
                slug: "beauty",
                name: "Beauty",
                url: "https://dummyjson.com/products/category/beauty"
            ),
            ProductCategory(
                slug: "smartphones",
                name: "Smartphones",
                url: "https://dummyjson.com/products/category/smartphones"
            )
        ]
    }
}
