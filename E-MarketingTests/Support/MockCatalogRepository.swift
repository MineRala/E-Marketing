//
//  MockCatalogRepository.swift
//  E-MarketingTests
//

import Foundation
@testable import E_Marketing

final class MockCatalogRepository: CatalogRepositoryProtocol, @unchecked Sendable {

    var result: Result<[ProductCategory], Error> = .success([])
    var callCount = 0

    func fetchCategories() async throws -> [ProductCategory] {
        callCount += 1
        return try result.get()
    }
}
