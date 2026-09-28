//
//  MockProductRepository.swift
//  E-MarketingTests
//

import Foundation
@testable import E_Marketing

final class MockProductRepository: ProductRepositoryProtocol, @unchecked Sendable {

    var pages: [ProductPage] = []
    var error: Error?
    var calls: [(limit: Int, skip: Int)] = []
    var onFetch: (() async throws -> ProductPage)?

    func fetchProducts(limit: Int, skip: Int) async throws -> ProductPage {
        calls.append((limit, skip))
        if let onFetch {
            return try await onFetch()
        }
        if let error {
            throw error
        }
        let index = calls.count - 1
        guard pages.indices.contains(index) else {
            return ProductPage(products: [], total: 0, skip: skip, limit: limit)
        }
        return pages[index]
    }
}
