//
//  CatalogRepositoryProtocol.swift
//  E-Marketing
//

import Foundation

protocol CatalogRepositoryProtocol: Sendable {
    func fetchCategories() async throws -> [ProductCategory]
}
