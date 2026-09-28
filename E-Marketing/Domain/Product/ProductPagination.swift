//
//  ProductPagination.swift
//  E-Marketing
//

import Foundation

struct ProductListPage: Equatable, Sendable {
    let products: [Product]
    let hasMore: Bool
    /// Server offset for the following request. Advances by the raw page length, including ids that were dropped as duplicates.
    let nextSkip: Int
}

struct ProductPagination: Sendable {
    let pageSize: Int

    struct Request: Equatable, Sendable {
        let limit: Int
        let skip: Int
    }

    func firstPageRequest() -> Request {
        Request(limit: pageSize, skip: 0)
    }

    func nextPageRequest(skip: Int) -> Request? {
        guard skip > 0 else { return nil }
        return Request(limit: pageSize, skip: skip)
    }

    func applyingFirstPage(_ page: ProductPage, requestedSkip: Int) -> ProductListPage {
        applying(page, to: [], requestedSkip: requestedSkip)
    }

    func applyingNextPage(
        _ page: ProductPage,
        to existing: [Product],
        requestedSkip: Int
    ) -> ProductListPage {
        applying(page, to: existing, requestedSkip: requestedSkip)
    }

    private func applying(
        _ page: ProductPage,
        to existing: [Product],
        requestedSkip: Int
    ) -> ProductListPage {
        var seen = Set(existing.map(\.id))
        let incoming = page.products.filter { seen.insert($0.id).inserted }
        let nextSkip = requestedSkip + page.products.count
        return ProductListPage(
            products: existing + incoming,
            hasMore: !page.products.isEmpty && nextSkip < page.total,
            nextSkip: nextSkip
        )
    }
}
