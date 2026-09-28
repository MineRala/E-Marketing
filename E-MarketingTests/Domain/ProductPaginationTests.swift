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
        let page = pagination.applyingFirstPage(makePage(ids: [1, 2], total: 4), requestedSkip: 0)

        XCTAssertEqual(page.products.map(\.id), [1, 2])
        XCTAssertEqual(page.nextSkip, 2)
        XCTAssertTrue(page.hasMore)
    }

    func testFirstPageStopsWhenCountReachesTotal() {
        let page = pagination.applyingFirstPage(makePage(ids: [1, 2], total: 2), requestedSkip: 0)

        XCTAssertEqual(page.nextSkip, 2)
        XCTAssertFalse(page.hasMore)
    }

    func testNextPageSkipsServerOffsetAndDropsDuplicateIDs() {
        let existing = [product(1), product(2)]

        XCTAssertEqual(
            pagination.nextPageRequest(skip: 2),
            ProductPagination.Request(limit: 2, skip: 2)
        )

        let page = pagination.applyingNextPage(
            makePage(ids: [2, 3], total: 4),
            to: existing,
            requestedSkip: 2
        )

        XCTAssertEqual(page.products.map(\.id), [1, 2, 3])
        XCTAssertEqual(page.nextSkip, 4)
        XCTAssertFalse(page.hasMore)
    }

    func testDuplicateIDsDoNotPullTheNextSkipBackward() {
        let existing = [product(1), product(2), product(3)]

        let page = pagination.applyingNextPage(
            makePage(ids: [3, 5], total: 8, skip: 4),
            to: existing,
            requestedSkip: 4
        )

        XCTAssertEqual(page.products.map(\.id), [1, 2, 3, 5])
        XCTAssertEqual(page.nextSkip, 6)
        XCTAssertTrue(page.hasMore)
        XCTAssertEqual(
            pagination.nextPageRequest(skip: page.nextSkip),
            ProductPagination.Request(limit: 2, skip: 6)
        )
    }

    func testAllDuplicatePageAdvancesSkipWhileTotalRemains() {
        let page = pagination.applyingNextPage(
            makePage(ids: [1, 2], total: 6),
            to: [product(1), product(2)],
            requestedSkip: 2
        )

        XCTAssertEqual(page.products.map(\.id), [1, 2])
        XCTAssertEqual(page.nextSkip, 4)
        XCTAssertTrue(page.hasMore)
    }

    func testEmptyServerPageStops() {
        let page = pagination.applyingNextPage(
            makePage(ids: [], total: 6),
            to: [product(1), product(2)],
            requestedSkip: 2
        )

        XCTAssertEqual(page.products.map(\.id), [1, 2])
        XCTAssertEqual(page.nextSkip, 2)
        XCTAssertFalse(page.hasMore)
    }

    func testNextPageRequestIsNilBeforeTheFirstPage() {
        XCTAssertNil(pagination.nextPageRequest(skip: 0))
    }

    private func makePage(ids: [Int], total: Int, skip: Int = 0) -> ProductPage {
        ProductPage(
            products: ids.map(product),
            total: total,
            skip: skip,
            limit: ids.count
        )
    }

    private func product(_ id: Int) -> Product {
        Product(id: id, title: "Item \(id)", price: 1, thumbnail: "", category: "beauty")
    }
}
