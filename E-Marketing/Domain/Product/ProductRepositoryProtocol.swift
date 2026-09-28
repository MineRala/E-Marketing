//
//  ProductRepositoryProtocol.swift
//  E-Marketing
//

import Foundation

protocol ProductRepositoryProtocol: Sendable {
    func fetchProducts(limit: Int, skip: Int) async throws -> ProductPage
}
