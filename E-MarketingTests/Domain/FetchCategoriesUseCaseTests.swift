//
//  FetchCategoriesUseCaseTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class FetchCategoriesUseCaseTests: XCTestCase {

    private var repository: MockCatalogRepository!
    private var sut: FetchCategoriesUseCase!

    override func setUp() {
        super.setUp()
        repository = MockCatalogRepository()
        sut = FetchCategoriesUseCase(repository: repository)
    }

    func testPreparesUniqueNamedHTTPCategoriesInNameOrder() async throws {
        repository.result = .success([
            ProductCategory(
                slug: "smartphones",
                name: "Smartphones",
                url: "https://dummyjson.com/products/category/smartphones"
            ),
            ProductCategory(
                slug: "  ",
                name: "Blank",
                url: "https://dummyjson.com/products/category/blank"
            ),
            ProductCategory(
                slug: "beauty",
                name: " Beauty ",
                url: " https://dummyjson.com/products/category/beauty "
            ),
            ProductCategory(
                slug: "beauty",
                name: "Other Beauty",
                url: "https://dummyjson.com/products/category/beauty"
            ),
            ProductCategory(slug: "broken", name: "Broken", url: "not a url"),
            ProductCategory(slug: "relative", name: "Relative", url: "foo")
        ])

        let categories = try await sut.execute()

        XCTAssertEqual(categories.map(\.slug), ["beauty", "smartphones"])
        XCTAssertEqual(categories.map(\.name), ["Beauty", "Smartphones"])
        XCTAssertEqual(repository.callCount, 1)
    }
}
