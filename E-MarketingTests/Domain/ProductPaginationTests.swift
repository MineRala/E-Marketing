//
//  ProductPaginationTests.swift
//  E-MarketingTests
//

import XCTest
@testable import E_Marketing

final class ProductPaginationTests: XCTestCase {

    private let pagination = ProductPagination(pageSize: 2)

    func testFirstPageStartsAtSkipZero() {
        XCTAssertEqual(pagination.firstPageRequest(), ProductPagination.Request(limit: 2, skip: 0))
    }

    func testFirstPageHasMoreWhileCountIsBelowTotal() {
        let page = pagination.applyingFirstPage(makePage(ids: [1, 2], total: 4))

        XCTAssertEqual(page.products.map(\.id), [1, 2])
        XCTAssertTrue(page.hasMore)
    }

    func testFirstPageStopsWhenCountReachesTotal() {
        let page = pagination.applyingFirstPage(makePage(ids: [1, 2], total: 2))

        XCTAssertFalse(page.hasMore)
    }

    func testNextPageSkipsLoadedCountAndDropsDuplicateIDs() {
        let existing = [product(1), product(2)]

        XCTAssertEqual(
            pagination.nextPageRequest(loadedCount: existing.count),
            ProductPagination.Request(limit: 2, skip: 2)
        )

        let page = pagination.applyingNextPage(
            makePage(ids: [2, 3], total: 4),
            to: existing
        )

        XCTAssertEqual(page.products.map(\.id), [1, 2, 3])
        XCTAssertTrue(page.hasMore)
    }

    func testNextPageStopsWhenIncomingProductsAreAlreadyLoaded() {
        let page = pagination.applyingNextPage(
            makePage(ids: [1], total: 4),
            to: [product(1)]
        )

        XCTAssertEqual(page.products.map(\.id), [1])
        XCTAssertFalse(page.hasMore)
    }

    func testNextPageRequestIsNilBeforeTheFirstPage() {
        XCTAssertNil(pagination.nextPageRequest(loadedCount: 0))
    }

    private func makePage(ids: [Int], total: Int) -> ProductPage {
        ProductPage(
            products: ids.map(product),
            total: total,
            skip: 0,
            limit: ids.count
        )
    }

    private func product(_ id: Int) -> Product {
        Product(id: id, title: "Item \(id)", price: 1, thumbnail: "", category: "beauty")
    }
}
